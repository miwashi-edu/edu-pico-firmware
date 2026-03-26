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
mkdir cmake
```

```bash
cd ~
cd ws
git clone https://github.com/raspberrypi/pico-sdk.git # PICO_SDK_PATH is set to /~/ws/pico-sdk
cd ~/ws/pico-sdk
git submodule update --init lib/cyw43-driver
```


## CMakeLists.txt

```bash
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.13)

set(APP blink)
set(CMAKE_EXECUTABLE_SUFFIX ".elf" CACHE STRING "" FORCE)
set(PICO_BOARD pico2_w CACHE STRING "Target board")
set(PICO_PLATFORM rp2350-arm-s CACHE STRING "Target platform")

include(cmake/pico_sdk.cmake)

project(blink C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(blink src/blink.c)

target_link_libraries(${APP} pico_stdlib pico_cyw43_arch_none)

pico_add_extra_outputs(${APP})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${APP}.uf2 DESTINATION /firmware)
EOF
```

## ./src/pico_sdk.cmake

```bash
cat > ./cmake/pico_sdk.cmake << 'EOF'
include(FetchContent)

FetchContent_Declare(
    pico-sdk
    GIT_REPOSITORY https://github.com/raspberrypi/pico-sdk.git
    GIT_TAG        2.2.0
)
FetchContent_MakeAvailable(pico-sdk)

set(PICO_SDK_PATH ${pico-sdk_SOURCE_DIR})
include(${PICO_SDK_PATH}/external/pico_sdk_import.cmake)
EOF
```

## ./src/blink.c

```bash
curl https://raw.githubusercontent.com/raspberrypi/pico-examples/refs/heads/master/blink/blink.c -o ./src/blink.c
```

