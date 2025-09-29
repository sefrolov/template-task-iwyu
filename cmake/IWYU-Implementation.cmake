function(ct_setup_iwyu)
    find_package(Python3 COMPONENTS Interpreter)
    find_program(IWYU_BIN NAMES include-what-you-use iwyu)

    set(IWYU_MAPPING_ARGS "")
    if (Python3_Interpreter_FOUND)
        execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpfullversion
                OUTPUT_VARIABLE _gcc_ver_full
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET)
        execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpmachine
                OUTPUT_VARIABLE _triple
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET)
        string(REGEX REPLACE "^([0-9]+)\\..*" "\\1" _gcc_ver "${_gcc_ver_full}")
        execute_process(
                COMMAND ${Python3_EXECUTABLE} "${CMAKE_SOURCE_DIR}/cmake/iwyu-mapgen-libstdcxx.py"
                --lang imp "/usr/include/c++/${_gcc_ver}" "/usr/include/${_triple}/c++/${_gcc_ver}"
                OUTPUT_FILE "${CMAKE_SOURCE_DIR}/cmake/libstdcxx.imp"
        )
        list(APPEND IWYU_MAPPING_ARGS "-Xiwyu" "--mapping_file=${CMAKE_SOURCE_DIR}/cmake/libstdcxx.imp")
    else ()
        message(WARNING "python3 not found, running without mapping_file for iwyu")
    endif ()

    if (IWYU_BIN)
        if (MSVC)
            set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${IWYU_BIN};--driver-mode=cl"
                    "-Wno-unknown-warning-option"
                    ${IWYU_MAPPING_ARGS} PARENT_SCOPE)
        else ()
            set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${IWYU_BIN}"
                    "-Wno-unknown-warning-option"
                    ${IWYU_MAPPING_ARGS} PARENT_SCOPE)
        endif ()
    else ()
        message(WARNING "include-what-you-use not found, running without it")
    endif ()
endfunction()
