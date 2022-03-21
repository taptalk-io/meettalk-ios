//
//  MeetTalkParticipantInfo.h
//  MeetTalk
//
//  Created by Kevin on 3/17/22.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MeetTalkParticipantInfo : JSONModel

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *participantID;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSNumber *leaveTime;
@property (nonatomic, strong) NSNumber *lastUpdated;
@property (nonatomic) BOOL *isAudioMuted;
@property (nonatomic) BOOL *isVideoMuted;

@end

NS_ASSUME_NONNULL_END
