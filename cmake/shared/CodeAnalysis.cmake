add_custom_target(analyse
  COMMENT "Performing code analysis..."
  )

add_custom_target(analyse-mlint
  COMMENT "- Performing MATLAB analysis (Mlint)..."
  BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/mlint.out"
  COMMAND matlab -nodisplay <<< "\"addpath('${Herbert_ROOT}/../admin');lint_wng({'${CMAKE_SOURCE_DIR}/**/*.m'},'${CMAKE_CURRENT_BINARY_DIR}/mlint.out');\""
  WORKING_DIRECTORY
  USES_TERMINAL
  )
add_dependencies(analyse analyse-mlint)

find_program(cppcheck NAMES cppcheck)
if (cppcheck)
  add_custom_target(analyse-cppcheck
    COMMENT "- Performing C++ analysis (CppCheck)..."
    BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/cppcheck.xml"
    COMMAND cppcheck --enable=all --inconclusive --xml --xml-version=2 -I "${CMAKE_SOURCE_DIR}/_LowLevelCode/cpp" "${CMAKE_SOURCE_DIR}/_LowLevelCode/" 2> "${CMAKE_CURRENT_BINARY_DIR}/cppcheck.xml"
    WORKING_DIRECTORY
    USES_TERMINAL
    )
  add_dependencies(analyse analyse-cppcheck)
endif()
