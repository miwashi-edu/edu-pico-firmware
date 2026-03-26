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
sudo apt install build-essential -y
sudo apt install gcc-arm-none-eabi -y #
sudo apt install libnewlib-arm-none-eabi -y #
sudo apt install libstdc++-arm-none-eabi-newlib -y #
sudo apt install cmake -y
```

## Instructions


### Pico-SDK

```bash
cd ~
mkdir ws
cd ws
git clone https://github.com/raspberrypi/pico-sdk.git # PICO_SDK_PATH is set to /~/ws/pico-sdk
cd ~/ws/pico-sdk
cd pico-sdk
git submodule update --init --recursive
git submodule update --init lib/cyw43-driver
```

> Create an empty project on github with name `pico`
> Add `README`, and `.gitignore` for `C`.

```bash
cd ~
cd ws
git clone https://github.com/[GITHUB-USER]/pico.git
cd pico
```

## Blink Firmware

```bash
mkdir blink && cd blink
mkdir src
mkdir cmake
```

## CMakeLists.txt

```bash
cat > CMakeLists.txt << 'EOF'
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

## ./src/blink.c

```bash
curl https://raw.githubusercontent.com/raspberrypi/pico-examples/refs/heads/master/blink/blink.c -o ./src/blink.c
```

## Try it

```bash
cd ~
cd ws
cd pico
cd blink
rm -rf build
cmake -B build
cmake --build build
cmake --install build # Copies .uf2 to your host computer
```

> Go to your host compter the project that has the Dockerfile, and look for
> firware directory, copy the .elf file to your pico.



