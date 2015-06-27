//
//  MLAudioPlayButton+Override.h
//  Pods
//
//  Created by molon on 15/6/28.
//
//

#import "MLAudioPlayButton.h"

@interface MLAudioPlayButton (Override)

@property (nonatomic, assign) MLAudioPlayButtonState audioState;

//for override
- (void)setUp;
- (void)playReceiveStop:(NSNotification*)notification;
- (void)playReceiveError:(NSNotification*)notification;
- (void)click;

@end
