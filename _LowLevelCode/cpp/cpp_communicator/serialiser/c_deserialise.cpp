/*=========================================================
 * c_deserialise.cpp
 * Deserialise serialised data back into a MATLAB object
 *
 * See also:
 * hlp_serialize
 * hlp_deserialize
 *
 * This is a MEX-file for MATLAB.
 *=======================================================*/
#include <iostream>
#include <cstring>
#include <cmath>
#include <vector>
#include "cpp_serialise.hpp"

size_t memPtr;

template<typename T, typename A>
inline void deser(const uint8_t* data, std::vector<T,A>& output, const double amount) {
  memcpy(output.data(), &data[memPtr], amount);
  memPtr += amount;
}

inline void deser(const uint8_t* data, void* output, const double amount) {
  memcpy(output, &data[memPtr], amount);
  memPtr += amount;
}

inline void read_data(uint8_t* data, mxArray* output, const size_t elemSize, const size_t nElem) {
  if (mxIsComplex(output)) {
    // Size of a complex component is half that of the whole complex
    size_t compSize = elemSize/2;

#if MX_HAS_INTERLEAVED_COMPLEX
    void* toWrite = mxGetComplexDouble(output);
    // Offset imaginary to end
    size_t imPtr = memPtr + (1+nElem)*compSize;

    for (int i = 0; i < nElem; i+=elemSize, memPtr += compSize, imPtr += compSize) {
      memcpy(&toWrite[i]         , &data[memPtr],  compSize);
      memcpy(&toWrite[i+compSize], &data[imPtr] ,  compSize);
    }
    memPtr = imPtr; // Finally update memPtr

#else
    void* toWrite = mxGetPr(output);
    deser(data, toWrite, compSize*nElem);
    toWrite = mxGetPi(output);
    deser(data, toWrite, compSize*nElem);

#endif

  } else {
    void* toWrite = mxGetPr(output);
    deser(data, toWrite, elemSize*nElem);
  }
}


mxArray* deserialise(uint8_t* data, size_t size, bool recursed) {

  mxArray* output = nullptr;

  tag_type tag;
  deser(data, &tag, types_size[UINT8]);
  size_t nDims;
  std::vector<uint32_t> cast_dims(2);
  std::vector<mwSize> vDims(2);
  size_t nElem;

  // Special case as function handles work differently
  if (tag.type != FUNCTION_HANDLE) {
    nDims = tag.dim;

    if (nDims > 2) {
      vDims.resize(nDims);
      cast_dims.resize(nDims);
    }

    deser(data, cast_dims, nDims*types_size[UINT32]);
    switch (nDims) {
    case 0:
      nElem = 1;
      nDims = 2;
      std::fill(vDims.begin(), vDims.end(), 1);
      break;

    case 1:
      nElem = cast_dims[0];
      nDims = 2;
      if (nElem == 0) { // Handle null
        std::fill(vDims.begin(), vDims.end(), 0);
      } else {
        vDims[0] = 1;
        vDims[1] = nElem;
      }
      break;

    default:
      nElem = 1;

      for (size_t i = 0; i < nDims; i++) {
        vDims[i] = cast_dims[i];
        nElem *= vDims[i];
      }
      break;

    }
  } else {
    // Function handle always scalar
    std::fill(vDims.begin(), vDims.end(), 1);
    std::fill(cast_dims.begin(), cast_dims.end(), 1);
    nElem = 1;

  }

  // C Mex API requires pointer, not vector
  mwSize* dims = vDims.data();

  switch (tag.type) {
    // Sparse
  case SPARSE_LOGICAL:
  case SPARSE_DOUBLE:
  case SPARSE_COMPLEX_DOUBLE:
    {
      uint32_t nnz;
      deser(data, &nnz, types_size[UINT32]);

      if (tag.type == SPARSE_LOGICAL) {
        output = mxCreateSparseLogicalMatrix(dims[0], dims[1], nnz);
      } else {
        mxComplexity cmplx = (mxComplexity) (tag.type == SPARSE_COMPLEX_DOUBLE);
        output = mxCreateSparse(dims[0], dims[1], nnz, cmplx);
      }
      mwIndex* ir = mxGetIr(output);
      mwIndex* jc = mxGetJc(output);
      std::vector<uint64_t> map_jc(nnz);

      deser(data, ir, types_size[UINT64]*nnz);
      deser(data, map_jc, types_size[UINT64]*nnz);

      // Unmap Jc (see MATLAB docs on sparse arrays in MEX API)
      for (const uint64_t& row: map_jc) {
        jc[row+1]++;
      }

      for (int i = 1; i < dims[1]+1; i++) {
        jc[i] += jc[i-1];
      }

      read_data(data, output, types_size[tag.type], nnz);

    }
    break;
  case CHAR:
    {
      std::vector<char> arr(nElem+1);
      deser(data, arr, nElem*types_size[CHAR]);
      output = mxCreateCharArray(nDims, dims);
      char* out = (char*) mxGetPr(output);
      for (int i =0; i < nElem; i++) {
        out[2*i] = arr[i];
      }
    }
    break;
  case LOGICAL:
    output = mxCreateLogicalArray(nDims, dims);
    read_data(data, output, types_size[tag.type], nElem);
    break;
  case INT8:
  case UINT8:
  case INT16:
  case UINT16:
  case INT32:
  case UINT32:
  case INT64:
  case UINT64:
  case SINGLE:
  case DOUBLE:
  case COMPLEX_INT8:
  case COMPLEX_UINT8:
  case COMPLEX_INT16:
  case COMPLEX_UINT16:
  case COMPLEX_INT32:
  case COMPLEX_UINT32:
  case COMPLEX_INT64:
  case COMPLEX_UINT64:
  case COMPLEX_SINGLE:
  case COMPLEX_DOUBLE:
    {
      // Complex tags are 13-22
      mxComplexity cmplx = (mxComplexity) (12 < tag.type && tag.type < 23);
      output = mxCreateNumericArray(nDims, dims, unmap_types[tag.type], cmplx);
      read_data(data, output, types_size[tag.type], nElem);
    }
    break;

  case FUNCTION_HANDLE:
    {
      switch(tag.dim) {
      case 1:
        {
          mxArray* name = deserialise(data, size, 1);
          mexCallMATLAB(1, &output, 1, &name, "str2func");
          mxDestroyArray(name);
        }
        break;
      case 2:
        {
          mxArray* name = deserialise(data, size, 1);
          mxArray* workspace = deserialise(data, size, 1);
          std::vector<mxArray*> input {name, workspace};
          mexCallMATLAB(1, &output, 2, input.data(), "restore_function");
          mxDestroyArray(name);
          mxDestroyArray(workspace);
        }
        break;
      case 3:
        {
          mxArray* parentage = deserialise(data, size, 1);
          const int len = mxGetNumberOfElements(parentage);

          // Initial output
          output = mxDuplicateArray(mxGetCell(parentage, len-1));

          std::vector<mxArray*> input(3);

          mxArray* stringHandle = mxCreateString("handle");
          input[0] = stringHandle;
          for (int i = len-2; i >= 0; i--) {
            input[1] = output;
            input[2] = mxGetCell(parentage, i);
            mexCallMATLAB(1, &output, 3, input.data(), "arg_report");
          }
          mxDestroyArray(stringHandle);
          mxDestroyArray(parentage);
          break;
        }
      }
    }
    break;

  case VALUE_OBJECT:
    {
      memPtr++; // Skip name_tag
      uint32_t nameLen;
      deser(data, &nameLen, types_size[UINT32]);
      std::vector<char> name(nameLen+1);
      // Null terminator
      name[nameLen] = 0;
      deser(data, name, nameLen*types_size[CHAR]);

      uint8_t ser_tag;
      deser(data, &ser_tag, types_size[UINT8]);

      switch (ser_tag) {
      case SELF_SER:
        {
          mxArray* mxData = mxCreateNumericMatrix(size-memPtr,1,mxUINT8_CLASS, (mxComplexity) 0);
          mxArray* mxName = mxCreateString(name.data());
          mxSetPr(mxData, (double *) &data[memPtr]);
          std::vector<mxArray*> results(2);
          std::vector<mxArray*> input {mxName, mxData};
          mexCallMATLAB(2, results.data(), 2, input.data(), "c_hlp_deserialise_object_self");
          output = results[0];
          memPtr += mxGetScalar(results[1]);
          mxDestroyArray(mxName);
          mxDestroyArray(mxData);
        }
        break;
      case SAVEOBJ:
        {
          mxArray* mxName = mxCreateString(name.data());
          mxArray* conts = deserialise(data, size, 1);
          std::vector<mxArray*> input {mxName, conts};
          mexCallMATLAB(1, &output, 2, input.data(), "c_hlp_deserialise_object_loadobj");
          mxDestroyArray(conts);
          mxDestroyArray(mxName);
        }
        break;
      case STRUCTED:
          {
            output = deserialise(data, size, 1);
            mxSetClassName(output, name.data());
          }
        break;
      }

    }
    break;

  case STRUCT:
    {
      uint32_t nFields;
      deser(data, &nFields, types_size[UINT32]);

      std::vector<uint32_t> fNameLens(nFields);
      deser(data, fNameLens, nFields*types_size[UINT32]);

      std::vector<std::vector<char>> fNames(nFields);
      std::vector<char*> mxData(nFields);
      for (int field=0; field < nFields; field++) {
        fNames[field] = std::vector<char>(fNameLens[field]+1);
        mxData[field] = fNames[field].data();
        fNames[field][fNameLens[field]] = 0;
        deser(data, fNames[field], fNameLens[field]*types_size[CHAR]);
      }

      output = mxCreateStructArray(nDims, dims, nFields, (const char**) mxData.data());
      if (nFields == 0) break;

      mxArray* cellData = deserialise(data, size, 1);

      for (int obj=0, elem=0; obj < nElem; obj++) {
        for (int field=0; field < nFields; field++, elem++) {
          mxArray* cellElem = mxGetCell(cellData, elem);
          mxSetFieldByNumber(output, obj, field, cellElem);
        }
      }

    }
    break;

  case CELL:
    {
      output = mxCreateCellArray(nDims, dims);
      for (mwIndex i = 0; i < nElem; i++) {
        mxArray* elem = deserialise(data, size, 1);
        mxSetCell(output, i, elem);
      }
    }
    break;
  }

  /* Avoid making plhs persistent,
     others *should* deallocate when the root object does
     (according to MEX docs) */
  if (recursed) {
    mexMakeArrayPersistent(output);
  }
  return output;
}

/* MATLAB entry point c_deserialise */
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[] ) {

#if defined(_LP64) || defined (_WIN64)
#ifdef MX_COMPAT_32
  for (i=0; i<nrhs; i++)  {
    if (mxIsSparse(prhs[i])) {
      mexErrMsgIdAndTxt("MATLAB:c_deserialise:NoSparseCompat",
                        "MEX-files compiled on a 64-bit platform that use sparse array functions "
                        "need to be compiled using -largeArrayDims.");
    }
  }
#endif
#endif

  if (nlhs > 1) {
    mexErrMsgIdAndTxt("MATLAB:c_deserialise:badLHS", "Bad number of LHS arguments in c_deserialise");
  }
  if (nrhs != 1) {
    mexErrMsgIdAndTxt("MATLAB:c_deserialise:badRHS", "Bad number of RHS arguments in c_deserialise");
  }

  memPtr = 0;
  mwSize size = mxGetNumberOfElements(prhs[0]);
  uint8_t* data = (uint8_t*) mxGetPr(prhs[0]);
  plhs[0] = deserialise(data, size, 0);
}
