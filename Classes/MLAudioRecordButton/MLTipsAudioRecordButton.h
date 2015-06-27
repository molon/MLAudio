//
//  MLTipsAudioRecordButton.h
//  MLVoice
//
//  Created by molon on 15/6/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLAudioRecordButton.h"
#import "MLAudioRecordTipsView.h"

@interface MLTipsAudioRecordButton : MLAudioRecordButton

- (instancetype)initWithMLAudioRecordTipsView:(id<MLAudioRecordTipsViewDelegate>)tipsView;

@end
