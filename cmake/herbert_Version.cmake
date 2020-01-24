#[=======================================================================[.rst:
herbert_Version
-----------------

Build a version release string:
  <version>[-<date>]-<target>-<matlab>[-<sha>]

 Optional elements are included based on the value of Herbert_RELEASE_TYPE
 - Date included for "nightly" builds
 - SHA included for non-"release" builds (i.e. "nightly" or "pull-request")

Variables required by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Herbert_RELEASE_TYPE
Release type: "nightly", "release" or "pull-request" (default)

``Matlab_VERSION
This is provided by the `herbert_FindMatlab` module which must be loaded first

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Herbert_FULL_VERSION``
formatted version string

#]=======================================================================]

set(Herbert_FULL_VERSION "${PROJECT_VERSION}")

if(Herbert_RELEASE_TYPE STREQUAL "nightly")
    string(TIMESTAMP _date "%Y%m%d")
    set(Herbert_FULL_VERSION "${Herbert_FULL_VERSION}-${_date}")
endif()

if(UNIX)
    set(Herbert_PLATFORM "linux")
elseif(WIN32)
    set(Herbert_PLATFORM "win64")
endif()

set(Herbert_FULL_VERSION "${Herbert_FULL_VERSION}-${Herbert_PLATFORM}-${Matlab_VERSION}")

if(NOT "${Herbert_RELEASE_TYPE}" STREQUAL "release")
    find_package(Git QUIET)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-list --abbrev-commit --no-merges -n 1 HEAD
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE _res
        OUTPUT_VARIABLE GIT_REVISION_SHA
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(Herbert_FULL_VERSION "${Herbert_FULL_VERSION}-${GIT_REVISION_SHA}")
endif()

message(STATUS "Herbert_FULL_VERSION: ${Herbert_FULL_VERSION}")