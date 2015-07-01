//
//  MLAudioRecordButton.h
//  MLVoice
//
//  Created by molon on 15/6/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MLAudioRecordButtonStatus) {
    MLAudioRecordButtonStatusNormal = 0, //按住 说话
    MLAudioRecordButtonStatusUpToComplete, //松开 结束
    MLAudioRecordButtonStatusUpToCancel, //松开 取消
};

@interface MLAudioRecordButton : UIButton

@property (readonly, nonatomic, assign) MLAudioRecordButtonStatus status;

//最小的有效时长，默认是0.5秒
@property (nonatomic, assign) NSTimeInterval minValidDuration;
//最大的时长，到这个时长自动停止，默认是120秒
@property (nonatomic, assign) NSTimeInterval maxDuration;
//最大的文件大小，到这个大小自动停止，默认是256KB
@property (nonatomic, assign) NSInteger maxFileSize;

@property (nonatomic, copy) NSURL *(^newFilePathBlock)(MLAudioRecordButton *button);

@property (nonatomic, copy) void(^didRecordTooShortAudioBlock)(NSURL *filePath,NSTimeInterval duration,MLAudioRecordButton *button);
@property (nonatomic, copy) void(^didRecordAudioBlock)(NSURL *filePath,NSTimeInterval duration,MLAudioRecordButton *button);
@property (nonatomic, copy) void(^volumeUpdatedBlock)(Float32 volume,MLAudioRecordButton *button);

@property (nonatomic, copy) void(^didReceiveErrorBlock)(NSError *error,MLAudioRecordButton *button);

@property (nonatomic, copy) void(^statusChangedBlock)(MLAudioRecordButtonStatus status,MLAudioRecordButton *button);


@property (nonatomic, copy) UIImage *(^backgroundImageBlock)(MLAudioRecordButtonStatus status,MLAudioRecordButton *button);
@property (nonatomic, copy) UIImage *(^imageBlock)(MLAudioRecordButtonStatus status,MLAudioRecordButton *button);
@property (nonatomic, copy) NSString *(^titleBock)(MLAudioRecordButtonStatus status,MLAudioRecordButton *button);

//外部代码停止
- (void)stopRecordingWithCancel:(BOOL)cancel;

@end
