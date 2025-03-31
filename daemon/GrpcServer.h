#pragma once

#include "config.h"

namespace qtstuff::daemon {

class GrpcServer
{
public:
    GrpcServer(const Config& config);

    void run();

private:
    Config config;
};



}
