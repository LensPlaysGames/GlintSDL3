list(APPEND CMAKE_MODULE_PATH "~/Programming/play/LensorCompilerCollection/cmake/")

# Export compilation database in JSON format (for language servers).
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Use `ccache` if it is installed in system's PATH.
find_program(CCACHE_PROGRAM ccache)
if (CCACHE_PROGRAM)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CCACHE_PROGRAM}")
endif()

# Turn on diagnostics colours.
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    add_compile_options(-fdiagnostics-color=always)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    add_compile_options(-fcolor-diagnostics)
endif()

# Use mold as the default linker, if it exists.
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    find_program(MOLD_LINKER "mold")
    if (MOLD_LINKER)
        add_link_options(-fuse-ld=mold)
    endif()
endif()


cmake_minimum_required(VERSION 3.24)
project(project_glintsdl LANGUAGES Glint)

set(SDL_STATIC ON)
set(SDL_SHARED OFF)
add_subdirectory(SDL)

add_executable(glintui src/main.g)
target_link_libraries(glintui PRIVATE SDL3::SDL3)
