cmake_minimum_required(VERSION 3.7.2)

project(libseL4seccells C ASM)

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
        src/*.h
)
list(SORT deps)

add_library(seL4seccells STATIC EXCLUDE_FROM_ALL ${deps})

# Have public header files (= visible to projects using the library)
target_include_directories(seL4seccells PUBLIC include)
# Have private header files (= visible only to the library itself for building)
target_include_directories(seL4seccells PRIVATE src)

target_link_libraries(seL4seccells
    sel4
    muslc
    utils
    seccells_Config
)

