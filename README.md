# edu-pico-firmware

## Prepare

```bash
git clone https://github.com/miwashi-edu/edu-pico-firmware.git
cd edu-pico-firmware
docker compose up -d
ssh -p 2227 dev@localhost # password dev
sudo apt update && sudo apt upgrade -y
```

## Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

git config --global user.name "Mikael Wallin"
git config --global user.email "mikael.x.wallin@gmail.com"
```

## Add software

### Development Environment

```bash
sudo apt install build-essential
sudo apt install gcc-arm-none-eabi #
sudo apt install libnewlib-arm-none-eabi #
sudo apt install libstdc++-arm-none-eabi-newlib #
sudo apt install cmake
```

## Instructions

> Create an empty project on github with name `pico`
> Add `README`, and `.gitignore` for `C`.

```bash
cd ~
mkdir ws
cd ws
git clone https://github.com/[GITHUB-USER]/pico.git
cd pico
```

## Blink Firmware

```bash
mkdir blink && cd blink
mkdir src
```

## CMakeLists.txt

```bash
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.13)

include($ENV{PICO_SDK_PATH}/external/pico_sdk_import.cmake)

project(blink C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(blink src/blink.c)

target_link_libraries(blink pico_stdlib)

pico_add_extra_outputs(blink)
EOF
```

## ./src/blink.c

```bash
cat > ./src/blink.c << 'EOF'
#include "pico/stdlib.h"

int main() {
    const uint LED_PIN = 25;  // GP25 for Pico, change to 32 for Pico W/Pico 2 W
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    while (true) {
        gpio_put(LED_PIN, 1);
        sleep_ms(500);
        gpio_put(LED_PIN, 0);
        sleep_ms(500);
    }
}
EOF
```

