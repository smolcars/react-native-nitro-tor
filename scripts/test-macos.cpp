#include "ffi.rs.h"
#include <iostream>
#include <stdexcept>

using namespace craby::reactnativenitrotor::bridging;

int main(int argc, char **argv) {
  try {
    auto tor = createReactNativeNitroTor(1, "");
    if (std::string(getStatus(*tor)) != "{\"state\":\"stopped\"}") {
      throw std::runtime_error("Expected a stopped Tor service");
    }
    stop(*tor);

    // Optional live test: use a fresh directory, never an existing app's data.
    if (argc == 2) {
      NativeTorConfig params{argv[1], 19050, 120000};
      auto status = start(*tor, params);
      if (std::string(status).find("\"state\":\"running\"") == std::string::npos) {
        throw std::runtime_error("Expected a running Tor service");
      }
      NativeHiddenServiceOptions options{80, 19051, {}};
      auto service = createHiddenService(*tor, options);
      bool created = !service.onion_address.empty() && service.private_key.size() == 64;
      NativeHttpRequest request{"https://check.torproject.org/api/ip", "GET", "{}", "", 60000, false, true};
      auto response = std::string(httpRequest(*tor, request));
      bool passed = response.find("\"statusCode\":200") != std::string::npos &&
                    response.find("\\\"IsTor\\\":true") != std::string::npos;
      removeHiddenService(*tor, service.onion_address);
      stop(*tor);
      if (!created || !passed || std::string(getStatus(*tor)) != "{\"state\":\"stopped\"}") {
        throw std::runtime_error("Tor HTTP request or shutdown failed");
      }
    }

    std::cout << "macOS Tor bridge smoke test passed\n";
    return 0;
  } catch (const std::exception &error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
