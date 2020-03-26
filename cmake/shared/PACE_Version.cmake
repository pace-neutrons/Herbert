#[=======================================================================[.rst:
herbert_Version
-----------------

Build a version release string:
  <version>[-<date>]-<target>-<matlab>[-<sha>]

 Optional elements are included based on the value of ${PROJECT_NAME}_RELEASE_TYPE
 - Date included for "nightly" builds
 - SHA included for non-"release" builds (i.e. "nightly" or "pull-request")

Variables required by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``${PROJECT_NAME}_RELEASE_TYPE``
Release type: "nightly", "release" or "pull-request" (default)

``Matlab_RELEASE``
This is provided by the `herbert_FindMatlab` module which must be loaded first

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``${PROJECT_NAME}_FULL_VERSION``
formatted version string

#]=======================================================================]

set(${PROJECT_NAME}_FULL_VERSION "${PROJECT_VERSION}")
string(TOUPPER "${${PROJECT_NAME}_RELEASE_TYPE}" ${PROJECT_NAME}_RELEASE_TYPE)

if(${PROJECT_NAME}_RELEASE_TYPE STREQUAL "NIGHTLY")
    string(TIMESTAMP _date "%Y%m%d")
    set(${PROJECT_NAME}_FULL_VERSION "${${PROJECT_NAME}_FULL_VERSION}-${_date}")
endif()

if(UNIX)
    set(${PROJECT_NAME}_PLATFORM "linux")
elseif(WIN32)
    set(${PROJECT_NAME}_PLATFORM "win64")
endif()

set(${PROJECT_NAME}_FULL_VERSION "${${PROJECT_NAME}_FULL_VERSION}-${${PROJECT_NAME}_PLATFORM}-${Matlab_RELEASE}")

if(NOT "${${PROJECT_NAME}_RELEASE_TYPE}" STREQUAL "RELEASE")
    find_package(Git QUIET)
    execute_process(
        COMMAND ${GIT_EXECUTABLE} rev-list --abbrev-commit --no-merges -n 1 HEAD
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE _res
        OUTPUT_VARIABLE GIT_REVISION_SHA
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(${PROJECT_NAME}_FULL_VERSION "${${PROJECT_NAME}_FULL_VERSION}-${GIT_REVISION_SHA}")
endif()

message(STATUS "${PROJECT_NAME}_FULL_VERSION: ${${PROJECT_NAME}_FULL_VERSION}")

# Set the short version which is used in ${PROJECT_NAME}_version.[m|h] files
set(${PROJECT_NAME}_SHORT_VERSION "${PROJECT_VERSION}")
if(NOT "${${PROJECT_NAME}_RELEASE_TYPE}" STREQUAL "RELEASE")
    set(${PROJECT_NAME}_SHORT_VERSION "${${PROJECT_NAME}_SHORT_VERSION}\.${GIT_REVISION_SHA}")
endif()
message(STATUS "${PROJECT_NAME}_SHORT_VERSION: ${${PROJECT_NAME}_SHORT_VERSION}")
