//
//  MLAmrPlayManager.h
//
//  Created by molon on 8/15/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MLAMRPLAYER_PLAY_RECEIVE_ERROR_NOTIFICATION @"MLAMRPLAYER_PLAY_RECEIVE_ERROR_NOTIFICATION"
#define MLAMRPLAYER_PLAY_RECEIVE_STOP_NOTIFICATION @"MLAMRPLAYER_PLAY_RECEIVE_STOP_NOTIFICATION"
#define MLAMRPLAYER_PLAY_RECEIVE_START_NOTIFICATION @"MLAMRPLAYER_PLAY_RECEIVE_START_NOTIFICATION"

@interface MLAmrPlayManager : NSObject

@property (nonatomic, strong,readonly) NSURL *filePath;
@property (nonatomic, assign,readonly) BOOL isPlaying;

+ (instancetype)manager;
+ (double)durationOfAmrFilePath:(NSURL*)filePath;

- (void)playWithFilePath:(NSURL*)filePath extra:(id)extra;
- (void)stopPlaying;

@end
