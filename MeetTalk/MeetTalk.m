//
//  MeetTalk.m
//  MeetTalk
//
//  Created by Kevin on 3/2/22.
//

#import <Foundation/Foundation.h>
#import "MeetTalk.h"
#import <TapTalk/TapTalk.h>
#import "MeetTalkCallViewController.h"
#import "MeetTalkConfigs.h"
#import "PodAsset.h"

@import JitsiMeetSDK;

@interface MeetTalk ()

@end

static NSString *appID = @"";

@implementation MeetTalk

+ (void)initializeTest {
    // Initialize default options for joining conferences.
    JitsiMeetConferenceOptions *defaultOptions
        = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
//            builder.serverURL = [NSURL URLWithString:@"https://meet.taptalk.io/"];
            builder.serverURL = [NSURL URLWithString:@"https://meet.jit.si"];
//            builder.welcomePageEnabled = NO;
#ifdef DEBUG
            builder.audioMuted = YES;
#endif
            builder.videoMuted = YES;
            [builder setFeatureFlag:ADD_PEOPLE_ENABLED withBoolean:NO];
//            [builder setFeatureFlag:AUDIO_MUTE_BUTTON_ENABLED withBoolean:NO];
            [builder setFeatureFlag:CALL_INTEGRATION_ENABLED withBoolean:NO];
            [builder setFeatureFlag:CHAT_ENABLED withBoolean:NO];
            [builder setFeatureFlag:HELP_BUTTON_ENABLED withBoolean:NO];
            [builder setFeatureFlag:INVITE_ENABLED withBoolean:NO];
            [builder setFeatureFlag:KICK_OUT_ENABLED withBoolean:NO];
            [builder setFeatureFlag:LOBBY_MODE_ENABLED withBoolean:NO];
            [builder setFeatureFlag:MEETING_NAME_ENABLED withBoolean:NO];
            [builder setFeatureFlag:MEETING_PASSWORD_ENABLED withBoolean:NO];
            [builder setFeatureFlag:NOTIFICATIONS_ENABLED withBoolean:NO];
            [builder setFeatureFlag:OVERFLOW_MENU_ENABLED withBoolean:NO];
            [builder setFeatureFlag:RAISE_HAND_ENABLED withBoolean:NO];
            [builder setFeatureFlag:REACTIONS_ENABLED withBoolean:NO];
            [builder setFeatureFlag:RECORDING_ENABLED withBoolean:NO];
            [builder setFeatureFlag:SECURITY_OPTIONS_ENABLED withBoolean:NO];
            [builder setFeatureFlag:TILE_VIEW_ENABLED withBoolean:NO];
//            [builder setFeatureFlag:TOOLBOX_ENABLED withBoolean:NO];
//            [builder setFeatureFlag:VIDEO_MUTE_BUTTON_ENABLED withBoolean:NO];
            [builder setFeatureFlag:VIDEO_SHARE_BUTTON_ENABLED withBoolean:NO];
            
//            NSInteger red = 255;
//            NSInteger green = 126;
//            NSInteger blue = 0;
//            NSString *rgbString = [NSString stringWithFormat:@"rgb(%ld, %ld, %ld)", (long)red, (long)green, (long)blue];
//            NSString *rgbaString = [NSString stringWithFormat:@"rgba(%ld, %ld, %ld, 0.3)", (long)red, (long)green, (long)blue];
//
//            NSInteger redSecond = 144;
//            NSInteger greenSecond = 77;
//            NSInteger blueSecond = 12;
//            NSString *rgbStringSecond = [NSString stringWithFormat:@"rgb(%ld, %ld, %ld)", (long)redSecond, (long)greenSecond, (long)blueSecond];
//
//            NSInteger redThird = 71;
//            NSInteger greenThird = 45;
//            NSInteger blueThird = 20;
//            NSString *rgbStringThird = [NSString stringWithFormat:@"rgb(%ld, %ld, %ld)", (long)redThird, (long)greenThird, (long)blueThird];
//
//            NSMutableDictionary *dialogDictionary = [[NSMutableDictionary alloc] init];
//            [dialogDictionary setObject:rgbString forKey:@"buttonBackground"];
//
//            NSMutableDictionary *conferenceDictionary = [[NSMutableDictionary alloc] init];
//            [conferenceDictionary setObject:rgbString forKey:@"inviteButtonBackground"];
//
//            NSMutableDictionary *headerColorDictionary = [[NSMutableDictionary alloc] init];
//            [headerColorDictionary setObject:rgbString forKey:@"statusBar"];
//            [headerColorDictionary setObject:rgbString forKey:@"background"];
//
//            NSMutableDictionary *chatDictionary = [[NSMutableDictionary alloc] init];
//            [chatDictionary setObject:rgbaString forKey:@"localMsgBackground"];
//
//            NSMutableDictionary *largeVideoDictionary = [[NSMutableDictionary alloc] init];
//            [largeVideoDictionary setObject:rgbStringThird forKey:@"background"];
//
//            NSMutableDictionary *thumbnailDictionary = [[NSMutableDictionary alloc] init];
//            [thumbnailDictionary setObject:rgbString forKey:@"activeParticipantHighlight"];
//            [thumbnailDictionary setObject:rgbaString forKey:@"background"];
//            [thumbnailDictionary setObject:rgbStringSecond forKey:@"activeParticipantTint"];
//
//            NSMutableDictionary *totalColorSchemeDictionary = [[NSMutableDictionary alloc] init];
//            [totalColorSchemeDictionary setObject:dialogDictionary forKey:@"Dialog"];
//            [totalColorSchemeDictionary setObject:conferenceDictionary forKey:@"Conference"];
//            [totalColorSchemeDictionary setObject:headerColorDictionary forKey:@"Header"];
//            [totalColorSchemeDictionary setObject:chatDictionary forKey:@"Chat"];
//            [totalColorSchemeDictionary setObject:largeVideoDictionary forKey:@"LargeVideo"];
//            [totalColorSchemeDictionary setObject:thumbnailDictionary forKey:@"Thumbnail"];
//            builder.colorScheme = [totalColorSchemeDictionary copy];
            
        }];
    
    [JitsiMeet sharedInstance].defaultConferenceOptions = defaultOptions;
}

+ (void)launchCallActivityTest:(UINavigationController *)navigationController roomID:(NSString *)roomID {
    NSString *conferenceRoomID = [NSString stringWithFormat:@"%@%@%@", MEET_ROOM_ID_PREFIX, @"d1e5dfe23d1e00bf54bc2316f", roomID]; // Change App Key ID
    MeetTalkCallViewController *callViewController = [[MeetTalkCallViewController alloc] initWithNibName:@"MeetTalkCallViewController" bundle:[PodAsset bundleForPod:@"MeetTalk"]];
//    MeetTalkCallViewController *callViewController = [[MeetTalkCallViewController alloc] init];
    callViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    callViewController.roomID = roomID;
    [navigationController presentViewController:callViewController animated:YES completion:^{
            [callViewController joinConferenceTest];
    }];
}

@end
