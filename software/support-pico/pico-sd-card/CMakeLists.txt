cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)

project(pico_sd_card C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

if (TARGET tinyusb_device)

  add_executable(pico_sd_card
    pico_sd_card.c
    hw_config.c
  )

  add_subdirectory(no-OS-FatFS-SD-SPI-RPi-Pico/FatFs_SPI)

  target_link_libraries(pico_sd_card pico_stdlib
			FatFs_SPI)

  pico_enable_stdio_usb(pico_sd_card 0)
  pico_enable_stdio_uart(pico_sd_card 0)

  pico_add_extra_outputs(pico_sd_card)

elseif(PICO_ON_DEVICE)
   message(WARNING "not building because TinyUSB submodule is not initialized in the SDK")
endif()
