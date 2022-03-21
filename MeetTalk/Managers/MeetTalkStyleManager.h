//
//  MeetTalkStyleManager.h
//  MeetTalk
//
//  Created by Kevin on 3/16/22.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MeetTalkComponentColor) {
    // Call Message Bubble
    MeetTalkRightCallBubbleMessageBodyComponentColor,
    MeetTalkLeftCallBubbleMessageBodyComponentColor,
    MeetTalkRightCallBubbleTimestampDurationComponentColor,
    MeetTalkLeftCallBubbleTimestampDurationComponentColor,
    MeetTalkRightCallBubblePhoneIconComponentColor,
    MeetTalkLeftCallBubblePhoneIconComponentColor,
    MeetTalkRightCallBubblePhoneIconBackgroundComponentColor,
    MeetTalkLeftCallBubblePhoneIconBackgroundComponentColor,
    MeetTalkIconArrowCallSuccessComponentColor,
    MeetTalkIconArrowCallFailureComponentColor,
    
    // Call Screen
    MeetTalkCallScreenTitleLabelComponentColor,
    MeetTalkCallScreenDurationStatusLabelComponentColor,
    MeetTalkCallScreenActiveButtonBackgroundComponentColor,
    MeetTalkCallScreenInactiveButtonBackgroundComponentColor,
    MeetTalkCallScreenDestructiveButtonBackgroundComponentColor,
};

typedef NS_ENUM(NSInteger, MeetTalkComponentFont) {
    // Call Message Bubble
    MeetTalkRightCallBubbleMessageBodyComponentFont,
    MeetTalkLeftCallBubbleMessageBodyComponentFont,
    MeetTalkRightCallBubbleTimestampDurationComponentFont,
    MeetTalkLeftCallBubbleTimestampDurationComponentFont,
    
    // Call Screen
    MeetTalkCallScreenTitleLabelComponentFont,
    MeetTalkCallScreenDurationStatusLabelComponentFont,
};

@interface MeetTalkStyleManager : NSObject

+ (MeetTalkStyleManager *)sharedManager;

- (void)setComponentColor:(UIColor *)color forType:(MeetTalkComponentColor)componentColorType;
- (void)setComponentFont:(UIFont *)font forType:(MeetTalkComponentFont)componentFontType;

- (UIColor *)getComponentColorForType:(MeetTalkComponentColor)componentType;
- (UIFont *)getComponentFontForType:(MeetTalkComponentFont)componentFontType;

@end

NS_ASSUME_NONNULL_END
