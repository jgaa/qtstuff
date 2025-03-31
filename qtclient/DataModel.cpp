#include "DataModel.h"

using namespace std;

DataModel::DataModel(QObject *parent)
: QObject(parent)
{
}

void DataModel::start()
{
#ifdef ENABLE_GRPC
    startGrpc();
#else
    status_ = "GRPC not enabled in CMake";
    emit statusChanged();
#endif
}

#ifdef ENABLE_GRPC

void DataModel::startGrpc()
{
    // if (started_) {
    //     status_ = "Already started";
    //     emit statusChanged();
    //     return;
    // }

    started_ = true;

    const QUrl url{"http://127.0.0.1:50051"};
    channel_ = make_shared<QGrpcHttp2Channel>(url);
    client_ = make_unique<version::VersionService::Client>();
    client_->attachChannel(channel_);

    auto reply = client_->GetVersion(version::GetVersionRequest{});
    QObject::connect(
        reply.get(), &QGrpcCallReply::finished, reply.get(),
        [reply = std::move(reply), this](const QGrpcStatus &status) {
            if (status.isOk()) {
                if (auto data = reply->read<version::VersionResponse>()) {
                    version_ = data->version();
                    status_ = "OK";
                } else {
                    version_ = "Error getting version";
                    status_ = "Error - no data";
                }
            } else {
                version_ = "Error getting version";
                status_ = "Error: " + status.message();
            }
            emit versionChanged();
            emit statusChanged();
        },
        Qt::SingleShotConnection        // 2
    );
}

#endif
