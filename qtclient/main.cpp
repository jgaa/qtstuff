
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QMessageLogContext>
#include <QDebug>
#include <QLoggingCategory>
#include <QtPlugin>

namespace {
void logToFile(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    static QFile logFile("log.txt");
    static bool initialized = false;

    if (!initialized) {
        logFile.open(QIODevice::Append | QIODevice::Text);
        initialized = true;
    }

    QTextStream out(&logFile);
    QString level;

    switch (type) {
    case QtDebugMsg:    level = "DEBUG"; break;
    case QtInfoMsg:     level = "INFO"; break;
    case QtWarningMsg:  level = "WARNING"; break;
    case QtCriticalMsg: level = "CRITICAL"; break;
    case QtFatalMsg:    level = "FATAL"; break;
    }

    out << QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz")
        << " [" << level << "] "
        << msg
        << " (" << context.file << ":" << context.line << ", " << context.function << ")\n";

    out.flush();

    if (type == QtFatalMsg)
        abort();
}
} // ns

int main(int argc, char *argv[])
{
    qInstallMessageHandler(logToFile);

#if defined(__linux__) && defined(QT_STATIC)
    Q_IMPORT_PLUGIN(QXcbIntegrationPlugin)
#endif

#if 0
    // optional: enable extra logging
    QLoggingCategory::setFilterRules(
        "qt.qml.imports.debug=true\n"
        "qt.qml.loader.info=true\n"
        "*.debug=true\n"
        );
#endif

    // Now do Qt stuff
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [&]() {
            qCritical() << "QML object creation failed.";
            QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.loadFromModule("QtStuff", "Main");

    int result = app.exec();
    qDebug() << "App exiting with code: " << result;
    return result;
}

