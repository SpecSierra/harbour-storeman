#pragma once

#include <QObject>
#include <QDateTime>
#include <QUrlQuery>

class QQmlEngine;
class QJSEngine;
class QNetworkAccessManager;
class QNetworkRequest;
class QNetworkReply;

class OrnClientPrivate;

class OrnClient : public QObject
{
    friend class OrnBackup;

    Q_OBJECT
    Q_PROPERTY(bool authorised READ authorised NOTIFY authorisedChanged)
    Q_PROPERTY(bool cookieIsValid READ cookieIsValid NOTIFY cookieIsValidChanged)
    Q_PROPERTY(bool isPublisher READ isPublisher NOTIFY authorisedChanged)
    Q_PROPERTY(quint32 userId READ userId NOTIFY authorisedChanged)
    Q_PROPERTY(QString userName READ userName NOTIFY authorisedChanged)
    Q_PROPERTY(QString userIconSource READ userIconSource NOTIFY authorisedChanged)
    Q_PROPERTY(bool hideOldApps READ hideOldApps WRITE setHideOldApps NOTIFY hideOldAppsChanged)
    // The date as "yyyy-MM-dd": applications not updated since it are hidden when hideOldApps is set
    Q_PROPERTY(QString hideOldAppsBefore READ hideOldAppsBefore WRITE setHideOldAppsBefore NOTIFY hideOldAppsChanged)

public:

    enum Error
    {
        NetworkError,
        AuthorisationError,
        CommentSendError,
        CommentDeleteError,
    };
    Q_ENUM(Error)

    enum CommentAction
    {
        CommentAdded,
        CommentEdited,
        CommentDeleted,
    };
    Q_ENUM(CommentAction)

    static OrnClient *instance();
    static inline QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
    {
        Q_UNUSED(engine)
        Q_UNUSED(scriptEngine)

        return OrnClient::instance();
    }

    QNetworkRequest apiRequest(const QString &resource, const QUrlQuery &query = QUrlQuery()) const;
    QNetworkAccessManager *networkAccessManager() const;
    QJsonDocument processReply(QNetworkReply *reply, Error code = NetworkError);

    bool authorised() const;
    bool cookieIsValid() const;
    bool isPublisher() const;
    quint32 userId() const;
    QString userName() const;
    QString userIconSource();

    Q_INVOKABLE QList<quint32> bookmarks() const;
    Q_INVOKABLE bool hasBookmark(quint32 appId) const;
    Q_INVOKABLE bool addBookmark(quint32 appId);
    Q_INVOKABLE bool removeBookmark(quint32 appId);

    Q_INVOKABLE bool categoryVisible(quint32 categoryId) const;
    Q_INVOKABLE void setCategoryVisibility(quint32 categoryId, bool visible);
    Q_INVOKABLE void toggleCategoryVisibility(quint32 categoryId);

    bool hideOldApps() const;
    void setHideOldApps(bool hide);

    QString hideOldAppsBefore() const;
    void setHideOldAppsBefore(const QString &date);

    // Whether the application with the given date of the last update is hidden as old
    bool isOldApp(const QDateTime &updated) const;

public slots:
    void login(const QString &username, QString password, bool savePassword = false);
    void logout();

    void comment(quint32 appId, const QString &body, quint32 parentId = 0);
    void editComment(quint32 appId, quint32 commentId, const QString &body);
    void deleteComment(quint32 appId, quint32 commentId);

    void vote(quint32 appId, quint32 value);

signals:
    void error(OrnClient::Error code);
    void authorisedChanged();
    void dayToExpiry();
    void cookieIsValidChanged();
    void commentActionFinished(OrnClient::CommentAction action, quint32 appId, quint32 cid);
    void bookmarkChanged(quint32 appid, bool bookmarked);
    void categoryVisibilityChanged(quint32 categoryId, bool visible);
    void hideOldAppsChanged();
    void userVoteFinished(quint32 appId, quint32 userVote, quint32 count, float rating);

private:
    explicit OrnClient(QObject *parent = nullptr);

    Q_DECLARE_PRIVATE(OrnClient)
};
