cmake_minimum_required(VERSION 3.25.1)

project(objc VERSION 0.1.0 LANGUAGES OBJC C)

set(CMAKE_INCLUDE_CURRENT_DIR OFF)

execute_process(
  COMMAND gnustep-config --objc-flags
  OUTPUT_VARIABLE GNUSTEP_OBJC_FLAGS
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
  COMMAND gnustep-config --base-libs
  OUTPUT_VARIABLE GNUSTEP_BASE_LIBS
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(REPLACE " " ";" GNUSTEP_OBJC_FLAGS_LIST "${GNUSTEP_OBJC_FLAGS}")
string(REPLACE " " ";" GNUSTEP_BASE_LIBS_LIST   "${GNUSTEP_BASE_LIBS}")

include(FetchContent)

set(RAYLIB_EMBEDDED_DATA ON CACHE BOOL "" FORCE)
FetchContent_Declare(
  raylib
  GIT_REPOSITORY https://github.com/raysan5/raylib.git
  GIT_TAG        master
)
set(RAYLIB_BUILD_EXAMPLES  OFF     CACHE BOOL "" FORCE)
set(RAYLIB_BUILD_GAMES     OFF     CACHE BOOL "" FORCE)
# set(BUILD_SHARED_LIBS      OFF     CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(raylib)

FetchContent_Declare(
  cJSON
  GIT_REPOSITORY https://github.com/DaveGamble/cJSON.git
  GIT_TAG        v1.7.18
)
FetchContent_MakeAvailable(cJSON)

FetchContent_Declare(
  libzip
  GIT_REPOSITORY https://github.com/nih-at/libzip.git
  GIT_TAG        main
)
find_package(ZLIB REQUIRED)
FetchContent_MakeAvailable(libzip)

file(GLOB_RECURSE SOURCE_FILES_C    src/*.c)
file(GLOB_RECURSE SOURCE_FILES_OBJC src/*.m)
set(SOURCE_FILES ${SOURCE_FILES_C} ${SOURCE_FILES_OBJC})
set_source_files_properties(${SOURCE_FILES_OBJC} PROPERTIES LANGUAGE OBJC)

add_executable(${PROJECT_NAME} ${SOURCE_FILES})
target_compile_options(${PROJECT_NAME} PRIVATE ${GNUSTEP_OBJC_FLAGS_LIST})
target_link_libraries(${PROJECT_NAME} PRIVATE raylib cjson libzip::zip ${GNUSTEP_BASE_LIBS_LIST} pthread m dl)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src/include ${cjson_SOURCE_DIR})

set_target_properties(${PROJECT_NAME} PROPERTIES
  C_STANDARD             99
  C_STANDARD_REQUIRED    ON
  OBJC_ENABLE_EXCEPTIONS ON
)
