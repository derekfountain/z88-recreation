cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(app_board_blink C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

if (TARGET tinyusb_device)

  add_executable(app_board_blink
    app_board_blink.c
  )

  target_link_libraries(app_board_blink pico_stdlib)

  pico_enable_stdio_usb(app_board_blink 0)
  pico_enable_stdio_uart(app_board_blink 0)

  pico_add_extra_outputs(app_board_blink)

elseif(PICO_ON_DEVICE)
   message(WARNING "not building because TinyUSB submodule is not initialized in the SDK")
endif()
