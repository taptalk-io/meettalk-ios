//
//  MeetTalkCallViewController.m
//  MeetTalk
//
//  Created by Kevin on 3/4/22.
//

#import "MeetTalk.h"
#import "MeetTalkCallViewController.h"
#import "MeetTalkCallManager.h"
#import "MeetTalkStyleManager.h"
#import "MeetTalkConfigs.h"
#import "MeetTalkConferenceInfo.h"
#import "MeetTalkParticipantInfo.h"
#import <TapTalk/TapTalk.h>
#import <TapTalk/TAPStyleManager.h>
#import <TapTalk/TAPConnectionManager.h>
#import <TapTalk/TAPCoreMessageManager.h>
#import <TapTalk/TAPUserModel.h>
#import <TapTalk/TAPImageView.h>
#import <TapTalk/TAPUtil.h>

@interface MeetTalkCallViewController () <JitsiMeetViewDelegate>

@property (strong, nonatomic) IBOutlet JitsiMeetView *meetTalkCallView;
@property (strong, nonatomic) IBOutlet TAPImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *roomDisplayNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *callDurationStatusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *toggleVideoMuteIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *toggleAudioMuteIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *hangUpIconImageView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *backgroundOverlayGradientView;
@property (strong, nonatomic) IBOutlet UIView *backgroundOverlaySolidView;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *innerButtonContainerView;
@property (strong, nonatomic) IBOutlet UIView *toggleVideoMuteButtonContainerView;
@property (strong, nonatomic) IBOutlet UIView *toggleAudioMuteButtonContainerView;
@property (strong, nonatomic) IBOutlet UIView *hangUpButtonContainerView;
@property (strong, nonatomic) IBOutlet UIButton *toggleVideoMuteButton;
@property (strong, nonatomic) IBOutlet UIButton *toggleAudioMuteButton;
@property (strong, nonatomic) IBOutlet UIButton *hangUpButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelContainerViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *innerButtonContainerViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toggleVideoMuteButtonContainerViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *toggleAudioMuteButtonContainerViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hangUpButtonContainerViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hangUpButtonContainerViewTrailingConstraint;

@property (strong, nonatomic) JitsiMeetConferenceOptions *options;
@property (strong, nonatomic) TAPRoomModel *activeCallRoom;
@property (strong, nonatomic) MeetTalkConferenceInfo *activeConferenceInfo;
@property (strong, nonatomic) MeetTalkParticipantInfo *activeParticipantInfo;
@property (strong, nonatomic) NSString *activeUserID;
@property (strong, nonatomic) NSString *roomDisplayName;
@property (strong, nonatomic) NSTimer *durationTimer;

@property (nonatomic) BOOL isAudioMuted;
@property (nonatomic) BOOL isVideoMuted;
@property (nonatomic) long callStartTimestamp;

@end

@implementation MeetTalkCallViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MeetTalkCallManager sharedManager].activeMeetTalkCallViewController = self;
    
    [self initData];
    [self initView];
    [self joinConference];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkIfCallIsEnded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.isVideoMuted) {
        [self toggleVideoMuteButtonDidTapped];
    }
}

#pragma mark - Delegates

#pragma mark - JitsiMeetViewDelegate

- (void)conferenceWillJoin:(NSDictionary *)data {
#ifdef DEBUG
    NSLog(@">>>>> MeetTalkCallViewController About to join conference %@", self.activeCallRoom.roomID);
#endif
}

- (void)conferenceJoined:(NSDictionary *)data {
#ifdef DEBUG
    NSLog(@">>>>> MeetTalkCallViewController Conference %@ joined", self.activeCallRoom.roomID);
#endif
    
    [self enableButtons];
    [self updateLayoutWithAnimation:YES];
    //[self retrieveParticipantInfo];
    if (self.activeCallRoom.type == RoomTypePersonal) {
        // Joined an existing call, send participant joined notification
        [[MeetTalkCallManager sharedManager] sendJoinedCallNotification:self.activeCallRoom];
        
        // Set status text to Waiting for User
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.isCallStarted) {
                self.callDurationStatusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Waiting for %@...", @""), [[self.roomDisplayName componentsSeparatedByString:@" "] objectAtIndex:0]];
            }
        });
    }
    
    // Trigger delegate callback
    if ([MeetTalk sharedInstance].delegate &&
        [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidJoinConference:)]
    ) {
        [[MeetTalk sharedInstance].delegate meetTalkDidJoinConference:[MeetTalkCallManager sharedManager].activeConferenceInfo];
    }
}

- (void)conferenceTerminated:(NSDictionary *)data {
#ifdef DEBUG
    NSLog(@">>>>> MeetTalkCallViewController Conference %@ terminated", self.activeCallRoom.roomID);
#endif
    // Trigger delegate callback
    if ([MeetTalk sharedInstance].delegate &&
        [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkConferenceTerminated:)]
    ) {
        [[MeetTalk sharedInstance].delegate meetTalkConferenceTerminated:[MeetTalkCallManager sharedManager].activeConferenceInfo];
    }
}

- (void)participantJoined:(NSDictionary *)data {
    
}

- (void)participantLeft:(NSDictionary *)data {
#ifdef DEBUG
    NSLog(@">>>>> MeetTalkCallViewController participantLeft");
#endif
    if (self.activeCallRoom.type == RoomTypePersonal) {
        // The other user left, terminate the call
        [self dismiss];
    }
}

#pragma mark - TAPConnectionManagerDelegate

- (void)connectionManagerDidConnected {
    [self fetchNewerMessages];
    
    // TODO: CHECK IF JOINED CALL NOTIFICATION IS ALREADY SENT
    
    // Trigger delegate callback
    if ([MeetTalk sharedInstance].delegate &&
        [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReconnectToConference:)]
    ) {
        [[MeetTalk sharedInstance].delegate meetTalkDidReconnectToConference:[MeetTalkCallManager sharedManager].activeConferenceInfo];
    }
}

- (void)connectionManagerDidDisconnectedWithCode:(NSInteger)code reason:(NSString *)reason cleanClose:(BOOL)clean {
    [self showVoiceCallLayoutWithAnimation:YES];
    [self stopCallDurationTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callDurationStatusLabel.text = NSLocalizedString(@"Disconnected from call", @"");
    });
    
    // Trigger delegate callback
    if ([MeetTalk sharedInstance].delegate &&
        [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidDisconnectFromConference:)]
    ) {
        [[MeetTalk sharedInstance].delegate meetTalkDidDisconnectFromConference:[MeetTalkCallManager sharedManager].activeConferenceInfo];
    }
}

- (void)connectionManagerIsConnecting {
    [self showVoiceCallLayoutWithAnimation:YES];
    [self stopCallDurationTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callDurationStatusLabel.text = NSLocalizedString(@"Connecting...", @"");
    });
}

- (void)connectionManagerIsReconnecting {
    
}

- (void)connectionManagerDidReceiveError:(NSError *)error {
    [self connectionManagerDidDisconnectedWithCode:error.code reason:error.localizedDescription cleanClose:YES];
}

#pragma mark - Custom Methods

- (void)initData {
    self.meetTalkCallView.delegate = self;
    _activeUserID = [[TapTalk sharedInstance] getTapTalkActiveUser].userID;
    
    [[TapTalk sharedInstance] connectWithSuccess:^{
    } failure:^(NSError * _Nonnull error) {
    }];
    
    NSString *alias = [[MeetTalkCallManager sharedManager].roomAliasDictionary objectForKey:self.activeCallRoom.roomID];
    if (alias != nil && ![alias isEqual:@""]) {
        _roomDisplayName = alias;
    }
    else {
        _roomDisplayName = self.activeCallRoom.name;
    }
    
    if ([MeetTalkCallManager sharedManager].activeConferenceInfo != nil) {
        for (MeetTalkParticipantInfo *participant in [MeetTalkCallManager sharedManager].activeConferenceInfo.participants) {
            if ([participant.userID isEqualToString:self.activeUserID]) {
                _activeParticipantInfo = participant;
                break;
            }
        }
    }
    if (self.activeParticipantInfo == nil) {
        _activeParticipantInfo = [[MeetTalkCallManager sharedManager] generateParticipantInfoWithRole:PARTICIPANT
                                                                                  startWithAudioMuted:[MeetTalkCallManager sharedManager].defaultAudioMuted
                                                                                  startWithVideoMuted:[MeetTalkCallManager sharedManager].defaultVideoMuted];
    }
    if ([MeetTalkCallManager sharedManager].activeConferenceInfo != nil) {
        _isAudioMuted = [MeetTalkCallManager sharedManager].activeConferenceInfo.startWithAudioMuted;
        _isVideoMuted = [MeetTalkCallManager sharedManager].activeConferenceInfo.startWithVideoMuted;
    }
    else {
        _isAudioMuted = [MeetTalkCallManager sharedManager].defaultAudioMuted;
        _isVideoMuted = [MeetTalkCallManager sharedManager].defaultVideoMuted;
    }
}

- (void)initView {
    dispatch_async(dispatch_get_main_queue(), ^{
        CAGradientLayer *backgroundViewGradient = [CAGradientLayer layer];
        backgroundViewGradient.frame = self.backgroundView.bounds;
        backgroundViewGradient.colors = [NSArray arrayWithObjects:(id)
            [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimaryLight].CGColor,
            [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary].CGColor,
            nil];
        backgroundViewGradient.startPoint = CGPointMake(0.0f, 0.0f);
        backgroundViewGradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.backgroundView.layer insertSublayer:backgroundViewGradient atIndex:0];
        
        CAGradientLayer *backgroundOverlayGradient = [CAGradientLayer layer];
        backgroundOverlayGradient.frame = self.backgroundView.bounds;
        backgroundOverlayGradient.colors = [NSArray arrayWithObjects:(id)
            [TAPUtil getColor:@"04040f"].CGColor,
            [[TAPUtil getColor:@"04040f"] colorWithAlphaComponent:0.0f].CGColor,
            nil];
        backgroundOverlayGradient.startPoint = CGPointMake(0.0f, 0.0f);
        backgroundOverlayGradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.backgroundOverlayGradientView.layer insertSublayer:backgroundOverlayGradient atIndex:0];
        
        self.roomDisplayNameLabel.textColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkCallScreenTitleLabelComponentColor];
        self.roomDisplayNameLabel.font = [[MeetTalkStyleManager sharedManager] getComponentFontForType:MeetTalkCallScreenTitleLabelComponentFont];
        self.callDurationStatusLabel.textColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkCallScreenDurationStatusLabelComponentColor];
        self.callDurationStatusLabel.font = [[MeetTalkStyleManager sharedManager] getComponentFontForType:MeetTalkCallScreenDurationStatusLabelComponentFont];
        
        self.toggleVideoMuteButtonContainerView.layer.cornerRadius = CGRectGetHeight(self.toggleVideoMuteButtonContainerView.frame) / 2.0f;
        self.toggleVideoMuteButtonContainerView.clipsToBounds = YES;
        self.toggleAudioMuteButtonContainerView.layer.cornerRadius = CGRectGetHeight(self.toggleAudioMuteButtonContainerView.frame) / 2.0f;
        self.toggleAudioMuteButtonContainerView.clipsToBounds = YES;
        self.hangUpButtonContainerView.layer.cornerRadius = CGRectGetHeight(self.hangUpButtonContainerView.frame) / 2.0f;
        self.hangUpButtonContainerView.clipsToBounds = YES;
        
        // Fix button gaps
        CGFloat buttonGapWidth = (CGRectGetWidth([UIScreen mainScreen].bounds) - (CGRectGetWidth(self.hangUpButton.frame) * 3)) / 4; // 3 buttons, 3 + 1 gaps
        self.hangUpButtonContainerViewTrailingConstraint.constant = buttonGapWidth;
        self.hangUpButtonContainerViewLeadingConstraint.constant = buttonGapWidth;
        self.toggleAudioMuteButtonContainerViewLeadingConstraint.constant = buttonGapWidth;
        self.toggleVideoMuteButtonContainerViewLeadingConstraint.constant = buttonGapWidth;
        
        self.roomDisplayNameLabel.text = self.roomDisplayName;
        
        [self loadRoomPicture];
        
        self.toggleAudioMuteButtonContainerView.alpha = 0.5f;
        self.toggleVideoMuteButtonContainerView.alpha = 0.5f;
        [self showAudioButtonMuted:self.isAudioMuted];
        [self showVideoButtonMuted:self.isVideoMuted];
        
        [self.hangUpButton addTarget:self
                              action:@selector(hangUpButtonDidTapped)
                    forControlEvents:UIControlEventTouchUpInside];
    });
}

- (void)joinConference {
    if (self.options == nil) {
        return;
    }
    [self.meetTalkCallView join:self.options];
}

- (void)loadRoomPicture {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self.activeCallRoom.imageURL.fullsize isEqual:@""]) {
            [self.profilePictureImageView setImageWithURLString:self.activeCallRoom.imageURL.fullsize];
            self.profilePictureImageView.alpha = 1.0f;
        }
        else {
            self.profilePictureImageView.alpha = 0.0f;
        }
    });
}

- (void)enableButtons {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.toggleAudioMuteButton addTarget:self
                                       action:@selector(toggleAudioMuteButtonDidTapped)
                             forControlEvents:UIControlEventTouchUpInside];
        [self.toggleVideoMuteButton addTarget:self
                                       action:@selector(toggleVideoMuteButtonDidTapped)
                             forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:0.2f animations:^{
            self.toggleAudioMuteButtonContainerView.alpha = 1.0f;
            self.toggleVideoMuteButtonContainerView.alpha = 1.0f;
        }];
    });
}

- (void)updateLayoutWithAnimation:(BOOL)animated {
    if ([MeetTalkCallManager sharedManager].activeConferenceInfo == nil) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (MeetTalkParticipantInfo *participant in [MeetTalkCallManager sharedManager].activeConferenceInfo.participants) {
            if (!participant.isVideoMuted) {
                [self showVideoCallLayoutWithAnimation:animated];
                return;
            }
        }
        [self showVoiceCallLayoutWithAnimation:animated];
    });
}

- (void)showVoiceCallLayoutWithAnimation:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.meetTalkCallView.alpha == 0.0f) {
            return;
        }
        CGFloat duration = 0.0f;
        if (animated) {
            duration = 0.2f;
        }
        [UIView animateWithDuration:0.2f animations:^{
            self.meetTalkCallView.alpha = 0.0f;
            self.buttonContainerBackgroundView.alpha = 0.0f;
            self.backgroundOverlaySolidView.alpha = 0.2f;
            self.labelContainerView.alpha = 1.0f;
            self.labelContainerViewTopConstraint.constant = 80.0f;
            self.innerButtonContainerViewBottomConstraint.constant = 80.0f;
            [self.view layoutIfNeeded];
        }];
    });
}

- (void)showVideoCallLayoutWithAnimation:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.meetTalkCallView.alpha == 1.0f) {
            return;
        }
        CGFloat duration = 0.0f;
        if (animated) {
            duration = 0.2f;
        }
        [UIView animateWithDuration:0.2f animations:^{
            self.meetTalkCallView.alpha = 1.0f;
            self.buttonContainerBackgroundView.alpha = 1.0f;
            self.backgroundOverlaySolidView.alpha = 0.0f;
            self.labelContainerView.alpha = 0.0f;
            self.labelContainerViewTopConstraint.constant = 24.0f;
            self.innerButtonContainerViewBottomConstraint.constant = 24.0f;
            [self.view layoutIfNeeded];
        }];
    });
}

- (void)updateActiveParticipantInConferenceInfo {
    if ([MeetTalkCallManager sharedManager].activeConferenceInfo == nil) {
        return;
    }
    for (MeetTalkParticipantInfo *participant in [MeetTalkCallManager sharedManager].activeConferenceInfo.participants) {
        if ([participant.userID isEqualToString:self.activeUserID]) {
            [[MeetTalkCallManager sharedManager].activeConferenceInfo.participants
             replaceObjectAtIndex:[[MeetTalkCallManager sharedManager].activeConferenceInfo.participants indexOfObject:participant]
             withObject:self.activeParticipantInfo];
            break;
        }
    }
}

- (void)toggleAudioMuteButtonDidTapped {
    if (![[MeetTalkCallManager sharedManager] checkAndRequestAudioPermission]) {
        return;
    }
    self.isAudioMuted = !self.isAudioMuted;
    [self showAudioButtonMuted:self.isAudioMuted];
    [self.meetTalkCallView setAudioMuted:self.isAudioMuted];
    self.activeParticipantInfo.isAudioMuted = self.isAudioMuted;
    self.activeParticipantInfo.lastUpdated = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000.0f];
    [self updateActiveParticipantInConferenceInfo];
    if (self.isCallStarted) {
        [[MeetTalkCallManager sharedManager] sendConferenceInfoNotification:self.activeCallRoom];
    }
}

- (void)showAudioButtonMuted:(BOOL)isAudioMuted {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isAudioMuted) {
            self.toggleAudioMuteIconImageView.image = [UIImage imageNamed:@"MeetTalkIconMicOffWhite" inBundle:[MeetTalk bundle] compatibleWithTraitCollection:nil];
            self.toggleAudioMuteButtonContainerView.backgroundColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkCallScreenInactiveButtonBackgroundComponentColor];
        }
        else {
            self.toggleAudioMuteIconImageView.image = [UIImage imageNamed:@"MeetTalkIconMicWhite" inBundle:[MeetTalk bundle] compatibleWithTraitCollection:nil];
            self.toggleAudioMuteButtonContainerView.backgroundColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkCallScreenActiveButtonBackgroundComponentColor];
        }
    });
}

- (void)toggleVideoMuteButtonDidTapped {
    if (![[MeetTalkCallManager sharedManager] checkAndRequestCameraPermission]) {
        return;
    }
    self.isVideoMuted = !self.isVideoMuted;
    [self showVideoButtonMuted:self.isVideoMuted];
    [self.meetTalkCallView setVideoMuted:self.isVideoMuted];
    self.activeParticipantInfo.isVideoMuted = self.isVideoMuted;
    self.activeParticipantInfo.lastUpdated = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000.0f];
    [self updateActiveParticipantInConferenceInfo];
    [self updateLayoutWithAnimation:YES];
    if (self.isCallStarted) {
        [[MeetTalkCallManager sharedManager] sendConferenceInfoNotification:self.activeCallRoom];
    }
}

- (void)showVideoButtonMuted:(BOOL)isVideoMuted {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isVideoMuted) {
            self.toggleVideoMuteIconImageView.image = [UIImage imageNamed:@"MeetTalkIconVideoCameraOffWhite" inBundle:[MeetTalk bundle] compatibleWithTraitCollection:nil];
            self.toggleVideoMuteButtonContainerView.backgroundColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkCallScreenInactiveButtonBackgroundComponentColor];
        }
        else {
            self.toggleVideoMuteIconImageView.image = [UIImage imageNamed:@"MeetTalkIconVideoCameraWhite" inBundle:[MeetTalk bundle] compatibleWithTraitCollection:nil];
            self.toggleVideoMuteButtonContainerView.backgroundColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkCallScreenActiveButtonBackgroundComponentColor];
        }
    });
}

- (void)hangUpButtonDidTapped {
    [self dismiss];
}

- (void)startCallDurationTimer {
    if (self.callStartTimestamp == 0L) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.callDurationStatusLabel.text = NSLocalizedString(@"Connected", @"");
    });
        
    [self stopCallDurationTimer];
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(callDurationTimerFired) userInfo:nil repeats:YES];
}

- (void)stopCallDurationTimer {
    if (self.durationTimer != nil) {
        [self.durationTimer invalidate];
    }
}

- (void)callDurationTimerFired {
    dispatch_async(dispatch_get_main_queue(), ^{
        long duration = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]].longValue - (long)(self.callStartTimestamp / 1000);
        NSString *callDurationString;
        NSTimeInterval durationTimeInterval = duration;
        callDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
        callDurationString = [TAPUtil nullToEmptyString:callDurationString];
        self.callDurationStatusLabel.text = callDurationString;
    });
}

- (void)fetchNewerMessages {
    if ([MeetTalkCallManager sharedManager].activeConferenceInfo == nil) {
        return;
    }
    // Fetch missed notifications when socket was offline
    NSNumber *lastUpdated = [MeetTalkCallManager sharedManager].activeConferenceInfo.lastUpdated;
    [[TAPCoreMessageManager sharedManager] getNewerMessagesAfterTimestamp:lastUpdated
                                                     lastUpdatedTimestamp:lastUpdated
                                                                   roomID:self.activeCallRoom.roomID
    success:^(NSArray<TAPMessageModel *> * _Nonnull messageArray) {
        if (messageArray.count > 0) {
            NSArray* reversedArray = [[messageArray reverseObjectEnumerator] allObjects];
            for (TAPMessageModel *message in reversedArray) {
                if ([message.room.roomID isEqualToString:self.activeCallRoom.roomID] && message.type) {
                    [[MeetTalkCallManager sharedManager] checkAndHandleCallNotificationFromMessage:message activeUser:[[TapTalk sharedInstance] getTapTalkActiveUser]];
                }
            }
        }
        if ([MeetTalkCallManager sharedManager].activeConferenceInfo != nil) {
            [self startCallDurationTimer];
            [self conferenceInfoUpdated:[MeetTalkCallManager sharedManager].activeConferenceInfo];
        }
        else {
            [self dismiss];
        }
    }
    failure:^(NSError * _Nonnull error) {
        // TODO: REQUEST LATEST CONFERENCE INFO
    }];
}

- (BOOL)checkIfCallIsEnded {
    if (self.activeCallRoom.type == RoomTypePersonal &&
        ([MeetTalkCallManager sharedManager].activeConferenceInfo == nil ||
         [MeetTalkCallManager sharedManager].activeConferenceInfo.callEndedTime.longValue > 0L)
    ) {
        [self dismiss];
        return YES;
    }
    return NO;
}

#pragma mark - Public Methods

- (void)setDataWithConferenceOptions:(JitsiMeetConferenceOptions *)conferenceOptions
                      activeCallRoom:(TAPRoomModel *)activeCallRoom
                activeConferenceInfo:(MeetTalkConferenceInfo *)activeConferenceInfo {
    
    _options = conferenceOptions;
    _activeCallRoom = activeCallRoom;
    _activeConferenceInfo = activeConferenceInfo;
}

- (void)conferenceInfoUpdated:(MeetTalkConferenceInfo *)updatedConferenceInfo {
#ifdef DEBUG
    NSLog(@">>>>> MeetTalkCallViewController updatedConferenceInfo isCallStarted: %ld", [NSNumber numberWithBool:self.isCallStarted].longValue);
    NSLog(@">>>>> MeetTalkCallViewController updatedConferenceInfo participants: %ld", updatedConferenceInfo.participants.count);
#endif
    
    if ([self checkIfCallIsEnded]) {
        return;
    }
    
    if ([MeetTalkCallManager sharedManager].activeConferenceInfo != nil &&
        !self.isCallStarted &&
        self.activeCallRoom.type == RoomTypePersonal &&
        updatedConferenceInfo.participants.count > 1
    ) {
        // Recipient has joined, mark the call as started
        self.isCallStarted = YES;
        if ([MeetTalkCallManager sharedManager].activeConferenceInfo.callStartedTime.longValue == 0L) {
            [MeetTalkCallManager sharedManager].activeConferenceInfo.callStartedTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000.0f];
        }
        self.callStartTimestamp = [MeetTalkCallManager sharedManager].activeConferenceInfo.callStartedTime.longValue;
        [self startCallDurationTimer];

        // Send updated conference info
        [[MeetTalkCallManager sharedManager] sendConferenceInfoNotification:self.activeCallRoom];
    }
    
    if (self.isCallStarted) {
        [self updateLayoutWithAnimation:YES];
    }
}

- (void)retrieveParticipantInfo {
//    [self.meetTalkCallView retrieveParticipantsInfo:^(NSArray * _Nullable array) {
//        // TODO:
//    }];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:^{
        self.meetTalkCallView.delegate = nil;
        [self.meetTalkCallView leave];
        [self stopCallDurationTimer];
        
        [[MeetTalkCallManager sharedManager] handleSendNotificationOnLeavingConference];
        [[MeetTalkCallManager sharedManager] setActiveCallAsEnded];
        [MeetTalkCallManager sharedManager].activeMeetTalkCallViewController = nil;
        [MeetTalkCallManager sharedManager].callState = MeetTalkCallStateIdle;
    }];
}

@end
