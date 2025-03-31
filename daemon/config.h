#pragma once

#include <string>

namespace qtstuff::daemon {

struct Config {
    std::string address{"127.0.0.1:50051"};
};


}
