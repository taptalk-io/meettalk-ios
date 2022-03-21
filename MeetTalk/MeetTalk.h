//
//  MeetTalk.h
//  MeetTalk
//
//  Created by Kevin on 3/1/22.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <TapTalk/TapTalk.h>

//! Project version number for MeetTalk.
FOUNDATION_EXPORT double MeetTalkVersionNumber;

//! Project version string for MeetTalk.
FOUNDATION_EXPORT const unsigned char MeetTalkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <MeetTalk/PublicHeader.h>

@protocol MeetTalkDelegate <NSObject>

@end


@interface MeetTalk : NSObject

@property (weak, nonatomic) id<MeetTalkDelegate> _Nullable delegate;
//@property (strong, nonatomic) NSString *appID;

+ (void)launchCallActivityTest:(UINavigationController *)navigationController roomID:(NSString *)roomID;

+ (MeetTalk *)sharedInstance;
+ (NSBundle *_Nullable)bundle;
- (void)initWithAppKeyID:(NSString *_Nonnull)appKeyID
            appKeySecret:(NSString *_Nonnull)appKeySecret
            apiURLString:(NSString *_Nonnull)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType;

- (void)initWithAppKeyID:(NSString *_Nonnull)appKeyID
            appKeySecret:(NSString *_Nonnull)appKeySecret
            apiURLString:(NSString *_Nonnull)apiURLString
      implementationType:(TapTalkImplentationType)tapTalkImplementationType
                 success:(void (^_Nullable)(void))success;

@end
