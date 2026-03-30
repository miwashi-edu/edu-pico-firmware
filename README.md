# edu-pico-firmware

## Prepare

```bash
cd ~
cd ws
cd pico
git add .
git commit -m "level-1"
git push
```

## Instructions

### Log Firmware

```bash
cd ~
cd ws
cd pico
mkdir log
mkdir ./log{src,include,cmake}
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
add_subdirectory(log)
EOF
```

### ./log/CMakeLists.txt

```bash
cat > ./log/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.12)

set(PICO_BOARD pico2_w CACHE STRING "Target board")
set(PICO_PLATFORM rp2350-arm-s CACHE STRING "Target platform")

# MUST be before project()
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(log C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(${PROJECT_NAME} src/log.c
)
pico_enable_stdio_usb(${PROJECT_NAME}  1)

target_link_libraries(${PROJECT_NAME} pico_stdlib)
pico_add_extra_outputs(${PROJECT_NAME})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.uf2 DESTINATION /firmware)
EOF
```

### ./log/src/log.c

```bash
cat > ./log/src/log.c << 'EOF'
#include "pico/stdlib.h"
#include <stdio.h>

#ifndef LOG_DELAY_MS
#define LOG_DELAY_MS 250
#endif


int main() {
    stdio_init_all();
    printf("Starting...\n");
    while (true) {
        printf("LED state: %d\n", true);
        sleep_ms(LOG_DELAY_MS);
        printf("LED state: %d\n", false);
        sleep_ms(LOG_DELAY_MS);
    }
}
EOF
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




