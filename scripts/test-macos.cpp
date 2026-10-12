#include "ffi.rs.h"
#include <iostream>
#include <stdexcept>

using namespace craby::reactnativenitrotor::bridging;

int main(int argc, char **argv) {
  try {
    auto tor = createReactNativeNitroTor(1, "");
    if (getServiceStatus(*tor) != 2 || shutdownService(*tor)) {
      throw std::runtime_error("Expected a stopped Tor service");
    }

    // Optional live test: use a fresh directory, never an existing app's data.
    if (argc == 2) {
      StartTorParams params{argv[1], 19050, 19051, 120000};
      auto result = startTorIfNotRunning(*tor, params);
      if (!result.is_success || result.onion_address.empty()) {
        throw std::runtime_error(std::string(result.error_message));
      }
      HttpGetParams request{"https://check.torproject.org/api/ip", "", 60000, false};
      auto response = httpGet(*tor, request);
      bool passed = response.status_code == 200 &&
                    std::string(response.body).find("\"IsTor\":true") != std::string::npos;
      bool stopped = shutdownService(*tor);
      if (!passed || !stopped || getServiceStatus(*tor) != 2) {
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
