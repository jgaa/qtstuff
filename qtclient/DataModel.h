#pragma once

#include <QObject>
#include <QQmlEngine>

#ifdef ENABLE_GRPC
#include <QGrpcHttp2Channel>

#include <grpcpp/grpcpp.h>
#include "stuff.qpb.h"
#include "stuff_client.grpc.qpb.h"
#endif

class DataModel : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString status MEMBER status_ NOTIFY statusChanged)
    Q_PROPERTY(QString version MEMBER version_ NOTIFY versionChanged)

signals:
    void statusChanged();
    void versionChanged();

public:
    DataModel(QObject *parent = nullptr);

    Q_INVOKABLE void start();

private:
#ifdef ENABLE_GRPC
    void startGrpc();

    std::unique_ptr<version::VersionService::Client> client_;
    std::shared_ptr<QGrpcHttp2Channel> channel_;
#endif

    QString status_{"unset"};
    QString version_;
    bool started_{false};

};
