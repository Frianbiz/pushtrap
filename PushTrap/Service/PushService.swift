import UIKit
import Foundation
import OneSignal
import PromiseKit

class PushService {
    
    fileprivate static let isOneSignalAvailable = !Constantes.onesignalAppId.isEmpty
    
    // MARK: - Setup
    
    class func setup(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        OneSignal.setLocationShared(false)
        self.registerRequestNotification()
        OneSignal.initWithLaunchOptions(
            launchOptions,
            appId: Constantes.onesignalAppId,
            handleNotificationReceived: { osNotification in
                if let notification = osNotification,
                    let _ = notification.payload.additionalData {
                    
                }
        },
            handleNotificationAction: { result in
                if let result = result,
                    let notification = result.notification {
                    self.notificationReceived(notification, from: "handleNotificationAction")
                }
        },
            settings: [
                kOSSettingsKeyAutoPrompt: false,
                kOSSettingsKeyInAppAlerts: true,
                kOSSettingsKeyInFocusDisplayOption: OSNotificationDisplayType.notification.rawValue,
                kOSSettingsKeyInAppLaunchURL: true
            ])
    }
    
    class func notificationReceived(_ notification: OSNotification, from: String) {
        if let _: String = notification.payload.category {
            if let additionalData = notification.payload.additionalData {
                print(additionalData)
            }
        }
    }
    
    class func readerResponceReceveid(additionalData: [AnyHashable: Any]) {
        print(additionalData)
    }
    
    class func transmitterRequestReceveid(additionalData: [AnyHashable: Any]) {
        print(additionalData)
    }
    
    class func registerRequestNotification() {
        
        let displayAction = UNNotificationAction(identifier: "DISPLAY_ACTION",
                                                 title: "Afficher",
                                                 options: .authenticationRequired)
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION",
                                                title: "Accepter",
                                                options: .authenticationRequired)
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Refusser",
                                                 options: .destructive)
        let meetingInviteCategory =
            UNNotificationCategory(identifier: "REQUEST_ACCESS",
                                   actions: [displayAction, acceptAction, declineAction],
                                   intentIdentifiers: [],
                                   options: .allowInCarPlay)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCategory])
    }
    
    class func registerUser(tags: [Tag] = []) -> Promise<Void> {
        return Promise<Void> { seal in
            guard PushService.isOneSignalAvailable else { return seal.resolve(nil) }
            
            OneSignal.promptForPushNotifications { (_) in }
            
            OneSignal.getTags { (oldTags) in
                oldTags?.forEach({ (key: AnyHashable, value: Any) in
                    if let keyTag = key as? String {
                        OneSignal.deleteTag(keyTag)
                    }
                })
                PushService.sendNewTags(tags: tags)
                seal.resolve(nil)
            }
        }
    }
    
    class func sendNewTags(tags: [Tag] = []) {
        tags.forEach { (tag) in
            OneSignal.sendTag(tag.key, value: tag.value)
        }
    }
    
    class func getCurrentTags() -> Promise<[Tag]> {
        return Promise<[Tag]> { seal in
            var result: [Tag] = []
            OneSignal.getTags { (oldTags) in
                oldTags?.forEach({ (key: AnyHashable, value: Any) in
                    if let keyTag = key as? String, let valueTag = value as? String {
                        result.append(Tag(vKey: keyTag, vValue: valueTag))
                    }
                })
                seal.fulfill(result)
            }
        }
    }
    
    class func removeUser(idUser: String? = nil) {
        guard PushService.isOneSignalAvailable else { return }
        if let idUser = idUser {
            OneSignal.deleteTag(idUser)
        }
    }
    
    // MARK: - Helpers
    
    static func canSubscriptionBeEnabled() -> Bool {
        return
            PushService.isOneSignalAvailable &&
                OneSignal.getPermissionSubscriptionState().permissionStatus.status == .authorized
    }
}
