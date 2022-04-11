//
//  MeetTalkCallManager.m
//  MeetTalk
//
//  Created by Kevin on 3/23/22.
//

#import "MeetTalk.h"
#import "MeetTalkCallManager.h"
#import "MeetTalkConfigs.h"
#import <TapTalk/TapTalk.h>
#import <TapTalk/TAPConnectionManager.h>
#import <TapTalk/TAPCoreMessageManager.h>
#import <TapTalk/TAPUtil.h>
#import <CallKit/CallKit.h>
#import <CallKit/CXError.h>

@import JitsiMeetSDK;

@interface MeetTalkCallManager () <CXProviderDelegate, TAPConnectionManagerDelegate>

@property (nonatomic, strong) CXProvider *provider;
@property (nonatomic, strong) CXCallController *callController;
@property (nonatomic, strong) NSUUID *currentCallUUID;
@property (nonatomic, strong) NSString *pendingIncomingCallRoomID;
@property (nonatomic, strong) NSString *pendingIncomingCallPhoneNumber;
@property (nonatomic, strong) NSString *answeredCallID;
@property (nonatomic, strong) NSTimer *missedCallTimer;
@property (nonatomic, strong) NSMutableArray<NSString *> *handledCallNotificationMessageLocalIDs;
@property (nonatomic, weak) UIApplication *application;
@property (nonatomic) BOOL shouldHandleConnectionManagerDelegate;
@property (nonatomic) TapTalkSocketConnectionMode savedSocketConnectionMode;

@end

@implementation MeetTalkCallManager

#pragma mark - Lifecycle

+ (MeetTalkCallManager *)sharedManager {
    static MeetTalkCallManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[MeetTalkCallManager alloc] init];
        [sharedManager initData];
    });
    return sharedManager;
}

- (void)initData {
    [self provider];
    
#ifdef DEBUG
    _defaultAudioMuted = YES;
#endif
    _defaultVideoMuted = YES;
    _pendingIncomingCallRoomID = nil;
    _pendingIncomingCallPhoneNumber = nil;
    _pendingCallNotificationMessages = [NSMutableArray array];
    _handledCallNotificationMessageLocalIDs = [NSMutableArray array];
    _roomAliasDictionary = [NSMutableDictionary dictionary];
    _shouldHandleConnectionManagerDelegate = NO;
    
    [[TAPConnectionManager sharedManager] addDelegate:self];
    
    // Initialize Jitsi Meet
    JitsiMeetConferenceOptions *defaultOptions
        = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
//            builder.serverURL = [NSURL URLWithString:MEET_URL];
            builder.serverURL = [NSURL URLWithString:@"https://meet.jit.si"];
            builder.audioMuted = self.defaultAudioMuted;
            builder.videoMuted = self.defaultVideoMuted;
            [builder setFeatureFlag:ADD_PEOPLE_ENABLED withBoolean:NO];
            [builder setFeatureFlag:AUDIO_MUTE_BUTTON_ENABLED withBoolean:NO];
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
            [builder setFeatureFlag:TOOLBOX_ENABLED withBoolean:NO];
            [builder setFeatureFlag:VIDEO_MUTE_BUTTON_ENABLED withBoolean:NO];
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

- (void)dealloc {
    [[TAPConnectionManager sharedManager] removeDelegate:self];
}

- (void)reportIncomingCallForUUID:(NSUUID *)uuid phoneNumber:(NSString *)phoneNumber {
    CXCallUpdate *update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:phoneNumber];
    __weak MeetTalkCallManager *weakSelf = self;
    NSLog(@">>>> reportIncomingCallForUUID: %@", uuid);
    [self.provider reportNewIncomingCallWithUUID:uuid update:update completion:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@">>>> reportIncomingCallForUUID: success");
            weakSelf.currentCallUUID = uuid;
        } else {
            NSLog(@">>>> reportIncomingCallForUUID ERROR: %@", error.localizedDescription);
            if (self.delegate && [self.delegate respondsToSelector:@selector(callDidFail)]) {
                [self.delegate callDidFail];
            }
        }
//        completion(error);
    }];
}

- (void)startCallWithPhoneNumber:(NSString *)phoneNumber {
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypePhoneNumber value:phoneNumber];
    self.currentCallUUID = [NSUUID new];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:self.currentCallUUID handle:handle];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:startCallAction];
    [self requestTransaction:transaction];
}

- (void)endCall {
    if (self.currentCallUUID == nil) {
        return;
    }
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:self.currentCallUUID];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:endCallAction];
    [self requestTransaction:transaction];
}

- (void)holdCall:(BOOL)hold {
    if (self.currentCallUUID == nil) {
        return;
    }
    CXSetHeldCallAction *holdCallAction = [[CXSetHeldCallAction alloc] initWithCallUUID:self.currentCallUUID onHold:hold];
    CXTransaction *transaction = [[CXTransaction alloc] init];
    [transaction addAction:holdCallAction];
    [self requestTransaction:transaction];
}

- (void)requestTransaction:(CXTransaction *)transaction {
    [self.callController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            if (self.delegate && [self.delegate respondsToSelector:@selector(callDidFail)]) {
                [self.delegate callDidFail];
            }
        }
    }];
}

#pragma mark - Getters

- (CXProvider *)provider {
    if (!_provider) {
        CXProviderConfiguration *configuration = [[CXProviderConfiguration alloc] initWithLocalizedName:@"CallKit"];
        configuration.supportsVideo = YES;
        configuration.maximumCallsPerCallGroup = 1;
        configuration.supportedHandleTypes = [NSSet setWithObject:@(CXHandleTypePhoneNumber)];
        _provider = [[CXProvider alloc] initWithConfiguration:configuration];
        [_provider setDelegate:self queue:nil];
    }
    return _provider;
}

- (CXCallController*)callController {
    if (!_callController) {
        _callController = [[CXCallController alloc] init];
    }
    return _callController;
}

#pragma mark - CXProviderDelegate

- (void)providerDidReset:(CXProvider *)provider {
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate providerDidReset:");
}

/// Called when the provider has been fully created and is ready to send actions and receive updates
- (void)providerDidBegin:(CXProvider *)provider {
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate providerDidBegin:");
}

// If provider:executeTransaction:error: returned NO, each perform*CallAction method is called sequentially for each action in the transaction
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action {
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate performStartCallAction:");
    [self.provider reportOutgoingCallWithUUID:action.callUUID startedConnectingAtDate:nil];
    [self.provider reportOutgoingCallWithUUID:action.callUUID connectedAtDate:nil];
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(callDidAnswer)]) {
//        [self.delegate callDidAnswer];
//    }
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action {
    [self answerIncomingCall];
    
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate performAnswerCallAction:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(callDidAnswer)]) {
        [self.delegate callDidAnswer];
    }
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action {
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate performEndCallAction:");
    self.currentCallUUID = nil;
    [self clearPendingIncomingCall];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(callDidEnd)]) {
        [self.delegate callDidEnd];
    }
    
    [action fulfill];
    
    // TODO: TEST USER REJECT CALL
    if (self.activeCallMessage != nil && [self.answeredCallID isEqualToString:self.activeCallMessage.localID]) {
        [self rejectIncomingCall];
    }
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action {
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate performSetHeldCallAction:");
//    if (action.isOnHold) {
//
//    }
//    else {
//
//    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(callDidHold:)]) {
        [self.delegate callDidHold:action.isOnHold];
    }
    
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action {
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate performSetMutedCallAction:");
}

- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action {
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate performSetGroupCallAction:");
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action {
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate performPlayDTMFCallAction:");
}

/// Called when an action was not performed in time and has been inherently failed. Depending on the action, this timeout may also force the call to end. An action that has already timed out should not be fulfilled or failed by the provider delegate
- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action {
    // React to the action timeout if necessary, such as showing an error UI.
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate timedOutPerformingAction:");
}

/// Called when the provider's audio session activation state changes.
- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession {
    //todo: start audio
    // Start call audio media, now that the audio session has been activated after having its priority boosted.
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate didActivateAudioSession:");
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession {
    /*
     Restart any non-call related audio now that the app's audio session has been
     de-activated after having its priority restored to normal.
     */
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate didDeactivateAudioSession:");
}

#pragma mark - TAPConnectionManagerDelegate

- (void)connectionManagerDidConnected {
    NSLog(@">>>> MeetTalkCallManager TAPConnectionManagerDelegate connectionManagerDidConnected:");
    if (!self.shouldHandleConnectionManagerDelegate) {
        return;
    }
    [self sendPendingCallNotificationMessages];
    
    if (self.activeMeetTalkCallViewController != nil) {
        [self.activeMeetTalkCallViewController connectionManagerDidConnected];
    }
}

- (void)connectionManagerDidDisconnectedWithCode:(NSInteger)code reason:(NSString *)reason cleanClose:(BOOL)clean {
    NSLog(@">>>> MeetTalkCallManager TAPConnectionManagerDelegate connectionManagerDidDisconnectedWithCode:");
    if (!self.shouldHandleConnectionManagerDelegate) {
        return;
    }
    if (self.callState == MeetTalkCallStateRinging) {
        [[TapTalk sharedInstance] connectWithSuccess:^{
                    
        }
        failure:^(NSError * _Nonnull error) {
            
        }];
    }
    
    if (self.activeMeetTalkCallViewController != nil) {
        [self.activeMeetTalkCallViewController connectionManagerDidDisconnectedWithCode:code reason:reason cleanClose:clean];
    }
}

- (void)connectionManagerIsConnecting {
    if (self.activeMeetTalkCallViewController != nil) {
        [self.activeMeetTalkCallViewController connectionManagerIsConnecting];
    }
}

- (void)connectionManagerIsReconnecting {
    if (self.activeMeetTalkCallViewController != nil) {
        [self.activeMeetTalkCallViewController connectionManagerIsReconnecting];
    }
}

- (void)connectionManagerDidReceiveError:(NSError *)error {
    if (self.activeMeetTalkCallViewController != nil) {
        [self.activeMeetTalkCallViewController connectionManagerDidReceiveError:error];
    }
}

- (void)connectionManagerDidReceiveNewEmit:(NSString *)eventName parameter:(NSDictionary *)dataDictionary {
    
}

#pragma mark - Custom Methods

- (void)showIncomingCallWithMessage:(TAPMessageModel *)message
                        //displayName:(NSString *)displayName
                 displayPhoneNumber:(NSString *)displayPhoneNumber {
    
    if (self.callState != MeetTalkCallStateIdle) {
        return;
    }
//    NSString *name;
//    if (![displayName isEqual:@""] && message != nil) {
//        [self.roomAliasDictionary setObject:displayName forKey:message.room.roomID];
//        name = displayName;
//    }
//    else if (message != nil) {
//        name = message.user.fullname;
//    }
//    else {
//        name = @"";
//    }
    NSString *phoneNumber;
    if (displayPhoneNumber == nil || [displayPhoneNumber isEqual:@""]) {
        if (message != nil && ![message.user.phone isEqual:@""]) {
            if (![message.user.countryCallingCode isEqual:@""]) {
                phoneNumber = [NSString stringWithFormat:@"+%@%@", message.user.countryCallingCode, message.user.phone];
            }
            else {
                phoneNumber = message.user.phone;
            }
        }
        else {
            phoneNumber = @"";
        }
    }
    else {
        phoneNumber = displayPhoneNumber;
    }
    
    // Show incoming call
    self.callState = MeetTalkCallStateRinging;
    
    if (message != nil) {
        self.pendingIncomingCallRoomID = message.room.roomID;
        self.pendingIncomingCallPhoneNumber = phoneNumber;
        
        // Trigger delegate callback
        if ([MeetTalk sharedInstance].delegate &&
            [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveIncomingCall:)]
        ) {
            [[MeetTalk sharedInstance].delegate meetTalkDidReceiveIncomingCall:message];
        }
    }
    
    NSUUID *uuid = [NSUUID new];
    [self reportIncomingCallForUUID:uuid phoneNumber:phoneNumber];
    [self startMissedCallTimer];
    NSLog(@">>>> showIncomingCallWithMessage: %@ %@", uuid, phoneNumber);
    

#ifdef DEBUG
    // TODO: TEST TO BYPASS INCOMING CALL
    [self answerIncomingCall];
#endif
}

- (void)dismissIncomingCall {
    if (self.currentCallUUID == nil) {
        return;
    }
    CXCallController *callController = [[CXCallController alloc] init];
    CXEndCallAction *endCallAction = [[CXEndCallAction alloc] initWithCallUUID:self.currentCallUUID];
    NSLog(@">>>> MeetTalkCallManager CXProviderDelegate performAnswerCallAction: %@", self.currentCallUUID);
    [callController requestTransactionWithAction:endCallAction completion:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@">>>> MeetTalkCallManager dismissIncomingCall: end call success");
        }
        else {
            NSLog(@">>>> MeetTalkCallManager dismissIncomingCall: end call error %@", error.localizedDescription);
        }
    }];
    [self clearPendingIncomingCall];
    
    // Trigger delegate callback
    if ([MeetTalk sharedInstance].delegate &&
        [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkIncomingCallDisconnected)]
    ) {
        [[MeetTalk sharedInstance].delegate meetTalkIncomingCallDisconnected];
    }
}

- (void)answerIncomingCall {
    if (self.activeCallMessage == nil) {
        return;
    }
    if ([MeetTalk sharedInstance].delegate &&
        [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidAnswerIncomingCall)]
    ) {
        [[MeetTalk sharedInstance].delegate meetTalkDidAnswerIncomingCall];
    }
    else {
        [self joinPendingIncomingConferenceCall];
    }
    self.answeredCallID = self.activeCallMessage.localID;
    [self clearPendingIncomingCall];
    [self dismissIncomingCall];
}

- (void)rejectIncomingCall {
    if (self.activeCallMessage == nil) {
        return;
    }
    if ([MeetTalk sharedInstance].delegate &&
        [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidRejectIncomingCall)]
    ) {
        [[MeetTalk sharedInstance].delegate meetTalkDidRejectIncomingCall];
    }
    else {
        [self rejectPendingIncomingConferenceCall];
    }
    [self clearPendingIncomingCall];
}

- (BOOL)checkAndRequestAudioPermission {
    AVAudioSessionRecordPermission permission = [[AVAudioSession sharedInstance] recordPermission];
    
    if (permission == AVAudioSessionRecordPermissionGranted) {
        return YES;
    }
    else if (permission == AVAudioSessionRecordPermissionUndetermined) {
        // Request permission
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkAndRequestAudioPermission];
            });
        }];
    }
    else if (permission == AVAudioSessionRecordPermissionDenied) {
        // No permission. Trying to normally request it
        [self requestPermissionInSettings];
    }
    return NO;
}

- (BOOL)checkAndRequestCameraPermission {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        return YES;
    }
    else if (status == AVAuthorizationStatusNotDetermined) {
        // Request permission
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self checkAndRequestCameraPermission];
            });
        }];
    }
    else {
        // No permission. Trying to normally request it
        [self requestPermissionInSettings];
    }
    return NO;
}

- (void)requestPermissionInSettings {
    NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:NSLocalizedStringFromTableInBundle(@"To give permissions tap on 'Change Settings' button", nil, [TAPUtil currentBundle], @"") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Change Settings", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (IS_IOS_11_OR_ABOVE) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    [alertController addAction:settingsAction];
    
    [[self topViewController] presentViewController:alertController animated:YES completion:nil];
}

- (void)clearPendingIncomingCall {
    self.callState = MeetTalkCallStateIdle;
    self.pendingIncomingCallRoomID = nil;
    self.pendingIncomingCallPhoneNumber = nil;
}

- (void)rejectPendingIncomingConferenceCall {
    if (self.activeCallMessage != nil) {
        [self sendRejectedCallNotification:self.activeCallMessage.room];
    }
    [self clearPendingIncomingCall];
}

- (BOOL)joinPendingIncomingConferenceCall {
    if (self.pendingIncomingCallRoomID == nil || self.activeCallMessage == nil) {
        return NO;
    }
    [self sendAnsweredCallNotification:self.activeCallMessage.room];
    [self launchMeetTalkCallViewController];
    self.pendingIncomingCallRoomID = nil;
    self.pendingIncomingCallPhoneNumber = nil;
    return YES;
}

- (void)closeIncomingCall {
    [self endCall];
    [self clearPendingIncomingCall];
}

- (void)initiateNewConferenceCallWithRoom:(TAPRoomModel *)room {
    if (room.type != RoomTypePersonal) {
        // TODO: Temporarily disabled for non-personal room
        return;
    }
    [self sendCallInitiatedNotification:room];
    [self launchMeetTalkCallViewController];
}

- (void)initiateNewConferenceCallWithRoom:(TAPRoomModel *)room
                     recipientDisplayName:(NSString *)recipientDisplayName {
    
    [self.roomAliasDictionary setObject:recipientDisplayName forKey:room.roomID];
    [self initiateNewConferenceCallWithRoom:room];
}

- (BOOL)launchMeetTalkCallViewController {
    if (self.activeCallMessage == nil ||
        self.activeConferenceInfo == nil
    ) {
        return NO;
    }
    TAPUserModel *activeUser = [[TapTalk sharedInstance] getTapTalkActiveUser];
    return [self launchMeetTalkCallViewControllerWithRoom:self.activeCallMessage.room
                                           activeUserName:activeUser.fullname
                                      activeUserAvatarUrl:activeUser.imageURL.fullsize];
}

- (BOOL)launchMeetTalkCallViewControllerWithRoom:(TAPRoomModel *)room
                                  activeUserName:(NSString *)activeUserName
                             activeUserAvatarUrl:(NSString *)activeUserAvatarUrl {
    
    UIViewController *topViewController = [self topViewController];
    if (self.activeCallMessage == nil ||
        self.activeConferenceInfo == nil ||
        topViewController == nil
    ) {
        return NO;
    }
    
    self.callState = MeetTalkCallStateInCall;
    
    NSString *conferenceRoomID = [NSString stringWithFormat:@"%@%@%@",
                                  MEET_ROOM_ID_PREFIX,
                                  self.activeConferenceInfo.callID,
                                  room.roomID
    ];
    
    JitsiMeetUserInfo *userInfo = [JitsiMeetUserInfo new];
    if (activeUserAvatarUrl != nil && ![activeUserAvatarUrl isEqual:@""]) {
        userInfo.avatar = [NSURL URLWithString:activeUserAvatarUrl];
    }
    if (activeUserName != nil && ![activeUserName isEqual:@""]) {
        userInfo.displayName = activeUserName;
    }
    
    JitsiMeetConferenceOptions *options = [JitsiMeetConferenceOptions fromBuilder:^(JitsiMeetConferenceOptionsBuilder *builder) {
        builder.room = conferenceRoomID;
        builder.userInfo = userInfo;
    }];
    
    MeetTalkCallViewController *callViewController = [[MeetTalkCallViewController alloc] initWithNibName:@"MeetTalkCallViewController" bundle:[MeetTalk bundle]];
    callViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [callViewController setDataWithConferenceOptions:options activeCallRoom:self.activeCallMessage.room activeConferenceInfo:self.activeConferenceInfo];
    [topViewController presentViewController:callViewController animated:YES completion:^{
    }];
    NSLog(@">>>> launchMeetTalkCallViewController conferenceRoomID: %@", conferenceRoomID);
    
    return YES;
}

- (UIViewController *_Nullable) topViewController {
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (topViewController == nil) {
        return nil;
    }
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
}

- (void)checkAndHandleCallNotificationFromMessage:(TAPMessageModel *)message activeUser:(TAPUserModel *)activeUser {
    NSLog(@">>>> checkAndHandleCallNotificationFromMessage: %ld %@ %@", message.type, message.user.fullname, message.body);
    if (message.type != CALL_MESSAGE_TYPE ||
        [self.handledCallNotificationMessageLocalIDs containsObject:message.localID]
    ) {
        // Return if:
        // • Message type is invalid
        // • Message has been previously handled
        return;
    }
    
    NSLog(@">>>> checkAndHandleCallNotificationFromMessage: %@ %@", message.body, message.data);
    [self.handledCallNotificationMessageLocalIDs addObject:message.localID];

    if (![message.action isEqualToString:CALL_ENDED] &&
        ![message.action isEqualToString:CALL_CANCELLED] &&
        ![message.action isEqualToString:RECIPIENT_BUSY] &&
        ![message.action isEqualToString:RECIPIENT_REJECTED_CALL] &&
        ![message.action isEqualToString:RECIPIENT_MISSED_CALL]
    ) {
        // Mark invisible message as read
        [[TAPCoreMessageManager sharedManager] markMessageAsRead:message];
    }

    if ([message.action isEqualToString:CALL_INITIATED] &&
        ![message.user.userID isEqualToString:activeUser.userID] &&
        [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000.0f].longValue - message.created.longValue < INCOMING_CALL_TIMEOUT_DURATION
    ) {
        if (self.callState == MeetTalkCallStateIdle) {
            if (message.data == nil) {
                // Received call initiated notification with no data, fetch data from API
                NSLog(@">>>> checkAndHandleCallNotificationFromMessage: CALL_INITIATED - Fetch data from API");
                [[TAPCoreMessageManager sharedManager] getNewerMessagesAfterTimestamp:message.created
                                                                 lastUpdatedTimestamp:message.created
                                                                               roomID:message.room.roomID
                success:^(NSArray<TAPMessageModel *> * _Nonnull messageArray) {
                    if (messageArray.count > 0) {
                        for (TAPMessageModel *obtainedMessage in messageArray) {
                            if ([message.localID isEqualToString:obtainedMessage.localID]) {
                                message.data = obtainedMessage.data;
                                [self setActiveCallData:message];
                                // Trigger delegate callback
                                if ([MeetTalk sharedInstance].delegate &&
                                    [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveCallInitiatedNotificationMessage:conferenceInfo:)]
                                ) {
                                    [[MeetTalk sharedInstance].delegate meetTalkDidReceiveCallInitiatedNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
                                }
                                else {
                                    [self showIncomingCallWithMessage:message displayPhoneNumber:@""];
                                }
                                break;
                            }
                        }
                    }
                }
                failure:^(NSError * _Nonnull error) {
                    
                }];
            }
            else {
                // Received call initiated notification, show incoming call
                NSLog(@">>>> checkAndHandleCallNotificationFromMessage: CALL_INITIATED - Show incoming call");
                [self setActiveCallData:message];
                // Trigger delegate callback
                if ([MeetTalk sharedInstance].delegate &&
                    [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveCallInitiatedNotificationMessage:conferenceInfo:)]
                ) {
                    [[MeetTalk sharedInstance].delegate meetTalkDidReceiveCallInitiatedNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
                }
                else {
                    [self showIncomingCallWithMessage:message displayPhoneNumber:@""];
                }
            }
        }
        else {
            // Send busy notification when a different call is received
            [self sendBusyNotification:message.room];
            // Trigger delegate callback
            if ([MeetTalk sharedInstance].delegate &&
                [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveCallInitiatedNotificationMessage:conferenceInfo:)]
            ) {
                [[MeetTalk sharedInstance].delegate meetTalkDidReceiveCallInitiatedNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
            }
        }
    }
    else if ([MeetTalkConferenceInfo fromMessageModel:message] != nil &&
             self.activeConferenceInfo != nil &&
             [[MeetTalkConferenceInfo fromMessageModel:message].callID isEqualToString:self.activeConferenceInfo.callID]
    ) {
        if (([message.action isEqualToString:CALL_CANCELLED] && ![message.user.userID isEqualToString:activeUser.userID]) ||
            ([message.action isEqualToString:RECIPIENT_REJECTED_CALL] && [message.user.userID isEqualToString:activeUser.userID])
        ) {
            // Caller cancelled call or recipient rejected call elsewhere, dismiss incoming call
            NSLog(@">>>> checkAndHandleCallNotificationFromMessage: %@", message.action);
            [self.activeMeetTalkCallViewController dismiss];
            [self closeIncomingCall];
            [self setActiveCallAsEnded];
            
            // Trigger delegate callback
            if ([message.action isEqualToString:CALL_CANCELLED]) {
                if ([MeetTalk sharedInstance].delegate &&
                    [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveCallCancelledNotificationMessage:conferenceInfo:)]
                ) {
                    [[MeetTalk sharedInstance].delegate meetTalkDidReceiveCallCancelledNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
                }
            }
            else if ([message.action isEqualToString:RECIPIENT_REJECTED_CALL]) {
                if ([MeetTalk sharedInstance].delegate &&
                    [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveActiveUserRejectedCallNotificationMessage:conferenceInfo:)]
                ) {
                    [[MeetTalk sharedInstance].delegate meetTalkDidReceiveActiveUserRejectedCallNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
                }
            }
        }
        else if ([message.action isEqualToString:CALL_ENDED]) {
            // A party ended the call, leave active call room
            NSLog(@">>>> checkAndHandleCallNotificationFromMessage: CALL_ENDED");
            [self.activeMeetTalkCallViewController dismiss];
            [self setActiveCallAsEnded];
            
            // Trigger delegate callback
            if ([MeetTalk sharedInstance].delegate &&
                [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveCallEndedNotificationMessage:conferenceInfo:)]
            ) {
                [[MeetTalk sharedInstance].delegate meetTalkDidReceiveCallEndedNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
            }
        }
        else if ([message.action isEqualToString:RECIPIENT_ANSWERED_CALL]) {
            NSLog(@">>>> checkAndHandleCallNotificationFromMessage: RECIPIENT_ANSWERED_CALL %@", message.user.fullname);
            if ([message.user.userID isEqualToString:activeUser.userID]) {
                // Recipient answered call elsewhere, dismiss incoming call
                [self closeIncomingCall];
                self.callState = MeetTalkCallStateIdle;
            }
            
            // Trigger delegate callback
            if ([MeetTalk sharedInstance].delegate &&
                [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveRecipientAnsweredCallNotificationMessage:conferenceInfo:)]
            ) {
                [[MeetTalk sharedInstance].delegate meetTalkDidReceiveRecipientAnsweredCallNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
            }
        }
        else if ([message.action isEqualToString:PARTICIPANT_JOINED_CONFERENCE]) {
            // A participant successfully joined the call, notify call view controller
            NSLog(@">>>> checkAndHandleCallNotificationFromMessage: PARTICIPANT_JOINED_CONFERENCE %@", message.user.fullname);
            MeetTalkConferenceInfo *updatedConferenceInfo = [MeetTalkConferenceInfo fromMessageModel:message];
            if (self.activeConferenceInfo != nil && updatedConferenceInfo != nil) {
                [self.activeConferenceInfo updateValue:updatedConferenceInfo];
                if (self.activeMeetTalkCallViewController != nil) {
                    [self.activeMeetTalkCallViewController conferenceInfoUpdated:self.activeConferenceInfo];
                }
            }
            
            // Trigger delegate callback
            if ([MeetTalk sharedInstance].delegate &&
                [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveParticipantJoinedConferenceNotificationMessage:conferenceInfo:)]
            ) {
                [[MeetTalk sharedInstance].delegate meetTalkDidReceiveParticipantJoinedConferenceNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
            }
        }
        else if ([message.action isEqualToString:PARTICIPANT_LEFT_CONFERENCE]) {
            // A participant left the call
            NSLog(@">>>> checkAndHandleCallNotificationFromMessage: PARTICIPANT_LEFT_CONFERENCE %@", message.user.fullname);
            MeetTalkConferenceInfo *updatedConferenceInfo = [MeetTalkConferenceInfo fromMessageModel:message];
            if (self.activeConferenceInfo != nil && updatedConferenceInfo != nil) {
                [self.activeConferenceInfo updateValue:updatedConferenceInfo];
                if (self.activeMeetTalkCallViewController != nil) {
                    [self.activeMeetTalkCallViewController conferenceInfoUpdated:self.activeConferenceInfo];
                }
            }
            
            // Trigger delegate callback
            if ([MeetTalk sharedInstance].delegate &&
                [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveParticipantLeftConferenceNotificationMessage:conferenceInfo:)]
            ) {
                [[MeetTalk sharedInstance].delegate meetTalkDidReceiveParticipantLeftConferenceNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
            }
        }
        else if (![message.user.userID isEqualToString:activeUser.userID] &&
                 ([message.action isEqualToString:RECIPIENT_BUSY] ||
                 [message.action isEqualToString:RECIPIENT_REJECTED_CALL] ||
                 [message.action isEqualToString:RECIPIENT_MISSED_CALL])
        ) {
            // Recipient did not join call, leave call room
            NSLog(@">>>> checkAndHandleCallNotificationFromMessage: %@", message.action);
            [self.activeMeetTalkCallViewController dismiss];
            [self setActiveCallAsEnded];
            
            // Trigger delegate callback
            if ([message.action isEqualToString:RECIPIENT_BUSY]) {
                if ([MeetTalk sharedInstance].delegate &&
                    [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveRecipientBusyNotificationMessage:conferenceInfo:)]
                ) {
                    [[MeetTalk sharedInstance].delegate meetTalkDidReceiveRecipientBusyNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
                }
            }
            else if ([message.action isEqualToString:RECIPIENT_REJECTED_CALL]) {
                if ([MeetTalk sharedInstance].delegate &&
                    [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveRecipientRejectedCallNotificationMessage:conferenceInfo:)]
                ) {
                    [[MeetTalk sharedInstance].delegate meetTalkDidReceiveRecipientRejectedCallNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
                }
            }
            else if ([message.action isEqualToString:RECIPIENT_MISSED_CALL]) {
                if ([MeetTalk sharedInstance].delegate &&
                    [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveRecipientMissedCallNotificationMessage:conferenceInfo:)]
                ) {
                    [[MeetTalk sharedInstance].delegate meetTalkDidReceiveRecipientMissedCallNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
                }
            }
        }
        else if ([message.action isEqualToString:CONFERENCE_INFO] && ![message.user.userID isEqualToString:activeUser.userID]) {
            NSLog(@">>>> checkAndHandleCallNotificationFromMessage: CONFERENCE_INFO - update view controller");
            // Received updated conference info
            MeetTalkConferenceInfo *updatedConferenceInfo = [MeetTalkConferenceInfo fromMessageModel:message];
            if (self.activeConferenceInfo != nil && updatedConferenceInfo != nil) {
                [self.activeConferenceInfo updateValue:updatedConferenceInfo];
                if (self.activeMeetTalkCallViewController != nil) {
                    [self.activeMeetTalkCallViewController retrieveParticipantInfo];
                    [self.activeMeetTalkCallViewController conferenceInfoUpdated:self.activeConferenceInfo];
                }
            }
            
            // Trigger delegate callback
            if ([MeetTalk sharedInstance].delegate &&
                [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveConferenceInfoUpdatedNotificationMessage:conferenceInfo:)]
            ) {
                [[MeetTalk sharedInstance].delegate meetTalkDidReceiveConferenceInfoUpdatedNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
            }
        }
        else if ([message.action isEqualToString:RECIPIENT_UNABLE_TO_RECEIVE_CALL]) {
            // One of the recipient's device is unable to receive the call
            // TODO:
            
            // Trigger delegate callback
            if ([MeetTalk sharedInstance].delegate &&
                [[MeetTalk sharedInstance].delegate respondsToSelector:@selector(meetTalkDidReceiveRecipientUnableToReceiveCallNotificationMessage:conferenceInfo:)]
            ) {
                [[MeetTalk sharedInstance].delegate meetTalkDidReceiveRecipientUnableToReceiveCallNotificationMessage:message conferenceInfo:[MeetTalkConferenceInfo fromMessageModel:message]];
            }
        }
        
    }
}

- (TAPMessageModel *)generateCallNotificationMessageWithRoom:(TAPRoomModel *)room
                                                        body:(NSString *)body
                                                      action:(NSString *)action {
    
    TAPUserModel *activeUser = [[TapTalk sharedInstance] getTapTalkActiveUser];
    TAPMessageModel *notificationMessage = [TAPMessageModel createMessageWithUser:activeUser room:room body:body type:CALL_MESSAGE_TYPE messageData:nil];
    notificationMessage.action = action;
    return notificationMessage;
}

- (MeetTalkParticipantInfo *)generateParticipantInfoWithRole:(NSString *)role {
    TAPUserModel *activeUser = [[TapTalk sharedInstance] getTapTalkActiveUser];
    MeetTalkParticipantInfo *participantInfo = [MeetTalkParticipantInfo new];
    participantInfo.userID = activeUser.userID;
    participantInfo.participantID = @"";
    participantInfo.displayName = activeUser.fullname;
    participantInfo.imageURL = activeUser.imageURL.fullsize;
    participantInfo.role = role;
    participantInfo.leaveTime = [NSNumber numberWithLong:0L];
    participantInfo.lastUpdated = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000.0f];
    participantInfo.isAudioMuted = self.defaultAudioMuted;
    participantInfo.isVideoMuted = self.defaultVideoMuted;
    return participantInfo;
}

- (TAPMessageModel *)setMessageConferenceInfoAsEnded:(TAPMessageModel *)message {
    if (self.activeConferenceInfo != nil) {
        MeetTalkConferenceInfo *conferenceInfo = [self.activeConferenceInfo copy];
        conferenceInfo.callEndedTime = message.created;
        conferenceInfo.lastUpdated = message.created;
        if (conferenceInfo.callStartedTime.longValue > 0L) {
            conferenceInfo.callDuration = [NSNumber numberWithLong:conferenceInfo.callEndedTime.longValue - conferenceInfo.callStartedTime.longValue];
        }
        [conferenceInfo attachToMessage:message];
        message.filterID = conferenceInfo.callID;
    }
    return  message;
}

- (TAPMessageModel *)sendCallInitiatedNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} started call." action:CALL_INITIATED];
    NSMutableArray<MeetTalkParticipantInfo *> *participants = [NSMutableArray array];
    MeetTalkParticipantInfo *host = [self generateParticipantInfoWithRole:HOST];
    [participants addObject:host];
    MeetTalkConferenceInfo *conferenceInfo = [MeetTalkConferenceInfo new];
    conferenceInfo.callID = message.localID;
    conferenceInfo.roomID = message.room.roomID;
    conferenceInfo.hostUserID = message.user.userID;
    conferenceInfo.callInitiatedTime = message.created;
    conferenceInfo.callStartedTime = [NSNumber numberWithLong:0L];
    conferenceInfo.callEndedTime = [NSNumber numberWithLong:0L];
    conferenceInfo.callDuration = [NSNumber numberWithLong:0L];
    conferenceInfo.lastUpdated = message.created;
    conferenceInfo.participants = participants;
    [conferenceInfo attachToMessage:message];
    message.filterID = conferenceInfo.callID;
    
    [self setActiveCallData:message];
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendCallCanceledNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} cancelled call." action:CALL_CANCELLED];
    message = [self setMessageConferenceInfoAsEnded:message];
    
    [self setActiveCallAsEnded];
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendCallEndedNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} ended call." action:CALL_ENDED];
    message = [self setMessageConferenceInfoAsEnded:message];
    
    [self setActiveCallAsEnded];
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendAnsweredCallNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} answered call." action:RECIPIENT_ANSWERED_CALL];
    if (self.activeConferenceInfo != nil) {
        [self.activeConferenceInfo attachToMessage:message];
    }
    //message.isHidden = YES;
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendJoinedCallNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} joined call." action:PARTICIPANT_JOINED_CONFERENCE];
    MeetTalkParticipantInfo *participant = [self generateParticipantInfoWithRole:PARTICIPANT];
    if (self.activeConferenceInfo != nil) {
        [self.activeConferenceInfo updateParticipant:participant];
        self.activeConferenceInfo.lastUpdated = message.created;
        [self.activeConferenceInfo attachToMessage:message];
    }
    message.isHidden = YES;
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendLeftCallNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} left call." action:PARTICIPANT_LEFT_CONFERENCE];
    if (self.activeConferenceInfo != nil) {
        self.activeConferenceInfo.lastUpdated = message.created;
        [self.activeConferenceInfo attachToMessage:message];
    }
    message.isHidden = YES;
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendBusyNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} is busy." action:RECIPIENT_BUSY];
    message = [self setMessageConferenceInfoAsEnded:message];
    
    [self setActiveCallAsEnded];
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendRejectedCallNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} rejected call." action:RECIPIENT_REJECTED_CALL];
    message = [self setMessageConferenceInfoAsEnded:message];
    
    [self setActiveCallAsEnded];
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendMissedCallNotification:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"{{sender}} missed call." action:RECIPIENT_MISSED_CALL];
    message = [self setMessageConferenceInfoAsEnded:message];
    
    [self setActiveCallAsEnded];
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendUnableToReceiveCallNotification:(NSString *)body room:(TAPRoomModel *)room {
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:body action:RECIPIENT_UNABLE_TO_RECEIVE_CALL];
    message.isHidden = YES;
    
    [self setActiveCallAsEnded];
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (TAPMessageModel *)sendConferenceInfoNotification:(TAPRoomModel *)room {
    if (self.activeConferenceInfo == nil) {
        return nil;
    }
    TAPMessageModel *message = [self generateCallNotificationMessageWithRoom:room body:@"Call info updated." action:CONFERENCE_INFO];
    self.activeConferenceInfo.lastUpdated = message.created;
    [self.activeConferenceInfo attachToMessage:message];
    message.isHidden = YES;
    
    [self sendCallNotificationMessage:message];
    
    return message;
}

- (void)sendPendingCallNotificationMessages {
    NSLog(@">>>> MeetTalkCallManager sendPendingCallNotificationMessages size: %ld", self.pendingCallNotificationMessages.count);
    NSMutableArray<TAPMessageModel *> *pendingMessagesCopy = [[NSMutableArray alloc] initWithArray:self.pendingCallNotificationMessages copyItems:YES];
    for (TAPMessageModel *message in pendingMessagesCopy) {
        TAPMessageModel *messageCopy = [message copy];
        [self.pendingCallNotificationMessages removeObject:message];
        [self sendCallNotificationMessage:messageCopy];
    }
}

- (void)sendCallNotificationMessage:(TAPMessageModel *)message {
    if ([[TapTalk sharedInstance] isConnected]) {
        NSLog(@">>>> MeetTalkCallManager sendCallNotificationMessage: %@", message.action);
        [[TAPCoreMessageManager sharedManager] sendCustomMessageWithMessageModel:message
        start:^(TAPMessageModel * _Nonnull message) {
                
        }
        success:^(TAPMessageModel * _Nonnull message) {
                
        }
        failure:^(TAPMessageModel * _Nullable message, NSError * _Nonnull error) {
                
        }];
    }
    else {
        NSLog(@">>>> MeetTalkCallManager add to pending array: %@", message.action);
        [self.pendingCallNotificationMessages addObject:message];
    }
}

- (void)handleSendNotificationOnLeavingConference {
    if (self.activeCallMessage == nil || self.activeMeetTalkCallViewController == nil) {
        NSLog(@">>>> MeetTalkCallManager handleSendNotificationOnLeavingConference: return");
        return;
    }
    
    if (self.activeCallMessage.room.type == RoomTypePersonal) {
        if (self.activeConferenceInfo != nil && self.activeConferenceInfo.participants.count > 1) {
            NSLog(@">>>> MeetTalkCallManager handleSendNotificationOnLeavingConference: sendCallEndedNotification");
            // Send call ended notification to notify the other party
            [self sendCallEndedNotification:self.activeCallMessage.room];
        }
        else if ([self.activeConferenceInfo.hostUserID isEqualToString:[[TapTalk sharedInstance] getTapTalkActiveUser].userID]) {
            NSLog(@">>>> MeetTalkCallManager handleSendNotificationOnLeavingConference: sendCallCanceledNotification");
            // Send call cancelled notification to notify recipient
            [self sendCallCanceledNotification:self.activeCallMessage.room];
        }
        else if (!self.activeMeetTalkCallViewController.isCallStarted) {
            NSLog(@">>>> MeetTalkCallManager handleSendNotificationOnLeavingConference: sendRejectedCallNotification");
            // Left conference before connecteed, send call rejected notification to notify recipient
            [self sendRejectedCallNotification:self.activeCallMessage.room];
        }
    }
    else {
        // Send left call notification to conference
        NSLog(@">>>> MeetTalkCallManager handleSendNotificationOnLeavingConference: sendLeftCallNotification");
        [self sendLeftCallNotification:self.activeCallMessage.room];
    }
}

- (void)setActiveCallData:(TAPMessageModel *)message {
    self.activeCallMessage = message;
    self.activeConferenceInfo = [MeetTalkConferenceInfo fromMessageModel:message];
    //[[TAPConnectionManager sharedManager] addDelegate:self];
    self.shouldHandleConnectionManagerDelegate = YES;
    self.savedSocketConnectionMode = [[TapTalk sharedInstance] getTapTalkSocketConnectionMode];
    [[TapTalk sharedInstance] setTapTalkSocketConnectionMode:TapTalkSocketConnectionModeAlwaysOn];
}

- (void)setActiveCallAsEnded {
    //[[TAPConnectionManager sharedManager] removeDelegate:self];
    //self.shouldHandleConnectionManagerDelegate = NO;
    [[TapTalk sharedInstance] setTapTalkSocketConnectionMode:self.savedSocketConnectionMode];
    [self.pendingCallNotificationMessages removeAllObjects];
    self.activeCallMessage = nil;
    self.activeConferenceInfo = nil;
    self.callState = MeetTalkCallStateIdle;
}

- (void)startMissedCallTimer {
    if (self.activeCallMessage == nil) {
        return;
    }
    
    if (self.missedCallTimer != nil) {
        [self.missedCallTimer invalidate];
    }
    
    NSTimeInterval missedCallInterval = ((INCOMING_CALL_TIMEOUT_DURATION + self.activeCallMessage.created.longValue) / 1000.0f) - [[NSDate date] timeIntervalSince1970];
    
    self.missedCallTimer = [NSTimer scheduledTimerWithTimeInterval:missedCallInterval target:self selector:@selector(missedCallTimerFired) userInfo:nil repeats:NO];
}

- (void)missedCallTimerFired {
    if (self.callState == MeetTalkCallStateRinging) {
        // Send missed call notification
        [self sendMissedCallNotification:self.activeCallMessage.room];
        [self closeIncomingCall];
        self.callState = MeetTalkCallStateIdle;
    }
    
    if (self.missedCallTimer != nil) {
        [self.missedCallTimer invalidate];
    }
}

- (void)handleAppExiting:(UIApplication *_Nonnull)application {
    NSLog(@">>>> MeetTalkCallManager handleAppExiting");
    _application = application;
    [self dismissIncomingCall];
    if (self.pendingCallNotificationMessages.count > 0 ||
        (self.activeCallMessage != nil &&
         self.activeConferenceInfo != nil &&
         self.activeConferenceInfo.callEndedTime.longValue == 0L)
    ) {
        if (self.callState == MeetTalkCallStateRinging) {
            NSLog(@">>>> MeetTalkCallManager handleAppExiting: sendRejectedCallNotification");
            [self sendRejectedCallNotification:self.activeCallMessage.room];
        }
        else {
            NSLog(@">>>> MeetTalkCallManager handleAppExiting: handleSendNotificationOnLeavingConference");
            [self handleSendNotificationOnLeavingConference];
        }
    }
    [[TapTalk sharedInstance] connectWithSuccess:^{
        NSLog(@">>>> MeetTalkCallManager handleAppExiting: connect Success");
        [self handleDisconnectAndExit];
    }
    failure:^(NSError * _Nonnull error) {
        NSLog(@">>>> MeetTalkCallManager handleAppExiting: connect ERROR");
        [self handleDisconnectAndExit];
    }];
}

- (void)handleDisconnectAndExit {
    [self sendPendingCallNotificationMessages];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSTimer *exitTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(exitCallTimerFired) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:exitTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        }
    );
}

- (void)exitCallTimerFired {
    NSLog(@">>>> MeetTalkCallManager handleAppExiting: exitCallTimerFired");
    [[TapTalk sharedInstance] disconnectWithCompletionHandler:^{
        if (self.application != nil) {
            NSLog(@">>>> MeetTalkCallManager handleAppExiting: TapTalk applicationWillTerminate");
            [[TapTalk sharedInstance] applicationWillTerminate:self.application];
            if (self.activeMeetTalkCallViewController != nil) {
                [self.activeMeetTalkCallViewController dismiss];
            }
        }
        //exit(0);
    }];
}

@end
