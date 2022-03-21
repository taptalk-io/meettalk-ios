//
//  MeetTalkCallChatBubbleTableViewCell.h
//  MeetTalk
//
//  Created by Kevin on 3/16/22.
//

#import "TAPBaseGeneralBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MeetTalkCallChatBubbleTableViewCellDelegate <NSObject>

- (void)callChatBubbleCallButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)callChatBubbleLongPressed:(TAPMessageModel *)tappedMessage;

@end

@interface MeetTalkCallChatBubbleTableViewCell : TAPBaseGeneralBubbleTableViewCell

@property (weak, nonatomic) id<MeetTalkCallChatBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;

//- (void)setMessage:(TAPMessageModel *)message;
- (void)showBubbleHighlight;

@end

NS_ASSUME_NONNULL_END
