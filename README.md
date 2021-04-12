# Wake on LAN - ESP32 version!
This project is an attempt at adding a Wake on LAN-like feature to my cheap
motherboard. This is done by connecting an ESP32 (will probably port this to an
ESP8266 once I find something else to do with the ESP32 though) to the power
button pins on the motherboard, and exposing a simple API that allows one to a)
check if the computer is on (it checks this by checking if the power LED is
on!) and b) turn the computer on!

## Installing
The easiest way by far is to use Nix (I already did all the hard work!). Just
clone the repo, do `nix-shell` on the root and then `idf.py menuconfig` to set the
WiFi credentials. Then, run `idf.py flash` to flash it to your ESP32.

### The hardware bit
TODO once the schematic is done!
