# edu-pico-firmware

## Prepare

```bash
cd ~
cd ws
cd pico
git add .
git commit -m "level-7"
git push
```

## Instructions

### Queue Firmware

```bash
cd ~
cd ws
cd pico
mkdir stoplight
mkdir ./stoplight/{src,include,cmake}
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
add_subdirectory(wifi)
add_subdirectory(watchdog)
add_subdirectory(queue)
add_subdirectory(stoplight)
EOF
```

### ./stoplight/CMakeLists.txt

```bash
cat > ./stoplight/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.12)

include(FetchContent)
FetchContent_Declare(
        tinyfsm
        GIT_REPOSITORY https://github.com/digint/tinyfsm.git
        GIT_TAG        master
)
FetchContent_MakeAvailable(tinyfsm)

add_executable(stoplight
        src/main.cpp
)

target_include_directories(stoplight PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${tinyfsm_SOURCE_DIR}/include
)

target_link_libraries(stoplight
        pico_stdlib
        hardware_gpio
        hardware_timer
)

pico_add_extra_outputs(stoplight)

pico_enable_stdio_usb(stoplight 1)
pico_enable_stdio_uart(stoplight 0)
EOF
```

### ./stoplight/src/main.cpp

```bash
cat > ./stoplight/src/main.cpp << 'EOF'
#include "stoplight.hpp"
#include "pico/stdlib.h"

static void set_lights(bool red, bool yellow, bool green) {
    gpio_put(RED_PIN,    red);
    gpio_put(YELLOW_PIN, yellow);
    gpio_put(GREEN_PIN,  green);
}

// Red
void Red::entry() { set_lights(1, 0, 0); }
void Red::react(TimerExpired const &) { transit<Green>(); }

// Green
void Green::entry() { set_lights(0, 0, 1); }
void Green::react(TimerExpired const &) { transit<Yellow>(); }

// Yellow
void Yellow::entry() { set_lights(0, 1, 0); }
void Yellow::react(TimerExpired const &) { transit<Red>(); }

int main() {
    stdio_init_all();

    gpio_init(RED_PIN);    gpio_set_dir(RED_PIN,    GPIO_OUT);
    gpio_init(YELLOW_PIN); gpio_set_dir(YELLOW_PIN, GPIO_OUT);
    gpio_init(GREEN_PIN);  gpio_set_dir(GREEN_PIN,  GPIO_OUT);

    Stoplight::start();

    const uint durations[] = { RED_DURATION_MS, GREEN_DURATION_MS, YELLOW_DURATION_MS };
    uint step = 0;

    while (true) {
        sleep_ms(durations[step % 3]);
        Stoplight::dispatch(TimerExpired());
        step++;
    }
}
EOF
```


### ./stoplight/include/stoplight.hpp

```bash
cat > ./stoplight/include/stoplight.hpp << 'EOF'
#pragma once

#include <tinyfsm.hpp>
#include "hardware/gpio.h"

constexpr uint RED_PIN    = 16;
constexpr uint YELLOW_PIN = 17;
constexpr uint GREEN_PIN  = 18;

constexpr uint RED_DURATION_MS    = 5000;
constexpr uint GREEN_DURATION_MS  = 4000;
constexpr uint YELLOW_DURATION_MS = 1000;

// Events
struct TimerExpired : tinyfsm::Event {};

// Forward declarations
struct Red;
struct Yellow;
struct Green;

// Base state
struct Stoplight : tinyfsm::Fsm<Stoplight> {
    virtual void react(TimerExpired const &) {}
    virtual void entry() {}
    virtual void exit()  {}
};

struct Red : Stoplight {
    void entry() override;
    void react(TimerExpired const &) override;
};

struct Green : Stoplight {
    void entry() override;
    void react(TimerExpired const &) override;
};

struct Yellow : Stoplight {
    void entry() override;
    void react(TimerExpired const &) override;
};

FSM_INITIAL_STATE(Stoplight, Red)
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
>

## Do Over

```bash
cd ~
cd ws
cd pico
git reset --hard
git clean -df
```




