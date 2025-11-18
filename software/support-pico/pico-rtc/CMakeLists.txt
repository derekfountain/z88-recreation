cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(pico_rtc C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

if (TARGET tinyusb_device)

  add_executable(pico_rtc
    pico_rtc.c
  )

  target_link_libraries(pico_rtc pico_stdlib)

  pico_enable_stdio_usb(pico_rtc 0)
  pico_enable_stdio_uart(pico_rtc 0)

  pico_add_extra_outputs(pico_rtc)

elseif(PICO_ON_DEVICE)
   message(WARNING "not building because TinyUSB submodule is not initialized in the SDK")
endif()
