//
//  MeetTalkCallViewController.m
//  MeetTalk
//
//  Created by Kevin on 3/4/22.
//

#import "MeetTalkCallViewController.h"
#import <TapTalk/TapTalk.h>
#import <TapTalk/TAPUserModel.h>

@import JitsiMeetSDK;

@interface MeetTalkCallViewController () <JitsiMeetViewDelegate>

@property (strong, nonatomic) IBOutlet JitsiMeetView *jitsiMeetView;
//@property (strong, nonatomic) JitsiMeetView *jitsiMeetView;

@end

@implementation MeetTalkCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    _jitsiMeetView = [[JitsiMeetView alloc] initWithFrame:self.view.frame];
//    [self.view addSubview:self.jitsiMeetView];
    self.jitsiMeetView.delegate = self;
}

- (void)conferenceWillJoin:(NSDictionary *)data {
    NSLog(@">>>>> About to join conference %@", self.roomID);
}

- (void)conferenceJoined:(NSDictionary *)data {
    NSLog(@">>>>> Conference %@ joined", self.roomID);
}

- (void)conferenceTerminated:(NSDictionary *)data {
    NSLog(@">>>>> Conference %@ terminated", self.roomID);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)joinConferenceTest:(NSString *)roomID {
    // Attach this controller as the delegate.
    //self.jitsiMeetView.delegate = self;
    
    // Join the room.
    TAPUserModel *activeUser = [[TapTalk sharedInstance] getTapTalkActiveUser];
    JitsiMeetUserInfo *userInfo = [JitsiMeetUserInfo new];
    if (activeUser.imageURL.fullsize != nil && ![activeUser.imageURL.fullsize isEqual:@""]) {
        userInfo.avatar = [NSURL URLWithString:activeUser.imageURL.fullsize];
    }
    if (activeUser.fullname != nil && ![activeUser.fullname isEqual:@""]) {
        userInfo.displayName = activeUser.fullname;
    }
    if (activeUser.email != nil && ![activeUser.email isEqual:@""]) {
        userInfo.email = activeUser.email;
    }
//    JitsiMeetConferenceOptions *options = [JitsiMeet sharedInstance].defaultConferenceOptions;
//    options.room = [NSString stringWithFormat:@"meettalktest%@", self.roomID];
//    options.userInfo = userInfo;
    
    JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
        builder.room = roomID;
        builder.userInfo = userInfo;
    }];
    [self.jitsiMeetView join:options];
}

@end
