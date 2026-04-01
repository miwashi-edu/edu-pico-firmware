# edu-pico-firmware

## Prepare

```bash
cd ~
cd ws
cd pico
git add .
git commit -m "level-5"
git push
```

## Instructions

### Watchdog Firmware

```bash
cd ~
cd ws
cd pico
mkdir watchdog
mkdir ./watchdog{src,include,cmake}
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
EOF
```

### ./watchdog/CMakeLists.txt

```bash
cat > ./watchdog/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.12)

project(watchdog C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(${PROJECT_NAME} src/watchdog.c)
pico_enable_stdio_usb(${PROJECT_NAME}  1)

target_link_libraries(${PROJECT_NAME} pico_stdlib)
pico_add_extra_outputs(${PROJECT_NAME})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.uf2 DESTINATION /firmware)
EOF
```

### ./watchdog/src/watchdog.c

```bash
cat > ./watchdog/src/watchdog.c << 'EOF'
#include "pico/stdlib.h"
#include <stdio.h>

#define BUTTON_PIN 15
#define DELAY_MS 250
#define STARTUP_DELAY_MS 5000
#define WATCHDOG_FEED_TIME_MS 2000

void button_callback(uint gpio, uint32_t events) {
    while (1){
        printf("No dog food!\n");
        sleep_ms(DELAY_MS);
    }
}

int init() {
    if (watchdog_caused_reboot()) {
        printf("Recovered from watchdog reset\n");
    } else {
        printf("Starting...\n");
    }
    watchdog_enable(WATCHDOG_FEED_TIME_MS, 1);

    gpio_init(BUTTON_PIN);
    gpio_set_dir(BUTTON_PIN, GPIO_IN);
    gpio_pull_up(BUTTON_PIN);

    gpio_set_irq_enabled_with_callback(BUTTON_PIN, GPIO_IRQ_EDGE_FALL, true, &button_callback);
}

int main() {
    stdio_init_all();
    sleep_ms(STARTUP_DELAY_MS);
    init();

    while (1) {
        printf("Feeding dog\n");
        watchdog_update();
        sleep_ms(DELAY_MS);
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




