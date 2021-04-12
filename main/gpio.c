#include "gpio.h"
#include <driver/gpio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

void gpio_task(void *arg) {
  while (1) {
    gpio_set_level(GPIO_NUM_22, gpio_get_level(GPIO_NUM_23));
    vTaskDelay(1);
  }
}

void setup_gpio() {
  gpio_config_t io_conf;

  io_conf.intr_type = GPIO_INTR_DISABLE;
  io_conf.mode = GPIO_MODE_OUTPUT;
  io_conf.pin_bit_mask = GPIO_SEL_22;
  io_conf.pull_down_en = 0;
  io_conf.pull_up_en = 0;
  gpio_config(&io_conf);

  io_conf.intr_type = GPIO_INTR_ANYEDGE;
  io_conf.mode = GPIO_MODE_INPUT;
  io_conf.pin_bit_mask = GPIO_SEL_23;
  io_conf.pull_down_en = 1;
  gpio_config(&io_conf);


  gpio_install_isr_service(0);

  xTaskCreate(gpio_task, "gpio_task", 2048, NULL, tskIDLE_PRIORITY, NULL);
}
