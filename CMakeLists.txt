cmake_minimum_required(VERSION 3.7.2)

project(libseccells C ASM)

set(configure_string "")

config_string(
    LibSCThreadsStackSize
    SCTHREADS_STACK_SIZE
    "Size of stacks in bytes to allocate for each SCThread"
    DEFAULT
    65536
    UNQUOTE
)

mark_as_advanced(LibSCThreadsStackSize)
add_config_library(seccells "${configure_string}")

file(GLOB_RECURSE
    deps
        src/*.c
        src/*.S
)
list(SORT deps)

add_library(seccells STATIC EXCLUDE_FROM_ALL ${deps})

target_include_directories(seccells PUBLIC include)
target_link_libraries(seccells
    sel4
    muslc
    utils
    seccells_Config
)

