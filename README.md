# edu-pico-firmware

> Connect a button to pin 18, and pin 20.

## Prepare

```bash
cd ~
cd ws
cd pico
git add .
git commit -m "level-2"
git push
```

## Instructions

### Btn Firmware

```bash
cd ~
cd ws
cd pico
mkdir btn
mkdir ./btn{src,include,cmake}
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
add_subdirectory(btn)
EOF
```

### ./btn/CMakeLists.txt

```bash
cat > ./btn/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.12)

set(PICO_BOARD pico2_w CACHE STRING "Target board")
set(PICO_PLATFORM rp2350-arm-s CACHE STRING "Target platform")

# MUST be before project()
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(btn C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(${PROJECT_NAME} src/btn.c)
pico_enable_stdio_usb(${PROJECT_NAME}  1)

target_link_libraries(${PROJECT_NAME} pico_stdlib)
pico_add_extra_outputs(${PROJECT_NAME})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.uf2 DESTINATION /firmware)
EOF
```

### ./btn/src/btn.c

```bash
cat > ./btn/src/btn.c << 'EOF'
#include "pico/stdlib.h"
#include <stdio.h>

#define LOG_DELAY_MS 250
#define BUTTON_PIN 15

int main() {
    stdio_init_all();

    gpio_init(BUTTON_PIN);
    gpio_set_dir(BUTTON_PIN, GPIO_IN);
    gpio_pull_up(BUTTON_PIN);

    printf("Starting...\n");

    while (true) {
        bool pressed = !gpio_get(BUTTON_PIN); // active-low: pin reads 0 when pressed
        printf("Button: %s\n", pressed ? "PRESSED" : "released");
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




