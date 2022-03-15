//
//  MeetTalkCallViewController.h
//  MeetTalk
//
//  Created by Kevin on 3/4/22.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MeetTalkCallViewController : TAPBaseViewController

@property (nonatomic, weak) NSString *roomID;

- (void)joinConferenceTest;

@end

NS_ASSUME_NONNULL_END
