//
//  MLAudioPlayButton.h
//  CustomerPo
//
//  Created by molon on 8/15/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLDataCache.h"

#define kMLAudioPlayButtonErrorDomain @"MLAudioPlayButtonErrorDomain"
/**
 *  错误标识
 */
typedef NS_OPTIONS(NSUInteger, MLAudioPlayButtonErrorCode) {
    MLAudioPlayButtonErrorCodeCacheFailed = 0, //写入缓存文件失败
    MLAudioPlayButtonErrorCodeWrongAudioFormat,//音频文件格式错误
};

typedef NS_OPTIONS(NSUInteger, MLAudioPlayButtonState) {
    MLAudioPlayButtonStateNone = 0,
    MLAudioPlayButtonStateNormal,
    MLAudioPlayButtonStateDownloading,
    MLAudioPlayButtonStateDownloadFailed,
};

@interface MLAudioPlayButton : UIButton

@property (nonatomic, strong,readonly) NSURL *audioURL;
@property (nonatomic, assign,readonly) MLAudioPlayButtonState audioState;
@property (nonatomic, assign,readonly) BOOL isAudioPlaying;

//是否自动读取duration
@property (nonatomic, assign) BOOL dontAutoSetDuration;

@property (nonatomic, assign) NSTimeInterval duration;

@property (nonatomic, copy) void(^durationChangedBlock)(double duration,MLAudioPlayButton *button);
@property (nonatomic, copy) void(^audioStateChangedBlock)(MLAudioPlayButtonState audioState,MLAudioPlayButton *button);
@property (nonatomic, copy) void(^preferredWidthChangedBlock)(CGFloat preferredWidth,MLAudioPlayButton *button);
@property (nonatomic, copy) void(^audioWillPlayBlock)(MLAudioPlayButton *button);
@property (nonatomic, copy) void(^audioPlayStoppedBlock)(MLAudioPlayButton *button,BOOL playComplete);
@property (nonatomic, copy) void(^didReceivePlayErrorBlock)(NSError *error,MLAudioPlayButton *button);

- (CGFloat)preferredWidth;

#pragma mark - cache
+ (MLDataCache*)sharedDataCache;

#pragma mark - cancel
- (void)cancelAudioRequestOperation;

#pragma mark - set audio
- (void)setAudioWithURL:(NSURL*)url;
- (void)setAudioWithURL:(NSURL*)url withAutoPlay:(BOOL)autoPlay;

- (void)setAudioWithURL:(NSURL *)url success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL* audioPath))success
                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)setAudioWithURLRequest:(NSURLRequest *)urlRequest success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL* audioPath))success
                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;



- (BOOL)isNotificationForMe:(NSNotification*)notification;
@end
