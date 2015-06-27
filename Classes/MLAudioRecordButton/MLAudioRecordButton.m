//
//  MLAudioRecordButton.m
//  MLVoice
//
//  Created by molon on 15/6/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLAudioRecordButton.h"
#import "MLAudioRecorder.h"
#import "AmrRecordWriter.h"
#import "MLAudioMeterObserver.h"
#import "AmrPlayerReader.h"
#import "MLAmrPlayManager.h"

@interface MLAudioRecordButton()

@property (nonatomic, assign) MLAudioRecordButtonStatus status;

@property (nonatomic, strong) MLAudioRecorder *recorder;
@property (nonatomic, strong) AmrRecordWriter *amrWriter;
@property (nonatomic, strong) MLAudioMeterObserver *meterObserver;

@property (nonatomic, assign) BOOL isStopBecauseCancel;

@end

@implementation MLAudioRecordButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.minValidDuration = 0.5;
        self.maxFileSize = 256*1024;
        self.maxDuration = 120.0f;
        self.exclusiveTouch = YES;
        
        //监测这些事件
        [self addTarget:self action:@selector(dragEnter) forControlEvents:UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(dragExit) forControlEvents:UIControlEventTouchDragExit];
        
        [self addTarget:self action:@selector(upOutSide) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(upInside) forControlEvents:UIControlEventTouchUpInside];
        
        [self addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchCancel];
        [self addTarget:self action:@selector(down) forControlEvents:UIControlEventTouchDown];
        
        //一些block回调，牵扯到weakSelf的回调不适合放到getter里
        __weak __typeof(self)weakSelf = self;
        self.recorder.receiveStoppedBlock = ^{
            __strong __typeof(weakSelf)sSelf = weakSelf;
            sSelf.status = MLAudioRecordButtonStatusNormal;
            
            if (!sSelf.isStopBecauseCancel) {
                NSTimeInterval duration = [AmrPlayerReader durationOfAmrFilePath:sSelf.amrWriter.filePath];
                if (duration<self.minValidDuration) {
                    if (sSelf.didRecordTooShortAudioBlock) {
                        sSelf.didRecordTooShortAudioBlock([NSURL fileURLWithPath:sSelf.amrWriter.filePath],duration,sSelf);
                    }
                }else{
                    if (sSelf.didRecordAudioBlock) {
                        sSelf.didRecordAudioBlock([NSURL fileURLWithPath:sSelf.amrWriter.filePath],duration,sSelf);
                    }
                }
            }
            sSelf.meterObserver.audioQueue = nil;
            sSelf.enabled = YES;
        };
        self.recorder.receiveErrorBlock = ^(NSError *error){
            __strong __typeof(weakSelf)sSelf = weakSelf;
            sSelf.status = MLAudioRecordButtonStatusNormal;
            
            if (sSelf.didReceiveErrorBlock) {
                sSelf.didReceiveErrorBlock(error,sSelf);
            }
            
            sSelf.meterObserver.audioQueue = nil;
            sSelf.enabled = YES;
        };
        
        self.meterObserver.actionBlock = ^(NSArray *levelMeterStates,MLAudioMeterObserver *meterObserver){
            __strong __typeof(weakSelf)sSelf = weakSelf;
            if (sSelf.volumeUpdatedBlock) {
                sSelf.volumeUpdatedBlock([MLAudioMeterObserver volumeForLevelMeterStates:levelMeterStates],sSelf);
            }
        };
        self.meterObserver.errorBlock = ^(NSError *error,MLAudioMeterObserver *meterObserver){
            __strong __typeof(weakSelf)sSelf = weakSelf;
            
            if (sSelf.didReceiveErrorBlock) {
                sSelf.didReceiveErrorBlock(error,sSelf);
            }
        };
        
    }
    return self;
}

- (void)dealloc
{
    self.meterObserver.audioQueue = nil;
    [self.recorder stopRecording];
}

#pragma mark - getter

- (MLAudioRecorder *)recorder
{
    if (!_recorder) {
        _recorder = [MLAudioRecorder new];
        _recorder.fileWriterDelegate = self.amrWriter;
        _recorder.bufferDurationSeconds = 0.25f;
    }
    return _recorder;
}

- (AmrRecordWriter *)amrWriter
{
    if (!_amrWriter) {
        _amrWriter = [AmrRecordWriter new];
        _amrWriter.maxSecondCount = self.maxDuration;
        _amrWriter.maxFileSize = self.maxFileSize;
    }
    return _amrWriter;
}

- (MLAudioMeterObserver *)meterObserver
{
    if (!_meterObserver) {
        _meterObserver = [MLAudioMeterObserver new];
    }
    return _meterObserver;
}

#pragma mark - setter
- (void)setMaxDuration:(NSTimeInterval)maxDuration
{
    _maxDuration = maxDuration;
    
    self.amrWriter.maxSecondCount = maxDuration;
}

- (void)setMaxFileSize:(NSInteger)maxFileSize
{
    _maxFileSize = maxFileSize;
    
    self.amrWriter.maxFileSize = maxFileSize;
}

- (void)setStatus:(MLAudioRecordButtonStatus)status
{
    MLAudioRecordButtonStatus origStatus = _status;
    
    _status = status;
    
    [self refreshTitle];
    [self refreshImage];
    [self refreshBackgroundImage];
    
    if (origStatus!=status&&self.statusChangedBlock) {
        self.statusChangedBlock(status,self);
    }
}

- (void)setBackgroundImageBlock:(UIImage *(^)(MLAudioRecordButtonStatus, MLAudioRecordButton *))backgroundImageBlock
{
    _backgroundImageBlock = backgroundImageBlock;
    [self refreshBackgroundImage];
}

- (void)setImageBlock:(UIImage *(^)(MLAudioRecordButtonStatus, MLAudioRecordButton *))imageBlock
{
    _imageBlock = imageBlock;
    [self refreshImage];
}

- (void)setTitleBock:(NSString *(^)(MLAudioRecordButtonStatus, MLAudioRecordButton *))titleBock
{
    _titleBock = titleBock;
    [self refreshTitle];
}

#pragma mark - helper
- (void)refreshTitle
{
    if (self.titleBock) {
        [self setTitle:self.titleBock(self.status,self) forState:UIControlStateNormal];
    }
}

- (void)refreshBackgroundImage
{
    if (self.backgroundImageBlock) {
        UIImage *backImage = self.backgroundImageBlock(self.status,self);
        [self setBackgroundImage:backImage forState:UIControlStateNormal];
        [self setBackgroundImage:backImage forState:UIControlStateHighlighted];
        [self setBackgroundImage:backImage forState:UIControlStateDisabled];
    }
}

- (void)refreshImage
{
    if (self.imageBlock) {
        UIImage *image = self.imageBlock(self.status,self);
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:image forState:UIControlStateHighlighted];
        [self setImage:image forState:UIControlStateDisabled];
    }
}

- (NSString*)filePathForKey:(NSString*)key
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths[0] stringByAppendingPathComponent:kAudioCacheDirName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDir]){
        NSError *error = nil;
        if(![[NSFileManager defaultManager] createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:&error]){
            if (self.didReceiveErrorBlock) {
                self.didReceiveErrorBlock(error,self);
            }
            return nil;
        }
    }
    
    return [cacheDir stringByAppendingPathComponent:key];
}

#pragma mark - event
- (void)dragEnter
{
    if (self.status==MLAudioRecordButtonStatusUpToCancel) {
        self.status = MLAudioRecordButtonStatusUpToComplete;
    }
}

- (void)dragExit
{
    if (self.status==MLAudioRecordButtonStatusUpToComplete) {
        self.status = MLAudioRecordButtonStatusUpToCancel;
    }
}

- (void)upOutSide
{
    [self cancel];
}

- (void)cancel
{
    [self stopRecordingWithCancel:YES];
}

- (void)down
{
    //录音和播放肯定不应该同时啦，把已有播放停止
    [[MLAmrPlayManager manager]stopPlaying];
    
    //必须在此重置下
    self.isStopBecauseCancel = NO;
    
    //用当前时间做文件名
    time_t curUnixTime = 0;
    time(&curUnixTime);
    NSString *key = [NSString stringWithFormat:@"%ld-%d.amr", curUnixTime,arc4random()%10000];
    NSString *filePath = [self filePathForKey:key];
    self.amrWriter.filePath = filePath;
    
    [self.recorder startRecording];
    self.meterObserver.audioQueue = self.recorder->_audioQueue;
    
    //松开 结束
    self.status = MLAudioRecordButtonStatusUpToComplete;
}

- (void)upInside
{
    [self stopRecordingWithCancel:NO];
}

- (void)stopRecordingWithCancel:(BOOL)cancel
{
    if (!self.recorder.isRecording) {
        //因为有可能因为意外，例如长度太长已经停止了,
        return;
    }
    
    self.isStopBecauseCancel = cancel;
    
    self.enabled = NO;
    double delayInSeconds = 0.4f;
    if (cancel) {
        delayInSeconds = 0.2f;
    }
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.recorder stopRecording];
    });
    
}
@end
