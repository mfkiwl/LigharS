cmake_minimum_required (VERSION 3.12)

project ("LigharS" LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/bin")

if (NOT CMAKE_BUILD_TYPE)
    message(STATUS "No build type selected, default to Release")
    set(CMAKE_BUILD_TYPE "Release" CACHE PATH "Build Type" FORCE)
endif()

include_directories("${PROJECT_SOURCE_DIR}/include")
file(GLOB SRCS "${PROJECT_SOURCE_DIR}/src/*")
file(GLOB INCS "${PROJECT_SOURCE_DIR}/include/*")
add_library(LigharS STATIC ${SRCS} ${INCS} "include/rt.hpp")

file(GLOB TEST_SRCS "${PROJECT_SOURCE_DIR}/tests/*")
add_executable(TestLigharS ${TEST_SRCS} ${INCS} "include/rt.hpp")
target_link_libraries(TestLigharS LigharS)
