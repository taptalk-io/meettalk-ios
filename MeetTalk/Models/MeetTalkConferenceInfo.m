//
//  MeetTalkConferenceInfo.m
//  MeetTalk
//
//  Created by Kevin on 3/17/22.
//

#import "MeetTalkConferenceInfo.h"
#import "MeetTalkConfigs.h"

@implementation MeetTalkConferenceInfo

+ (MeetTalkConferenceInfo * _Nullable)fromMessageModel:(TAPMessageModel *)message {
    @try {
        if (message.data != nil && [message.data objectForKey:CONFERENCE_MESSAGE_DATA] != nil) {
            NSMutableDictionary *conferenceInfoDictionary = [[message.data objectForKey:CONFERENCE_MESSAGE_DATA] mutableCopy];
            NSMutableArray *participantsDictionaryArray = [conferenceInfoDictionary objectForKey:@"participants"];
            NSMutableArray *participantsArray = [NSMutableArray array];
            if (participantsDictionaryArray != nil && participantsDictionaryArray.count > 0) {
                for (NSDictionary *participantsDictionary in participantsDictionaryArray) {
                    [participantsArray addObject:[[MeetTalkParticipantInfo alloc] initWithDictionary:participantsDictionary error:nil]];
                }
            }
            [conferenceInfoDictionary removeObjectForKey:@"participants"];
            [conferenceInfoDictionary setObject:participantsArray forKey:@"participants"];
            return [[MeetTalkConferenceInfo alloc] initWithDictionary:conferenceInfoDictionary error:nil];
        }
        return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (TAPMessageModel *)attachToMessage:(TAPMessageModel *)message {
    NSMutableDictionary *messageData;
    if (message.data != nil) {
        messageData = [message.data mutableCopy];
    }
    else {
        messageData = [NSMutableDictionary dictionary];
    }
    MeetTalkConferenceInfo *existingConferenceInfo = [MeetTalkConferenceInfo fromMessageModel:message];
    if (existingConferenceInfo != nil) {
        [existingConferenceInfo updateValue:self];
        [messageData setObject:existingConferenceInfo forKey:CONFERENCE_MESSAGE_DATA];
    }
    else {
        NSMutableDictionary *conferenceInfoDictionary = [[self toDictionary] mutableCopy];
        NSMutableArray *participantsDictionaryArray = [NSMutableArray array];
        for (MeetTalkParticipantInfo *participant in self.participants) {
            [participantsDictionaryArray addObject:[participant toDictionary]];
        }
        [conferenceInfoDictionary removeObjectForKey:@"participants"];
        [conferenceInfoDictionary setObject:participantsDictionaryArray forKey:@"participants"];
        [messageData setObject:conferenceInfoDictionary forKey:CONFERENCE_MESSAGE_DATA];
    }
    message.data = messageData;
    return message;
}

- (void)updateValue:(MeetTalkConferenceInfo *)updatedConferenceInfo {
    if (![updatedConferenceInfo.callID isEqual:@""]) {
        self.callID = updatedConferenceInfo.callID;
    }
    if (![updatedConferenceInfo.roomID isEqual:@""]) {
        self.roomID = updatedConferenceInfo.roomID;
    }
    if (![updatedConferenceInfo.hostUserID isEqual:@""]) {
        self.hostUserID = updatedConferenceInfo.hostUserID;
    }
    if (updatedConferenceInfo.callInitiatedTime.longValue > 0L) {
        self.callInitiatedTime = updatedConferenceInfo.callInitiatedTime;
    }
    if (updatedConferenceInfo.callStartedTime.longValue > 0L) {
        self.callStartedTime = updatedConferenceInfo.callStartedTime;
    }
    if (updatedConferenceInfo.callEndedTime.longValue > 0L) {
        self.callEndedTime = updatedConferenceInfo.callEndedTime;
    }
    if (updatedConferenceInfo.callDuration.longValue > 0L) {
        self.callDuration = updatedConferenceInfo.callDuration;
    }
    if (updatedConferenceInfo.lastUpdated.longValue > 0L) {
        self.lastUpdated = updatedConferenceInfo.lastUpdated;
    }
    if ([updatedConferenceInfo.participants count] > 0) {
        for (MeetTalkParticipantInfo *updatedParticipant in updatedConferenceInfo.participants) {
            [self updateParticipant:updatedParticipant];
        }
    }
}

- (void)updateParticipant:(MeetTalkParticipantInfo *)updatedParticipant {
    // TODO: VALUE NOT UPDATED?
    BOOL isExistingParticipant = NO;
    NSMutableArray<MeetTalkParticipantInfo *> *participantsCopy = [self.participants mutableCopy];
    for (MeetTalkParticipantInfo *participant in participantsCopy) {
        if ([participant.userID isEqualToString:updatedParticipant.userID]) {
            isExistingParticipant = YES;
            if (participant.lastUpdated.longValue <= updatedParticipant.lastUpdated.longValue) {
                [self.participants replaceObjectAtIndex:[participantsCopy indexOfObject:participant] withObject:updatedParticipant];
            }
            break;
        }
    }
    if (!isExistingParticipant) {
        [self.participants addObject:updatedParticipant];
    }
//    MeetTalkParticipantInfo *existingParticipant = [self.participants objectForKey:updatedParticipant.userID];
//    if (existingParticipant == nil ||
//        (existingParticipant != nil &&
//        existingParticipant.lastUpdated.longValue <= updatedParticipant.lastUpdated.longValue)
//    ) {
//        [self.participants setObject:updatedParticipant forKey:updatedParticipant.userID];
//    }
}

- (MeetTalkConferenceInfo *)copy {
    MeetTalkConferenceInfo *conferenceInfoCopy = [MeetTalkConferenceInfo new];
    conferenceInfoCopy.callID = self.callID;
    conferenceInfoCopy.roomID = self.roomID;
    conferenceInfoCopy.hostUserID = self.hostUserID;
    conferenceInfoCopy.callInitiatedTime = self.callInitiatedTime;
    conferenceInfoCopy.callStartedTime = self.callStartedTime;
    conferenceInfoCopy.callEndedTime = self.callEndedTime;
    conferenceInfoCopy.callDuration = self.callDuration;
    conferenceInfoCopy.lastUpdated = self.lastUpdated;
    conferenceInfoCopy.participants = self.participants;
    return conferenceInfoCopy;
}

@end
