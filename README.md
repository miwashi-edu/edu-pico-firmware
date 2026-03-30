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
git config --global credential.helper store
```

## Add software

### Development Environment

```bash
sudo apt install build-essential -y # GCC, G++, make, and libc development headers
sudo apt install gcc-arm-none-eabi -y # ARM Cross-compiler.
sudo apt install libnewlib-arm-none-eabi -y # Std C-library.
sudo apt install libstdc++-arm-none-eabi-newlib -y  Std C++-library.
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
```

> Create an empty project on github with name `pico`
> Add `README`, and `.gitignore` for `C`.

```bash
cd ~
cd ws
git clone https://github.com/[GITHUB-USER]/pico.git
cd pico
```

## CMakeLists.txt

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
EOF
```

## Commit it

```bash
git add .
git commit -m "Initial Commit"
git push # We cloned from github
```


