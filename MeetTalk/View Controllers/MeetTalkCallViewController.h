//
//  MeetTalkCallViewController.h
//  MeetTalk
//
//  Created by Kevin on 3/4/22.
//

#import <UIKit/UIKit.h>
#import <TapTalk/TAPRoomModel.h>
#import "MeetTalkConferenceInfo.h"

@import JitsiMeetSDK;

NS_ASSUME_NONNULL_BEGIN

@interface MeetTalkCallViewController : UIViewController

@property (nonatomic) BOOL isCallStarted;

- (void)setDataWithConferenceOptions:(JitsiMeetConferenceOptions *)conferenceOptions
                      activeCallRoom:(TAPRoomModel *)activeCallRoom
                activeConferenceInfo:(MeetTalkConferenceInfo *)activeConferenceInfo;
- (void)conferenceInfoUpdated:(MeetTalkConferenceInfo *)updatedConferenceInfo;
- (void)retrieveParticipantInfo;
- (void)dismiss;

// Redirect Connection Manager delegates from MeetTalkCallManager
- (void)connectionManagerDidConnected;
- (void)connectionManagerDidDisconnectedWithCode:(NSInteger)code reason:(NSString *)reason cleanClose:(BOOL)clean;
- (void)connectionManagerIsConnecting;
- (void)connectionManagerIsReconnecting;
- (void)connectionManagerDidReceiveError:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
