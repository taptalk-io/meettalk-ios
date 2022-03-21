//
//  MeetTalkStyleManager.m
//  MeetTalk
//
//  Created by Kevin on 3/16/22.
//

#import "MeetTalkStyleManager.h"
#import "MeetTalkStyle.h"
#import <TapTalk/TAPStyle.h>
#import <TapTalk/TAPUtil.h>

@interface MeetTalkStyleManager ()

@property (strong, nonatomic) NSMutableDictionary *componentColorDictionary;
@property (strong, nonatomic) NSMutableDictionary *componentFontDictionary;

@end

@implementation MeetTalkStyleManager

#pragma mark - Lifecycle

+ (MeetTalkStyleManager *)sharedManager {
    static MeetTalkStyleManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[MeetTalkStyleManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _componentColorDictionary = [[NSMutableDictionary alloc] init];
        _componentFontDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)setComponentColor:(UIColor *)color forType:(MeetTalkComponentColor)componentColorType {
    [self.componentColorDictionary setObject:color forKey:[NSNumber numberWithInteger:componentColorType]];
}

- (void)setComponentFont:(UIFont *)font forType:(MeetTalkComponentFont)componentFontType {
    [self.componentFontDictionary setObject:font forKey:[NSNumber numberWithInteger:componentFontType]];
}

- (UIColor *)getComponentColorForType:(MeetTalkComponentColor)componentType {
    return [self retrieveComponentColorDataWithIdentifier:componentType];
}

- (UIFont *)getComponentFontForType:(MeetTalkComponentFont)componentFontType {
    return [self retrieveComponentFontDataWithIdentifier:componentFontType];
}

- (UIColor *)retrieveComponentColorDataWithIdentifier:(MeetTalkComponentColor)componentType {
    UIColor *obtainedComponentColor = [self.componentColorDictionary objectForKey:[NSNumber numberWithInteger:componentType]];
    if (obtainedComponentColor != nil) {
        return obtainedComponentColor;
    }
    
    switch (componentType) {
        // Call Message Bubble
        case MeetTalkRightCallBubbleMessageBodyComponentColor: {
            return [TAPUtil getColor:TAP_COLOR_WHITE];
            break;
        }
        case MeetTalkLeftCallBubbleMessageBodyComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_TEXT_DARK];
            break;
        }
        case MeetTalkRightCallBubbleTimestampDurationComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_WHITE];
            break;
        }
        case MeetTalkLeftCallBubbleTimestampDurationComponentColor:
        {
            return [[TAPUtil getColor:TAP_COLOR_TEXT_DARK] colorWithAlphaComponent:0.6f];
            break;
        }
        case MeetTalkRightCallBubblePhoneIconComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_PRIMARY];
            break;
        }
        case MeetTalkLeftCallBubblePhoneIconComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_WHITE];
            break;
        }
        case MeetTalkRightCallBubblePhoneIconBackgroundComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_WHITE];
            break;
        }
        case MeetTalkLeftCallBubblePhoneIconBackgroundComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_PRIMARY];
            break;
        }
        case MeetTalkIconArrowCallSuccessComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_SUCCESS];
            break;
        }
        case MeetTalkIconArrowCallFailureComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_ICON_ERROR];
            break;
        }
        // Call Screen
        case MeetTalkCallScreenTitleLabelComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_WHITE];
            break;
        }
        case MeetTalkCallScreenDurationStatusLabelComponentColor:
        {
            return [TAPUtil getColor:TAP_COLOR_WHITE];
            break;
        }
        case MeetTalkCallScreenActiveButtonBackgroundComponentColor:
        {
            return [[TAPUtil getColor:TAP_COLOR_WHITE] colorWithAlphaComponent:0.55f];
            break;
        }
        case MeetTalkCallScreenInactiveButtonBackgroundComponentColor:
        {
            return [[TAPUtil getColor:TAP_COLOR_WHITE] colorWithAlphaComponent:0.3f];
            break;
        }
        case MeetTalkCallScreenDestructiveButtonBackgroundComponentColor:
        {
            return [TAPUtil getColor:MEETTALK_DESTRUCTIVE_BUTTON_COLOR];
            break;
        }
        // Default
        default: {
            // Set default color to black to prevent crash
            return [TAPUtil getColor:@"9B9B9B"];
            break;
        }
    }
}

- (UIFont *)retrieveComponentFontDataWithIdentifier:(MeetTalkComponentFont)componentFontType {
    UIFont *obtainedFont = [self.componentFontDictionary objectForKey:[NSNumber numberWithInteger:componentFontType]];
    if (obtainedFont != nil) {
        return obtainedFont;
    }
    
    switch (componentFontType) {
        // Call Message Bubble
        case MeetTalkRightCallBubbleMessageBodyComponentFont:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_BOLD  size:16.0f];
            if (font == nil) {
                font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
            }
            return font;
            break;
        }
        case MeetTalkLeftCallBubbleMessageBodyComponentFont:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_BOLD  size:16.0f];
            if (font == nil) {
                font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
            }
            return font;
            break;
        }
        case MeetTalkRightCallBubbleTimestampDurationComponentFont:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_REGULAR size:14.0f];
            if (font == nil) {
                font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            }
            return font;
            break;
        }
        case MeetTalkLeftCallBubbleTimestampDurationComponentFont:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_REGULAR size:14.0f];
            if (font == nil) {
                font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            }
            return font;
            break;
        }
        // Call Screen
        case MeetTalkCallScreenTitleLabelComponentFont:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_BOLD  size:24.0f];
            if (font == nil) {
                font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
            }
            return font;
            break;
        }
        case MeetTalkCallScreenDurationStatusLabelComponentFont:
        {
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_REGULAR size:16.0f];
            if (font == nil) {
                font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            }
            return font;
            break;
        }
        // Default
        default:
        {
            // Set default font to prevent crash
            UIFont *font = [UIFont fontWithName:TAP_FONT_FAMILY_REGULAR size:[UIFont systemFontSize]];
            if (font == nil) {
                font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
            }
            return font;
            break;
        }
    }
}

@end
