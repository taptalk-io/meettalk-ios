//
//  MeetTalkCallChatBubbleTableViewCell.m
//  MeetTalk
//
//  Created by Kevin on 3/16/22.
//

#import "MeetTalkCallChatBubbleTableViewCell.h"
#import "MeetTalkConferenceInfo.h"
#import "MeetTalkConfigs.h"
#import "MeetTalkStyle.h"
#import "MeetTalkStyleManager.h"
#import <TapTalk/TapTalk.h>
#import <TapTalk/TAPUserModel.h>
#import <TapTalk/TAPImageView.h>
#import <TapTalk/TAPStyle.h>
#import <TapTalk/TAPStyleManager.h>
#import <TapTalk/TAPContactManager.h>
#import <TapTalk/TAPUtil.h>

@interface MeetTalkCallChatBubbleTableViewCell ()

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *bubbleHighlightView;
@property (strong, nonatomic) IBOutlet UIView *senderView;
@property (strong, nonatomic) IBOutlet UIView *senderInitialView;
@property (strong, nonatomic) IBOutlet UIView *callButtonContainerView;
@property (strong, nonatomic) IBOutlet UILabel *senderInitialLabel;
@property (strong, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;
@property (strong, nonatomic) IBOutlet UILabel *callTimeDurationLabel;
@property (strong, nonatomic) IBOutlet UIButton *senderProfileButton;
@property (strong, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) IBOutlet UIImageView *arrowIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *callIconImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *senderAvatarImageView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderViewWidthConstraint; // 30
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderViewHeightConstraint; // 30
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderViewTrailingConstraint; // 4
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderViewReceiverLeadingConstraint; // 16
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewSenderTrailingConstraint; // 16
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleViewBottomConstraint; // 8
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderNameLabelHeightConstraint; // 16
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *senderNameLabelTopConstraint; // 10
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bodyLabelHeightConstraint; // 24
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *arrowIconImageViewHeightConstraint; // 21
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *callButtonContainerViewHeightConstraint; // 48
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *callButtonContainerViewBottomConstraint; // 10
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *callIconImageViewHeightConstraint; // 24
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *hiddenBubbleViewHeightConstraint;

@property (strong, nonatomic) TAPUserModel *activeUser;
@property (strong, nonatomic) UILongPressGestureRecognizer *bubbleViewLongPressGestureRecognizer;
@property (strong, nonatomic) NSString *currentProfileImageURLString;

@end

@implementation MeetTalkCallChatBubbleTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _activeUser = [[TapTalk sharedInstance] getTapTalkActiveUser];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.bubbleView.layer.cornerRadius = 16.0f;
    self.bubbleView.clipsToBounds = YES;
    self.bubbleHighlightView.layer.cornerRadius = 16.0f;
    self.bubbleHighlightView.clipsToBounds = YES;

    _bubbleViewLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleBubbleViewLongPress:)];
    self.bubbleViewLongPressGestureRecognizer.minimumPressDuration = 0.2f;
    [self.bubbleView addGestureRecognizer:self.bubbleViewLongPressGestureRecognizer];

    self.callIconImageView.image = [self.callIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.arrowIconImageView.image = [self.arrowIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self hideCell];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self hideCell];
}

- (BOOL)isCallHostedByActiveUser {
    if (self.message != nil) {
        MeetTalkConferenceInfo *conferenceInfo = [MeetTalkConferenceInfo fromMessageModel:self.message];
        if (conferenceInfo != nil) {
            return [self.activeUser.userID isEqualToString:conferenceInfo.hostUserID];
        }
        return NO;
    }
    return NO;
}

- (void)setMessage:(TAPMessageModel *)message {
    if (message == nil) {
        return;
    }
        
    _message = message;
    
    if (![message.action isEqualToString:CALL_ENDED] &&
        ![message.action isEqualToString:CALL_CANCELLED] &&
        ![message.action isEqualToString:RECIPIENT_BUSY] &&
        ![message.action isEqualToString:RECIPIENT_REJECTED_CALL] &&
        ![message.action isEqualToString:RECIPIENT_MISSED_CALL]
    ) {
        [self hideCell];
        return;
    }

    [self showCell];

    if ([self isCallHostedByActiveUser]) {
        // Active user is the call host
        [self showSenderInfo:NO];
        self.bubbleView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultRightBubbleBackground];
        self.bubbleView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.bubbleHighlightView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.callButtonContainerView.backgroundColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkRightCallBubblePhoneIconBackgroundComponentColor];
        [self.callIconImageView setTintColor:[[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkRightCallBubblePhoneIconComponentColor]];
        self.bodyLabel.textColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkRightCallBubbleMessageBodyComponentColor];
        self.bodyLabel.font = [[MeetTalkStyleManager sharedManager] getComponentFontForType:MeetTalkRightCallBubbleMessageBodyComponentFont];
        self.callTimeDurationLabel.textColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkRightCallBubbleTimestampDurationComponentColor];
        self.callTimeDurationLabel.font = [[MeetTalkStyleManager sharedManager] getComponentFontForType:MeetTalkRightCallBubbleTimestampDurationComponentFont];
        self.arrowIconImageView.transform = CGAffineTransformMakeRotation(M_PI);
        self.senderViewReceiverLeadingConstraint.active = NO;
        self.bubbleViewSenderTrailingConstraint.active = YES;
    }
    else {
        // Active user is not host
        [self showSenderInfo:message.room.type != RoomTypePersonal];
        self.bubbleView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultLeftBubbleBackground];
        self.bubbleView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.bubbleHighlightView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.callButtonContainerView.backgroundColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkLeftCallBubblePhoneIconBackgroundComponentColor];
        [self.callIconImageView setTintColor:[[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkLeftCallBubblePhoneIconComponentColor]];
        self.bodyLabel.textColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkLeftCallBubbleMessageBodyComponentColor];
        self.bodyLabel.font = [[MeetTalkStyleManager sharedManager] getComponentFontForType:MeetTalkLeftCallBubbleMessageBodyComponentFont];
        self.callTimeDurationLabel.textColor = [[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkLeftCallBubbleTimestampDurationComponentColor];
        self.callTimeDurationLabel.font = [[MeetTalkStyleManager sharedManager] getComponentFontForType:MeetTalkLeftCallBubbleTimestampDurationComponentFont];
        self.arrowIconImageView.transform = CGAffineTransformMakeRotation(0.0f);
        self.senderViewReceiverLeadingConstraint.active = YES;
        self.bubbleViewSenderTrailingConstraint.active = NO;
    }

    if ([self.message.action isEqualToString:CALL_ENDED]) {
        // Call successfully ended
        if ([self isCallHostedByActiveUser]) {
            self.bodyLabel.text = NSLocalizedString(@"Outgoing Call", @"");
        }
        else {
            self.bodyLabel.text = NSLocalizedString(@"Incoming Call", @"");
        }
        NSString *callDurationString = [self getCallDurationString:message];
        NSString *messageTimeString = [self getMessageTimeString:message];
        self.callTimeDurationLabel.text = [NSString stringWithFormat:@"%@ - %@", messageTimeString, callDurationString];
        [self.arrowIconImageView setTintColor:[[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkIconArrowCallSuccessComponentColor]];
    }
    else if ([self.message.action isEqualToString:CALL_CANCELLED] ||
             [self.message.action isEqualToString:RECIPIENT_BUSY]
    ) {
        // Caller cancelled the call or recipient is in another call
        if ([self isCallHostedByActiveUser]) {
            self.bodyLabel.text = NSLocalizedString(@"Cancelled Call", @"");
        }
        else {
            self.bodyLabel.text = NSLocalizedString(@"Missed Call", @"");
        }
        self.callTimeDurationLabel.text = [self getMessageTimeString:message];
        [self.arrowIconImageView setTintColor:[[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkIconArrowCallFailureComponentColor]];
    }
    else if ([self.message.action isEqualToString:RECIPIENT_REJECTED_CALL] ||
             [self.message.action isEqualToString:RECIPIENT_MISSED_CALL]
    ) {
        // Recipient rejected or missed the call
        if ([self isCallHostedByActiveUser]) {
            self.bodyLabel.text = NSLocalizedString(@"Outgoing Call", @"");
        }
        else {
            self.bodyLabel.text = NSLocalizedString(@"Missed Call", @"");
        }
        self.callTimeDurationLabel.text = [self getMessageTimeString:message];
        [self.arrowIconImageView setTintColor:[[MeetTalkStyleManager sharedManager] getComponentColorForType:MeetTalkIconArrowCallFailureComponentColor]];
    }
    else {
        [self hideCell];
    }

    [self.callButton addTarget:self action:@selector(callButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView layoutIfNeeded];
}

- (NSString *)getCallDurationString:(TAPMessageModel *)message {
    MeetTalkConferenceInfo *conferenceInfo = [MeetTalkConferenceInfo fromMessageModel:message];
    NSTimeInterval durationTimeInterval = [conferenceInfo.callDuration integerValue] / 1000;
    NSString *callDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
    return [TAPUtil nullToEmptyString:callDurationString];
}

- (NSString *)getMessageTimeString:(TAPMessageModel *)message {
    NSTimeInterval messageCreatedTimeInterval = [message.created integerValue] / 1000;
    NSDate *messageCreatedDate = [NSDate dateWithTimeIntervalSince1970:messageCreatedTimeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *messageTimeString = [dateFormatter stringFromDate:messageCreatedDate];
    return [TAPUtil nullToEmptyString:messageTimeString];
}

- (void)hideCell {
    self.contentView.alpha = 0.0f;
    self.bodyLabel.text = @"";
    self.callTimeDurationLabel.text = @"";
    [self.arrowIconImageView setTintColor:nil];
    [self showSenderInfo:NO];
    self.bubbleViewHeightConstraint.active = NO;
    self.hiddenBubbleViewHeightConstraint.active = YES;
    self.senderViewHeightConstraint.constant = 0.0f;
    self.bubbleViewBottomConstraint.constant = 0.0f;
    self.senderNameLabelHeightConstraint.constant = 0.0f;
    self.senderNameLabelTopConstraint.constant = 0.0f;
    self.bodyLabelHeightConstraint.constant = 0.0f;
    self.arrowIconImageViewHeightConstraint.constant = 0.0f;
    self.callButtonContainerViewHeightConstraint.constant = 0.0f;
    self.callButtonContainerViewBottomConstraint.constant = 0.0f;
    self.callIconImageViewHeightConstraint.constant = 0.0f;
    
    [self.contentView layoutIfNeeded];
}

- (void)showCell {
    self.contentView.alpha = 1.0f;
    self.hiddenBubbleViewHeightConstraint.active = NO;
    self.bubbleViewHeightConstraint.active = YES;
    self.senderViewHeightConstraint.constant = 30.0f;
    self.bubbleViewBottomConstraint.constant = 8.0f;
    self.senderNameLabelHeightConstraint.constant = 16.0f;
    self.senderNameLabelTopConstraint.constant = 10.0f;
    self.bodyLabelHeightConstraint.constant = 24.0f;
    self.arrowIconImageViewHeightConstraint.constant = 21.0f;
    self.callButtonContainerViewHeightConstraint.constant = 48.0f;
    self.callButtonContainerViewBottomConstraint.constant = 10.0f;
    self.callIconImageViewHeightConstraint.constant = 24.0f;
    self.callButtonContainerView.layer.cornerRadius = self.callButtonContainerViewHeightConstraint.constant / 2;
    self.callButtonContainerView.clipsToBounds = YES;
    
    [self.contentView layoutIfNeeded];
}

- (void)showSenderInfo:(BOOL)show {
    if (show && self.message != nil) {
        self.senderViewHeightConstraint.constant = 30.0f;
        self.senderViewWidthConstraint.constant = 30.0f;
        self.senderViewTrailingConstraint.constant = 4.0f;
        self.senderNameLabelHeightConstraint.constant = 18.0f;
        self.senderProfileButton.userInteractionEnabled = YES;

        NSString *fullNameString = self.message.user.fullname;
        fullNameString = [TAPUtil nullToEmptyString:fullNameString];
        self.senderNameLabel.text = fullNameString;

        NSString *thumbnailImageString = self.message.user.imageURL.thumbnail;
        thumbnailImageString = [TAPUtil nullToEmptyString:thumbnailImageString];
        if ([thumbnailImageString isEqualToString:@""]) {
            // Show initial
            self.senderInitialView.alpha = 1.0f;
            self.senderAvatarImageView.alpha = 0.0f;
            self.senderInitialView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:fullNameString];
            self.senderInitialLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:fullNameString isGroup:NO];
            self.senderInitialView.layer.cornerRadius = CGRectGetHeight(self.senderAvatarImageView.frame) / 2.0f;
            self.senderInitialView.clipsToBounds = YES;
        }
        else {
            // Load profile picture
            if (![self.currentProfileImageURLString isEqualToString:thumbnailImageString]) {
                self.senderAvatarImageView.image = nil;
            }

            self.senderInitialView.alpha = 0.0f;
            self.senderAvatarImageView.alpha = 1.0f;
            [self.senderAvatarImageView setImageWithURLString:thumbnailImageString];
            self.senderAvatarImageView.layer.cornerRadius = CGRectGetHeight(self.senderAvatarImageView.frame) / 2.0f;
            self.senderAvatarImageView.clipsToBounds = YES;
            _currentProfileImageURLString = thumbnailImageString;
        }
    }
    else {
        self.senderViewHeightConstraint.constant = 0.0f;
        self.senderViewWidthConstraint.constant = 0.0f;
        self.senderViewTrailingConstraint.constant = 0.0f;
        self.senderNameLabelHeightConstraint.constant = 0.0f;
        self.senderProfileButton.userInteractionEnabled = NO;

        self.senderAvatarImageView.image = nil;
        self.senderNameLabel.text = @"";
    }
}

- (void)callButtonDidTapped {
    if ([self.delegate respondsToSelector:@selector(callChatBubbleCallButtonDidTapped:)]) {
        [self.delegate callChatBubbleCallButtonDidTapped:self.message];
    }
}

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(callChatBubbleLongPressed:)]) {
            [self.delegate callChatBubbleLongPressed:self.message];
        }
    }
}

- (void)showBubbleHighlight {
    self.bubbleHighlightView.alpha = 0.0f;
    [TAPUtil performBlock:^{
        [UIView animateWithDuration:0.2f animations:^{
            self.bubbleHighlightView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [TAPUtil performBlock:^{
                [UIView animateWithDuration:0.75f animations:^{
                    self.bubbleHighlightView.alpha = 0.0f;
                }];
            } afterDelay:1.0f];
        }];
    } afterDelay:0.2f];
}

@end
