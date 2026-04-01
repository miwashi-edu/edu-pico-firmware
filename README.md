# edu-pico-firmware

## Prepare

```bash
cd ~
cd ws
cd pico
git add .
git commit -m "level-6"
git push
```

## Instructions

### Queue Firmware

```bash
cd ~
cd ws
cd pico
mkdir queue
mkdir ./queue/{src,include,cmake}
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
EOF
```

### ./queue/CMakeLists.txt

```bash
cat > ./queue/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.12)

project(queue C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(${PROJECT_NAME} src/queue.c)
pico_enable_stdio_usb(${PROJECT_NAME}  1)

target_link_libraries(${PROJECT_NAME} pico_stdlib)
pico_add_extra_outputs(${PROJECT_NAME})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.uf2 DESTINATION /firmware)

EOF
```

### ./queue/src/queue.c

```bash
cat > ./queue/src/queue.c << 'EOF'
#include "pico/stdlib.h"
#include "pico/util/queue.h"
#include <stdio.h>

#define BTN_A_PIN 14
#define BTN_B_PIN 15
#define BTN_RESET_PIN 16

#define DELAY_MS 250
#define STARTUP_DELAY_MS 2000

#define NUMER_OF_Q_ELEMENTS 16

volatile uint32_t counter = 0;
// Queue for events
queue_t q;

typedef struct {
    uint gpio;
    uint32_t events;
} event_t;

void slow_process(uint gpio) {
    printf("Start %d from GPIO %d\n", counter++, gpio);

    printf("Step A\n"); sleep_ms(DELAY_MS);
    printf("Step B\n"); sleep_ms(DELAY_MS);
    printf("Step C\n"); sleep_ms(DELAY_MS);
    printf("Step D\n"); sleep_ms(DELAY_MS);

    printf("Done\n");
}

void gpio_isr(uint gpio, uint32_t events) {
    if (gpio == BTN_RESET_PIN) {
        printf("Resetting counter\n");
        counter = 0;
        printf("Counter reset\n");
        return;
    }
    printf("GPIO %d pressed\n", gpio);
    event_t e = {
        .gpio = gpio,
        .events = events
    };
    queue_try_add(&q, &e);
}

// --------------------
// Init helpers
// --------------------
void init_btn(int pin) {
    printf("Initializing GPIO %d\n", pin);
    gpio_init(pin);
    gpio_set_dir(pin, GPIO_IN);
    gpio_pull_up(pin);
}

void init_all() {
    printf("Initializing system\n");

    queue_init(&q, sizeof(event_t), NUMER_OF_Q_ELEMENTS);

    init_btn(BTN_A_PIN);
    init_btn(BTN_B_PIN);
    init_btn(BTN_RESET_PIN);

    gpio_set_irq_enabled_with_callback(BTN_A_PIN,GPIO_IRQ_EDGE_FALL,true,&gpio_isr);
    gpio_set_irq_enabled_with_callback(BTN_B_PIN,GPIO_IRQ_EDGE_FALL,true,&gpio_isr);
    gpio_set_irq_enabled_with_callback(BTN_RESET_PIN,GPIO_IRQ_EDGE_FALL,true,&gpio_isr);
}

int main() {
    stdio_init_all();
    sleep_ms(STARTUP_DELAY_MS);

    init_all();

    while (1) {
        event_t e;
        if (queue_try_remove(&q, &e)) {
            switch (e.gpio) {
            case BTN_A_PIN:
                printf("GPIO %d handled\n", e.gpio);
                slow_process(e.gpio);
                break;
            case BTN_B_PIN:
                printf("GPIO %d handled\n", e.gpio);
                slow_process(e.gpio);
                break;
            default:
                break;
            }
        }
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
>
> Start server in your host.

```bash
cat > server << 'EOF'
#!/usr/bin/env python3

from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        body = self.rfile.read(content_length)
        data = json.loads(body)

        print(f"Received: {data}")

        response = json.dumps(data).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(response))
        self.end_headers()
        self.wfile.write(response)

    def log_message(self, format, *args):
        pass  # suppress default request logging

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), Handler)
    print('Listening on port 8080...')
    server.serve_forever()
EOF
chmod +x server
./server
```

## Do Over

```bash
cd ~
cd ws
cd pico
git reset --hard
git clean -df
```




