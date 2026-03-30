# edu-pico-firmware

## Instructions

### Blink Firmware

```bash
cd ~
cd ws
cd pico
mkdir blink
mkdir ./blink{src,include,cmake}
```

### ./CMakeLists.txt

```bash
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.12)

set(PICO_BOARD pico2_w CACHE STRING "Target board")
set(PICO_PLATFORM rp2350-arm-s CACHE STRING "Target platform")

include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(all_projects C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_subdirectory(blink)
EOF
```

### ./blink/CMakeLists.txt

```bash
cat > ./blink/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.12)
set(PICO_BOARD pico2_w CACHE STRING "Target board")
set(PICO_PLATFORM rp2350-arm-s CACHE STRING "Target platform")
# MUST be before project()
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)
project(blink C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
add_executable(${PROJECT_NAME} src/blink.c)
target_link_libraries(${PROJECT_NAME} pico_stdlib)
if (PICO_CYW43_SUPPORTED)
    target_link_libraries(${PROJECT_NAME} pico_cyw43_arch_none)
endif()
pico_add_extra_outputs(${PROJECT_NAME})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.uf2 DESTINATION /firmware)
EOF
```

### ./blink/src/blink.c

```bash
curl https://raw.githubusercontent.com/raspberrypi/pico-examples/refs/heads/master/blink/blink.c -o ./blink/src/blink.c
```

## Try it

```bash
cd ~
cd ws
cd pico
rm -rf build
cmake -B build
cmake --build build
cmake --install build # Copies .uf2 to your host computer
```

> Go to your host compter the project that has the Dockerfile, and look for
> firware directory, copy the .u2f file to your pico.

## Do Over

```bash
cd ~
cd ws
cd pico
git reset --hard
git clean -df
```



