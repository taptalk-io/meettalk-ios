//
//  MeetTalkCallManager.h
//  MeetTalk
//
//  Created by Kevin on 3/23/22.
//

#import "MeetTalkCallViewController.h"
#import "MeetTalkConferenceInfo.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <TapTalk/TapTalk.h>
#import <TapTalk/TAPMessageModel.h>
#import <TapTalk/TAPRoomModel.h>
#import <TapTalk/TAPUserModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MeetTalkCallState) {
    MeetTalkCallStateIdle = 0,
    MeetTalkCallStateInCall = 1,
    MeetTalkCallStateRinging = 2,
};

@protocol MeetTalkCallManagerDelegate <NSObject>

- (void)callDidAnswer;
- (void)callDidEnd;
- (void)callDidHold:(BOOL)isOnHold;
- (void)callDidFail;

@end

@interface MeetTalkCallManager : NSObject

@property (weak, nonatomic) id<MeetTalkCallManagerDelegate> delegate;
@property (strong, nonatomic) TAPMessageModel *activeCallMessage;
@property (strong, nonatomic) MeetTalkCallViewController *activeMeetTalkCallViewController;
@property (strong, nonatomic) MeetTalkConferenceInfo *activeConferenceInfo;
@property (strong, nonatomic) NSMutableArray<TAPMessageModel *> *pendingCallNotificationMessages;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *roomAliasDictionary;
@property (nonatomic) MeetTalkCallState callState;
@property (nonatomic) BOOL defaultAudioMuted;
@property (nonatomic) BOOL defaultVideoMuted;

+ (MeetTalkCallManager *)sharedManager;
- (void)initData;
- (void)showIncomingCallWithMessage:(TAPMessageModel *)message
                 displayPhoneNumber:(NSString *)displayPhoneNumber;
- (void)dismissIncomingCall;
- (void)answerIncomingCall;
- (void)rejectIncomingCall;
- (BOOL)checkAndRequestAudioPermission;
- (BOOL)checkAndRequestCameraPermission;
- (void)clearPendingIncomingCall;
- (void)rejectPendingIncomingConferenceCall;
- (BOOL)joinPendingIncomingConferenceCall;
- (void)initiateNewConferenceCallWithRoom:(TAPRoomModel *)room;
- (void)initiateNewConferenceCallWithRoom:(TAPRoomModel *)room
                     recipientDisplayName:(NSString *)recipientDisplayName;
- (BOOL)launchMeetTalkCallViewController;
- (BOOL)launchMeetTalkCallViewControllerWithRoom:(TAPRoomModel *)room
                                  activeUserName:(NSString *)activeUserName
                             activeUserAvatarUrl:(NSString *)activeUserAvatarUrl;
- (void)checkAndHandleCallNotificationFromMessage:(TAPMessageModel *)message activeUser:(TAPUserModel *)activeUser;
- (MeetTalkParticipantInfo *)generateParticipantInfoWithRole:(NSString *)role;
- (TAPMessageModel *)sendCallInitiatedNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendCallCanceledNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendCallEndedNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendAnsweredCallNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendJoinedCallNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendLeftCallNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendBusyNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendRejectedCallNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendMissedCallNotification:(TAPRoomModel *)room;
- (TAPMessageModel *)sendUnableToReceiveCallNotification:(NSString *)body room:(TAPRoomModel *)room;
- (TAPMessageModel *)sendConferenceInfoNotification:(TAPRoomModel *)room;
- (void)sendPendingCallNotificationMessages;
- (void)handleSendNotificationOnLeavingConference;
- (void)setActiveCallData:(TAPMessageModel *)message;
- (void)setActiveCallAsEnded;
- (void)handleAppExiting:(UIApplication *_Nonnull)application;

@end

NS_ASSUME_NONNULL_END
