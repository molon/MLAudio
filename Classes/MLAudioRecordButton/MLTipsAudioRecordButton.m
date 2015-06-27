//
//  MLTipsAudioRecordButton.m
//  MLVoice
//
//  Created by molon on 15/6/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLTipsAudioRecordButton.h"
#import "MLAudioRecordTipsView.h"

@interface MLTipsAudioRecordButton()

@property (nonatomic, strong) id<MLAudioRecordTipsViewDelegate> tipsView;
@property (nonatomic, assign) Float32 volume;

@end

@implementation MLTipsAudioRecordButton

- (instancetype)initWithMLAudioRecordTipsView:(id<MLAudioRecordTipsViewDelegate>)tipsView
{
    self = [self init];
    if (self) {
        self.tipsView = tipsView;
        
        __weak __typeof(self)weakself = self;
        //很多自己的回调调一下，和tipsView联合起来
        [self setStatusChangedBlock:^(MLAudioRecordButtonStatus status, MLAudioRecordButton *button) {
            if (status==MLAudioRecordButtonStatusNormal) {
                [tipsView hide];
            }else{
                [tipsView showWithMLAudioRecordButtonStatus:status volume:weakself.volume];
            }
        }];
        
        [self setVolumeUpdatedBlock:^(Float32 volume, MLAudioRecordButton *button) {
            weakself.volume = volume;
            [tipsView showWithMLAudioRecordButtonStatus:button.status volume:volume];
        }];
        
        [self setDidRecordTooShortAudioBlock:^(NSURL *filePath, NSTimeInterval duration, MLAudioRecordButton *button) {
            [tipsView showWarning:@"说话时间太短" hideAfterDelay:1.5f];
        }];
        
        [self setDidReceiveErrorBlock:^(NSError *error, MLAudioRecordButton *button) {
            [tipsView showWarning:@"发生错误，请重试" hideAfterDelay:1.5f];
        }];
    }
    return self;
}

- (void)dealloc
{
    [self.tipsView hide];
}

@end
