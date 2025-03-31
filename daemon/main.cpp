#include <iostream>
#include <filesystem>
#include <boost/program_options.hpp>
#include <boost/asio.hpp>

#include "config.h"
#include "logfault/logfault.h"
#include "GrpcServer.h"

using namespace std;

int main(int argc, char* argv[]) {
    try {
        locale loc("");
    } catch (const std::exception&) {
        cout << "Locales in Linux are fundamentally broken. Never worked. Never will. Overriding the current mess with LC_ALL=C" << endl;
        setenv("LC_ALL", "C", 1);
    }

    qtstuff::daemon::Config config;
    namespace po = boost::program_options;
    po::options_description general("Options");
    std::string log_level_console = "info";

    general.add_options()
        ("help,h", "Print help and exit")
        ("version,v", "Print version and exit")
        ("address,a",
         po::value(&config.address)->default_value(config.address),
         "Network address to use for gRPC.")
        ("log-to-console,C",
         po::value(&log_level_console)->default_value(log_level_console),
         "Log-level to the console; one of 'info', 'debug', 'trace'. Empty string to disable.")
        ;

    const auto appname = filesystem::path(argv[0]).stem().string();
    po::options_description cmdline_options;
    cmdline_options.add(general);
    po::variables_map vm;
    try {
        po::store(po::command_line_parser(argc, argv).options(cmdline_options).run(), vm);
        po::notify(vm);
    } catch (const std::exception& ex) {
        cerr << appname
             << " Failed to parse command-line arguments: " << ex.what() << endl;
        return -1;
    }

    if (vm.count("help")) {
        std::cout <<appname << " [options]";
        std::cout << cmdline_options << std::endl;
        return -2;
    }

    if (vm.count("version")) {
        std::cout << appname << ' ' << APP_VERSION << endl
                  << "Using C++ standard " << __cplusplus << endl
                  << "Platform " << BOOST_PLATFORM << endl
                  << "Compiler " << BOOST_COMPILER << endl
                  << "Build date " <<__DATE__ << endl;
        return -3;
    }

    {
        auto log_level = logfault::LogLevel::INFO;
        if (log_level_console == "debug") {
            log_level = logfault::LogLevel::DEBUGGING;
        } else if (log_level_console == "trace") {
            log_level = logfault::LogLevel::TRACE;
        } else if (log_level_console == "info") {
            log_level = logfault::LogLevel::INFO;
        } else if (log_level_console.empty()) {
            log_level = logfault::LogLevel::DISABLED;
        } else {
            cerr << appname << " Unknown log level " << log_level_console << endl;
            return -4;
        }

        logfault::LogManager::Instance().AddHandler(make_unique<logfault::StreamHandler>(clog, log_level));
    }

    LFLOG_INFO << appname << ' ' << APP_VERSION <<  " starting up";
    try {
        qtstuff::daemon::GrpcServer server(config);
        server.run();
    } catch (const std::exception& ex) {
        LFLOG_ERROR << "Exception: " << ex.what();
        return -5;
    }
}
