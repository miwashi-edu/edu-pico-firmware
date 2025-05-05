add_executable(blink main.c)
add_executable(gul main.c)

pico_add_extra_outputs(blink)
pico_add_extra_outputs(gul)

target_link_libraries(blink pico_stdlib)
target_link_libraries(gul pic_stdlib)

if (PICO_CYW43_SUPPORTED)
    target_link_libraries(blink pico_cyw43_arch_none)
    target_link_libraries(gul pico_cyw43_arch_none)
endif()
