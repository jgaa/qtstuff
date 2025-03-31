#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtLogging>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [&app
        ]() {
            qCritical() << "Failed to create object in QML engine";
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.loadFromModule("QtStuff", "Main");

    return app.exec();
}
