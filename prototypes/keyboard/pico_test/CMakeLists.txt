cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(z88r_kb_test C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(z88r_kb_test
	main.c
)

target_link_libraries(z88r_kb_test
	pico_stdlib
)

pico_enable_stdio_usb(z88r_kb_test 1) 
pico_enable_stdio_uart(z88r_kb_test 0)

pico_add_extra_outputs(z88r_kb_test)
