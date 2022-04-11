//
//  MeetTalkConferenceInfo.h
//  MeetTalk
//
//  Created by Kevin on 3/17/22.
//

#import "JSONModel.h"
#import "MeetTalkParticipantInfo.h"
#import <TapTalk/TAPMessageModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeetTalkConferenceInfo : JSONModel

@property (nonatomic, strong) NSString *callID;
@property (nonatomic, strong) NSString *roomID;
@property (nonatomic, strong) NSString *hostUserID;
@property (nonatomic, strong) NSNumber *callInitiatedTime;
@property (nonatomic, strong) NSNumber *callStartedTime;
@property (nonatomic, strong) NSNumber *callEndedTime;
@property (nonatomic, strong) NSNumber *callDuration;
@property (nonatomic, strong) NSNumber *lastUpdated;
@property (nonatomic, strong) NSMutableArray<MeetTalkParticipantInfo *> *participants;

+ (MeetTalkConferenceInfo * _Nullable)fromMessageModel:(TAPMessageModel *)message;
- (TAPMessageModel *)attachToMessage:(TAPMessageModel *)message;
- (void)updateValue:(MeetTalkConferenceInfo *)updatedConferenceInfo;
- (void)updateParticipant:(MeetTalkParticipantInfo *)updatedParticipant;
- (MeetTalkConferenceInfo *)copy;

@end


NS_ASSUME_NONNULL_END
