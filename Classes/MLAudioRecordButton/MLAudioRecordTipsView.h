//
//  MLAudioRecordTipsView.h
//  MLVoice
//
//  Created by molon on 15/6/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLAudioRecordButton.h"

@protocol MLAudioRecordTipsViewDelegate <NSObject>

- (void)showWithMLAudioRecordButtonStatus:(MLAudioRecordButtonStatus)status volume:(Float32)volume;
- (void)hide;
- (void)showWarning:(NSString*)warningText hideAfterDelay:(NSTimeInterval)delay;

@end

@interface MLAudioRecordWeChatStyleTipsView : UIView<MLAudioRecordTipsViewDelegate>


@end
