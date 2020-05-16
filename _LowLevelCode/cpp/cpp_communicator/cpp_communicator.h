#pragma once
//
// $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)" 
//
//
#include <memory>
#include "MPI_wrapper.h"
#include "input_parser.h"

void set_numlab_and_nlabs(class_handle<MPI_wrapper> const *const pCommunicatorHolder, int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);;