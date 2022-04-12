//
//  MeetTalk.h
//  MeetTalk
//
//  Created by Kevin on 3/1/22.
//

// In this header, you should import all the public headers of your framework using statements like #import <MeetTalk/PublicHeader.h>

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <TapTalk/TapTalk.h>
#import <TapTalk/TapUI.h>
#import <TapTalk/TAPMessageModel.h>
#import "MeetTalkCallViewController.h"
#import "MeetTalkCallChatBubbleTableViewCell.h"
#import "MeetTalkConfigs.h"
#import "MeetTalkConferenceInfo.h"

//! Project version number for MeetTalk.
FOUNDATION_EXPORT double MeetTalkVersionNumber;

//! Project version string for MeetTalk.
FOUNDATION_EXPORT const unsigned char MeetTalkVersionString[];


@protocol MeetTalkDelegate <NSObject>
@optional

#pragma mark TapTalkDelegate callbacks

- (void)tapTalkRefreshTokenExpired;

//Badge
/**
Called when the number of unread messages in the application is updated. Returns the number of unread messages from the application.
*/
- (void)tapTalkUnreadChatRoomBadgeCountUpdated:(NSInteger)numberOfUnreadRooms;

//Notification
/**
Called when TapTalk.io needs to request for push notification, usually client needs to add [[UIApplication sharedApplication] registerForRemoteNotifications] inside the method.
*/
- (void)tapTalkDidRequestRemoteNotification;

/**
Called when user tapped the notification
*/
- (void)tapTalkDidTappedNotificationWithMessage:(TAPMessageModel *_Nonnull)message fromActiveController:(nullable UIViewController *)currentActiveController;

//Logout
- (void)userLogout;

#pragma mark Call/conference notification callbacks
- (void)meetTalkDidReceiveCallInitiatedNotificationMessage:(TAPMessageModel *_Nonnull)message
                                            conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveCallCancelledNotificationMessage:(TAPMessageModel *_Nonnull)message
                                            conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveCallEndedNotificationMessage:(TAPMessageModel *_Nonnull)message
                                        conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveRecipientAnsweredCallNotificationMessage:(TAPMessageModel *_Nonnull)message
                                                    conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveRecipientBusyNotificationMessage:(TAPMessageModel *_Nonnull)message
                                            conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveRecipientRejectedCallNotificationMessage:(TAPMessageModel *_Nonnull)message
                                                    conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveRecipientMissedCallNotificationMessage:(TAPMessageModel *_Nonnull)message
                                                  conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveRecipientUnableToReceiveCallNotificationMessage:(TAPMessageModel *_Nonnull)message
                                                           conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveActiveUserRejectedCallNotificationMessage:(TAPMessageModel *_Nonnull)message
                                                     conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveParticipantJoinedConferenceNotificationMessage:(TAPMessageModel *_Nonnull)message
                                                          conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveParticipantLeftConferenceNotificationMessage:(TAPMessageModel *_Nonnull)message
                                                        conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReceiveConferenceInfoUpdatedNotificationMessage:(TAPMessageModel *_Nonnull)message
                                                    conferenceInfo:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;

#pragma mark Incoming call callbacks
- (void)meetTalkDidReceiveIncomingCall:(TAPMessageModel *_Nonnull)message;
- (void)meetTalkShowIncomingCallFailed:(TAPMessageModel *_Nonnull)message errorMessage:(NSString *)errorMessage;
- (void)meetTalkDidAnswerIncomingCall;
- (void)meetTalkDidRejectIncomingCall;
- (void)meetTalkIncomingCallDisconnected;

#pragma mark Conference callbacks
- (void)meetTalkDidDisconnectFromConference:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidReconnectToConference:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkDidJoinConference:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;
- (void)meetTalkConferenceTerminated:(MeetTalkConferenceInfo *_Nullable)conferenceInfo;

#pragma mark UI callbacks
- (void)meetTalkChatBubbleCallButtonDidTapped:(TAPMessageModel *_Nonnull)message;

@end

@interface MeetTalk : NSObject

@property (weak, nonatomic) id<MeetTalkDelegate> _Nullable delegate;
//@property (strong, nonatomic) NSString *appID;

#pragma mark Initialization
+ (MeetTalk *_Nonnull)sharedInstance;
+ (NSBundle *_Nullable)bundle;
- (void)initWithAppKeyID:(NSString *_Nonnull)appKeyID
            appKeySecret:(NSString *_Nonnull)appKeySecret
            apiURLString:(NSString *_Nonnull)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType;
- (void)initWithAppKeyID:(NSString *_Nonnull)appKeyID
            appKeySecret:(NSString *_Nonnull)appKeySecret
            apiURLString:(NSString *_Nonnull)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType
                 success:(void (^_Nullable)(void))success;

#pragma mark - AppDelegate Handling
- (void)application:(UIApplication *_Nonnull)application didFinishLaunchingWithOptions:(NSDictionary *_Nonnull)launchOptions;
- (void)applicationWillResignActive:(UIApplication *_Nonnull)application;
- (void)applicationDidEnterBackground:(UIApplication *_Nonnull)application;
- (void)applicationWillEnterForeground:(UIApplication *_Nonnull)application;
- (void)applicationDidBecomeActive:(UIApplication *_Nonnull)application;
- (void)applicationWillTerminate:(UIApplication *_Nonnull)application;
- (void)application:(UIApplication *_Nonnull)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *_Nonnull)deviceToken;
- (void)application:(UIApplication *_Nonnull)application didReceiveRemoteNotification:(NSDictionary *_Nonnull)userInfo fetchCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult result))completionHandler;

#pragma mark - Incoming Call
- (void)showIncomingCallWithMessage:(TAPMessageModel *)message;
- (void)showIncomingCallWithMessage:(TAPMessageModel *)message phoneNumber:(NSString *)phoneNumber;

#pragma mark - Conference Call
- (void)initiateNewConferenceCallWithRoom:(TAPRoomModel *)room;
- (void)initiateNewConferenceCallWithRoom:(TAPRoomModel *)room
                     recipientDisplayName:(NSString *)recipientDisplayName;
- (BOOL)joinPendingIncomingConferenceCall;
- (BOOL)launchMeetTalkCallViewController;
- (BOOL)launchMeetTalkCallViewControllerWithRoom:(TAPRoomModel *)room
                                  activeUserName:(NSString *)activeUserName
                             activeUserAvatarUrl:(NSString *)activeUserAvatarUrl;

#pragma mark - Permission
- (BOOL)checkAndRequestAudioPermission;
- (BOOL)checkAndRequestCameraPermission;

@end
