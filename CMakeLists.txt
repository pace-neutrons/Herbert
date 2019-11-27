cmake_minimum_required(VERSION 3.10)

project("Herbert")

set(CMAKE_CXX_STANDARD 11)

# Sort our targets into folders
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Set our options
option(BUILD_FORTRAN "Build the Fortran Mex libraries" OFF)

# Add cmake directory to CMake's path
if(NOT CMAKE_MODULE_PATH)
  set(CMAKE_MODULE_PATH)
endif()
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

# Look for packages early so we can exit if they're not found
find_package(MPI REQUIRED)
include(herbert_FindMatlab)

# Set the destination of our build artifacts
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

add_subdirectory("_LowLevelCode")