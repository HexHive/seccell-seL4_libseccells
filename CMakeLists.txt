cmake_minimum_required(VERSION 3.7.2)

project(libseL4seccells C ASM)

set(configure_string "")

config_string(
    LibSCThreadsContextSizeBits
    SCTHREADS_CONTEXT_SIZE_BITS
    "Bits for the size of the context to allocate for each SCThread. Size will be (1 << LibSCThreadsContextSizeBits).
     This influences the stack size since stack size is (context_size - sizeof(seL4_UserContext))"
    DEFAULT
    16
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
