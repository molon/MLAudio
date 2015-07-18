//
//  MLAmrPlayManager.m
//
//  Created by molon on 8/15/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLAmrPlayManager.h"
#import "MLAudioPlayer.h"
#import "AmrPlayerReader.h"

@interface MLAmrPlayManager()

@property (nonatomic, strong) MLAudioPlayer *player;
@property (nonatomic, strong) AmrPlayerReader *amrReader;

@property (nonatomic, strong) NSURL *filePath;

@end

@implementation MLAmrPlayManager

+ (instancetype)manager {
    static MLAmrPlayManager *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [MLAmrPlayManager new];
    });
    return _shareInstance;
}

#pragma mark - life
- (void)dealloc
{
	[_player stopPlaying];
}

#pragma mark - getter
- (MLAudioPlayer *)player
{
	if (!_player) {
		_player = [MLAudioPlayer new];
        _player.fileReaderDelegate = self.amrReader;
        
        __weak __typeof(self)weakSelf = self;
        _player.receiveErrorBlock = ^(NSError *error){
            if (!weakSelf.filePath) {
                return;
            }
            //这里应该post 一个通知，通知音频播放错误
            NSURL *filePath = weakSelf.filePath;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter]postNotificationName:MLAMRPLAYER_PLAY_RECEIVE_ERROR_NOTIFICATION object:nil userInfo:@{@"error":error,@"filePath":filePath}];
            });
        };
        _player.receiveStoppedBlock = ^{
            if (!weakSelf.filePath) {
                return;
            }
            NSURL *filePath = weakSelf.filePath;
            dispatch_async(dispatch_get_main_queue(), ^{
                //因为下面的playWithFilePath方法是先stop然后start，如果不放到下一个runloop里的话，这里被通知的对象可能会执行一个新的playWithFilePath方法就造成了。 stop -> stop,start ->start的情况，就出BUG了。而放到下一个runloop里就不怕了。
                //这里应该post 一个通知，通知音频播放完毕
                [[NSNotificationCenter defaultCenter]postNotificationName:MLAMRPLAYER_PLAY_RECEIVE_STOP_NOTIFICATION object:nil userInfo:@{@"filePath":filePath}];
            });
        };
	}
	return _player;
}

- (AmrPlayerReader *)amrReader
{
	if (!_amrReader) {
		_amrReader = [AmrPlayerReader new];
		
	}
	return _amrReader;
}

- (BOOL)isPlaying
{
	return self.player.isPlaying;
}

#pragma mark - setter
- (void)setFilePath:(NSURL *)filePath
{
    _filePath = filePath;

    self.amrReader.filePath = [filePath path];
}

#pragma mark - outcall
- (void)playWithFilePath:(NSURL*)filePath
{
    [self.player stopPlaying];
    self.filePath = filePath;
    [self.player startPlaying];
}

- (void)stopPlaying
{
    [self.player stopPlaying];
    self.filePath = nil;
}

#pragma mark - other
+ (double)durationOfAmrFilePath:(NSURL*)filePath
{
    return [AmrPlayerReader durationOfAmrFilePath:[filePath path]];
}
@end
