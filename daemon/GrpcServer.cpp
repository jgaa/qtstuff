#include "GrpcServer.h"

// Include google grpc headers
#include <grpcpp/grpcpp.h>
#include <grpcpp/server_builder.h>
#include <grpcpp/server.h>
#include "logfault/logfault.h"

#include "stuff.grpc.pb.h"

using namespace std;

namespace qtstuff::daemon {

namespace {

    class VersionServiceImpl : public version::VersionService::CallbackService {
    public:
        virtual ::grpc::ServerUnaryReactor* GetVersion(
            ::grpc::CallbackServerContext* context,
            const ::version::GetVersionRequest* request,
            ::version::VersionResponse* response)  {

            assert(response);
            response->set_version(APP_VERSION);
            auto* reactor = context->DefaultReactor();
            reactor->Finish(grpc::Status::OK);

            LFLOG_TRACE << "GetVersion called by " << context->peer();

            return reactor;
        }
    };
} // anon na

GrpcServer::GrpcServer(const Config &config)
    : config(config)
{

}

void GrpcServer::run()
{
    VersionServiceImpl service;
    grpc::ServerBuilder builder;
    builder.AddListeningPort(config.address, grpc::InsecureServerCredentials());
    builder.RegisterService(&service);
    auto server = builder.BuildAndStart();
    LFLOG_INFO << "Server listening on " << config.address;

    server->Wait();
}


} // ns
