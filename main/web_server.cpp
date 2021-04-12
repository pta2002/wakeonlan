#include "web_server.h"
#include <esp_http_server.h>
#include <esp_log.h>
#include <cJSON.h>
#include <driver/gpio.h>

httpd_uri_t root = {
  .uri = "/api/v1/status",
  .method = HTTP_GET,
  .handler = [](httpd_req_t *req) -> esp_err_t {
    ESP_LOGI("http", "status");

    auto obj = cJSON_CreateObject();
    cJSON_AddItemToObject(obj, "on", cJSON_CreateBool(false));

    httpd_resp_set_type(req, "application/json");

    char *resp = cJSON_Print(obj);
    httpd_resp_send(req, resp, HTTPD_RESP_USE_STRLEN);

    cJSON_Delete(obj);
    free(resp);
    return ESP_OK;
  },
  .user_ctx = NULL
};

extern "C" void setup_webserver() {
  httpd_config_t config = HTTPD_DEFAULT_CONFIG();
  httpd_handle_t server = NULL;

  if (httpd_start(&server, &config) == ESP_OK) {
    ESP_LOGI("http", "created server");
    httpd_register_uri_handler(server, &root);
  }
}
