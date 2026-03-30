# edu-pico-firmware

## Prepare

```bash
cd ~
cd ws
cd pico
git add .
git commit -m "level-3"
git push
```

## Instructions

### Interrupt Firmware

```bash
cd ~
cd ws
cd pico
mkdir interrupt
mkdir ./interrupt{src,include,cmake}
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
add_subdirectory(interrupt)
EOF
```

### ./interrupt/CMakeLists.txt

```bash
cat > ./interrupt/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.12)
set(PICO_BOARD pico2_w CACHE STRING "Target board")
set(PICO_PLATFORM rp2350-arm-s CACHE STRING "Target platform")
# MUST be before project()
include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)
project(interrupt C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
add_executable(${PROJECT_NAME} src/interrupt.c)
target_link_libraries(${PROJECT_NAME} pico_stdlib)
if (PICO_CYW43_SUPPORTED)
    target_link_libraries(${PROJECT_NAME} pico_cyw43_arch_none)
endif()
pico_add_extra_outputs(${PROJECT_NAME})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.uf2 DESTINATION /firmware)
EOF
```

### ./interrupt/src/interrupt.c

```bash
cat > ./interrupt/src/interrupt.c << 'EOF'
#include "pico/stdlib.h"
#include <stdio.h>

#define BUTTON_PIN 15

void button_callback(uint gpio, uint32_t events) {
    printf("PRESSED\n");
}

int main() {
    stdio_init_all();

    gpio_init(BUTTON_PIN);
    gpio_set_dir(BUTTON_PIN, GPIO_IN);
    gpio_pull_up(BUTTON_PIN);

    gpio_set_irq_enabled_with_callback(BUTTON_PIN, GPIO_IRQ_EDGE_FALL, true, &button_callback);

    printf("Starting...\n");

    while (true) {
        tight_loop_contents();
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




