#[=======================================================================[.rst:
herbert_FindMatlab
-----------------

Calls the FindMatlab script that is shipped with CMake, and also finds some
other libraries that are not found by the afformentioned FindMatlab script.

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Matlab_BIN_DIR``
the path to Matlab's bin directory

``Matlab_DLL_DIR`` (Windows only)
the path to the directory containing Matlab's dynamically linked libraries

``Matlab_UT_LIBRARY``
the path to the Matlab UT library

``Matlab_VERSION``
the Matlab release e.g. R2019b

See the FindMatlab.cmake documentation for other variables defined by this
module. You'll find the file bundled with your CMake installation.

#]=======================================================================]
find_package(Matlab REQUIRED COMPONENTS MAIN_PROGRAM MEX_COMPILER)
get_filename_component(Matlab_LIBRARY_DIR "${Matlab_MEX_LIBRARY}" DIRECTORY)
get_filename_component(Matlab_BIN_DIR "${Matlab_MAIN_PROGRAM}" DIRECTORY)

# Get the Matlab release from the VersionInfo.xml file
file(READ "${Matlab_ROOT_DIR}/VersionInfo.xml" _version_info)
string(REGEX REPLACE
    ".*<release>(R[0-9]+[ab])</release>.*"
    "\\1"
    Matlab_VERSION
    "${_version_info}"
)

# Find the libut library
find_library(Matlab_UT_LIBRARY
    NAMES "ut" "libut"
    HINTS "${Matlab_LIBRARY_DIR}"
    NO_DEFAULT_PATH
)
mark_as_advanced(FORCE Matlab_UT_LIBRARY)

# The MX library doesn't seem to get found on UNIX, so make sure we have it
if(NOT DEFINED Matlab_MX_LIBRARY)
    find_library(Matlab_MX_LIBRARY
        NAMES "mx" "libmx"
        HINTS "${Matlab_LIBRARY_DIR}"
        NO_DEFAULT_PATH
    )
    mark_as_advanced(FORCE Matlab_MX_LIBRARY)
endif()

# Get the directory containing Matlab's dlls. This is required so we can tell
# CTest to add it to the system path when it runs tests
if(WIN32)
    if("CMAKE_SIZEOF_VOID_P" EQUAL 4)
        set(Matlab_DLL_DIR "${Matlab_BIN_DIR}/win32")
    else()
        set(Matlab_DLL_DIR "${Matlab_BIN_DIR}/win64")
    endif()
endif()
