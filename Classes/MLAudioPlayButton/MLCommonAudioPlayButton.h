//
//  MLCommonAudioPlayButton.h
//  Pods
//
//  Created by molon on 15/6/28.
//
//

#import "MLAudioPlayButton.h"

@interface MLCommonAudioPlayButton : MLAudioPlayButton

@property (nonatomic, readonly, strong) UIImageView *playingSignImageView;

/**
 *  自定义图像
 */
@property (nonatomic, copy) NSString *customBundleName;

//根据此区分语音播放的图标的指向
@property (nonatomic, assign) BOOL locationRight;

@end
