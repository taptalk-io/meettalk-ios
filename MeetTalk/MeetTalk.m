//
//  MeetTalk.m
//  MeetTalk
//
//  Created by Kevin on 3/2/22.
//

#import "MeetTalk.h"
#import "MeetTalkCallManager.h"
#import <TapTalk/TapTalk.h>
#import <TapTalk/TAPChatManager.h>
#import <TapTalk/TAPCoreMessageManager.h>
#import <Intents/Intents.h>
#import <PushKit/PushKit.h>

@import JitsiMeetSDK;

@interface MeetTalk () <PKPushRegistryDelegate, TapTalkDelegate, TAPChatManagerDelegate, MeetTalkCallChatBubbleTableViewCellDelegate>

@property (strong, nonatomic) NSString *appID;

@end

@implementation MeetTalk

#pragma mark Initialization

+ (MeetTalk *)sharedInstance {
    static MeetTalk *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

+ (NSBundle *_Nullable)bundle {
    // Search all bundles
    for (NSBundle *bundle in [NSBundle allBundles]) {
        NSString *bundlePath = [bundle pathForResource:@"MeetTalk" ofType:@"bundle"];
        if (bundlePath) {
            return [NSBundle bundleWithPath:bundlePath];
        }
    }

    // Search all frameworks
    for (NSBundle *bundle in [NSBundle allFrameworks]) {
        NSString *bundlePath = [bundle pathForResource:@"MeetTalk" ofType:@"bundle"];
        if (bundlePath) {
            return [NSBundle bundleWithPath:bundlePath];
        }
    }
    
    return nil;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _appID = @"";
    }
    
    return self;
}

- (void)initWithAppKeyID:(NSString *_Nonnull)appKeyID
            appKeySecret:(NSString *_Nonnull)appKeySecret
            apiURLString:(NSString *_Nonnull)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType {
    
    [self initWithAppKeyID:appKeyID
              appKeySecret:appKeySecret
              apiURLString:apiURLString
        implementationType:tapTalkImplementationType
                   success:^{
    }];
}

- (void)initWithAppKeyID:(NSString *_Nonnull)appKeyID
            appKeySecret:(NSString *_Nonnull)appKeySecret
            apiURLString:(NSString *_Nonnull)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType
                 success:(void (^_Nullable)(void))success {

    [[TapTalk sharedInstance] initWithAppKeyID:appKeyID
                                  appKeySecret:appKeySecret
                                  apiURLString:apiURLString
                            implementationType:tapTalkImplementationType];
    
    [[TapTalk sharedInstance] setDelegate:self];
    [[TAPChatManager sharedManager] addDelegate:self];
    // Init managers to prevent delegate array mutation exception
    [TAPCoreMessageManager sharedManager];
    [MeetTalkCallManager sharedManager];
        
    // Initialize PKPushRegistry
    PKPushRegistry *pushRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
    pushRegistry.delegate = self;
    pushRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    if (tapTalkImplementationType != TapTalkImplentationTypeCore) {
        // Initialize call message bubble
        [[TapUI sharedInstance] addCustomBubbleWithClassName:@"MeetTalkCallChatBubbleTableViewCell" type:CALL_MESSAGE_TYPE delegate:self bundle:[MeetTalk bundle]];
//        [[TapUI sharedInstance] addCustomBubbleWithClassName:@"TAPYourChatBubbleTableViewCell" type:CALL_MESSAGE_TYPE delegate:self bundle:[TAPUtil currentBundle]];
        
    }
    
    success();
}

- (void)dealloc {
    [[TAPChatManager sharedManager] removeDelegate:self];
}

#pragma mark - AppDelegate Handling

- (void)application:(UIApplication *_Nonnull)application didFinishLaunchingWithOptions:(NSDictionary *_Nonnull)launchOptions {
    [[TapTalk sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
 }

- (void)applicationWillResignActive:(UIApplication *_Nonnull)application {
    [[TapTalk sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *_Nonnull)application {
    [[TapTalk sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *_Nonnull)application {
    [[TapTalk sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *_Nonnull)application {
    [[TapTalk sharedInstance] applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *_Nonnull)application {
    [[MeetTalkCallManager sharedManager] handleAppExiting:application];
}

- (void)application:(UIApplication *_Nonnull)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *_Nonnull)deviceToken {
    
    [[TapTalk sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *_Nonnull)application didReceiveRemoteNotification:(NSDictionary *_Nonnull)userInfo fetchCompletionHandler:(void (^_Nonnull)(UIBackgroundFetchResult result))completionHandler {
    
    [[TapTalk sharedInstance] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}

#pragma mark Delegates

#pragma mark TapTalkDelegate

// Add TapTalkDelegate callbacks to redirect all events to MeetTalkDelegate

- (void)tapTalkRefreshTokenExpired {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapTalkRefreshTokenExpired)]) {
        [self.delegate tapTalkRefreshTokenExpired];
    }
}

- (void)tapTalkUnreadChatRoomBadgeCountUpdated:(NSInteger)numberOfUnreadRooms {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapTalkUnreadChatRoomBadgeCountUpdated:)]) {
        [self.delegate tapTalkUnreadChatRoomBadgeCountUpdated:numberOfUnreadRooms];
    }
}

- (void)tapTalkDidRequestRemoteNotification {
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapTalkDidRequestRemoteNotification)]) {
        [self.delegate tapTalkDidRequestRemoteNotification];
    }
}

- (void)tapTalkDidTappedNotificationWithMessage:(TAPMessageModel *_Nonnull)message
                           fromActiveController:(nullable UIViewController *)currentActiveController {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapTalkDidTappedNotificationWithMessage:fromActiveController:)]) {
        [self.delegate tapTalkDidTappedNotificationWithMessage:message fromActiveController:currentActiveController];
    }
}

- (void)userLogout {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userLogout)]) {
        [self.delegate userLogout];
    }
}

#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
    
    if ([pushCredentials.token length] == 0) {
        return;
    }
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion {
    
    NSString *uuidString = payload.dictionaryPayload[@"UUID"];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    NSString *phoneNumber = payload.dictionaryPayload[@"PhoneNumber"];

//    TapCallViewController *callViewController = [[TapCallViewController alloc] init];
//    callViewController.phoneNumber = phoneNumber;
//    callViewController.isIncoming = YES;
//    callViewController.uuid = uuid;
//    UINavigationController *callNavigationViewController = [[UINavigationController alloc] initWithRootViewController:callViewController];
//    callNavigationViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
//    [self presentViewController:callNavigationViewController animated:YES completion:nil];
}

#pragma mark - TAPChatManagerDelegate

- (void)chatManagerDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message {
    [[MeetTalkCallManager sharedManager] checkAndHandleCallNotificationFromMessage:message activeUser:[[TapTalk sharedInstance] getTapTalkActiveUser]];
}

- (void)chatManagerDidReceiveNewMessageOnOtherRoom:(TAPMessageModel *)message {
    [self chatManagerDidReceiveNewMessageInActiveRoom:message];
}

#pragma mark MeetTalkCallChatBubbleTableViewCellDelegate

- (void)callChatBubbleCallButtonDidTapped:(TAPMessageModel *)tappedMessage {
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(meetTalkChatBubbleCallButtonDidTapped:viewController:)]
    ) {
        [self.delegate meetTalkChatBubbleCallButtonDidTapped:tappedMessage];
    }
    else {
        [[MeetTalkCallManager sharedManager] initiateNewConferenceCallWithRoom:tappedMessage.room];
    }
}

- (void)callChatBubbleLongPressed:(TAPMessageModel *)tappedMessage {
#ifdef DEBUG
    NSLog(@">>>>> callChatBubbleLongPressed: %@ %@", tappedMessage.user.fullname, tappedMessage.body);
#endif
}

#pragma mark - Custom Methods

#pragma mark - Incoming Call

- (void)showIncomingCallWithMessage:(TAPMessageModel *)message {
    [self showIncomingCallWithMessage:message phoneNumber:@""];
}

- (void)showIncomingCallWithMessage:(TAPMessageModel *)message phoneNumber:(NSString *)phoneNumber {
    [[MeetTalkCallManager sharedManager] showIncomingCallWithMessage:message displayPhoneNumber:phoneNumber];
}

#pragma mark - Conference Call

- (void)initiateNewConferenceCallWithRoom:(TAPRoomModel *)room {
    [[MeetTalkCallManager sharedManager] initiateNewConferenceCallWithRoom:room];
}

- (void)initiateNewConferenceCallWithRoom:(TAPRoomModel *)room
                     recipientDisplayName:(NSString *)recipientDisplayName {
    
    [[MeetTalkCallManager sharedManager] initiateNewConferenceCallWithRoom:room recipientDisplayName:recipientDisplayName];
}

- (BOOL)joinPendingIncomingConferenceCall {
    return [[MeetTalkCallManager sharedManager] joinPendingIncomingConferenceCall];
}

- (BOOL)launchMeetTalkCallViewController {
    return [[MeetTalkCallManager sharedManager] launchMeetTalkCallViewController];
}

- (BOOL)launchMeetTalkCallViewControllerWithRoom:(TAPRoomModel *)room
                                  activeUserName:(NSString *)activeUserName
                             activeUserAvatarUrl:(NSString *)activeUserAvatarUrl {
    
    return [[MeetTalkCallManager sharedManager] launchMeetTalkCallViewControllerWithRoom:room activeUserName:activeUserName activeUserAvatarUrl:activeUserAvatarUrl];
}

#pragma mark - Permission

- (BOOL)checkAndRequestAudioPermission {
    return [[MeetTalkCallManager sharedManager] checkAndRequestAudioPermission];
}

- (BOOL)checkAndRequestCameraPermission {
    return [[MeetTalkCallManager sharedManager] checkAndRequestCameraPermission];
}

@end
