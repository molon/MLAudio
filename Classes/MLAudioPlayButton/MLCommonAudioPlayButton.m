//
//  MLCommonAudioPlayButton.m
//  Pods
//
//  Created by molon on 15/6/28.
//
//

#import "MLCommonAudioPlayButton.h"
#import "MLAudioPlayButton+Override.h"

@interface MLCommonAudioPlayButton()

@property (nonatomic, strong) UIImageView *playingSignImageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation MLCommonAudioPlayButton

- (void)setUp
{
    [super setUp];
    
    [self addSubview:self.playingSignImageView];
    [self addSubview:self.indicator];
    
    [self updatePlayingSignImage];
}

#pragma mark - notification

- (void)playReceiveStart:(NSNotification *)notification
{
    [super playReceiveStart:notification];
    if (![self isNotificationForMe:notification]) {
        return;
    }
    [self updatePlayingSignImage];
}

- (void)playReceiveStop:(NSNotification*)notification
{
    [super playReceiveStop:notification];
    if (![self isNotificationForMe:notification]) {
        return;
    }
    [self updatePlayingSignImage];
}

- (void)playReceiveError:(NSNotification*)notification
{
    [super playReceiveError:notification];
    if (![self isNotificationForMe:notification]) {
        return;
    }
    [self updatePlayingSignImage];
}

#pragma mark - getter

- (UIImageView *)playingSignImageView
{
    if (!_playingSignImageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _playingSignImageView = imageView;
    }
    return _playingSignImageView;
}

- (UIActivityIndicatorView *)indicator
{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
    }
    return _indicator;
}

#pragma mark - setter
- (void)setLocationRight:(BOOL)locationLeft
{
    _locationRight = locationLeft;
    
    [self updatePlayingSignImage];
    
    [self setNeedsLayout];
}

- (void)setAudioState:(MLAudioPlayButtonState)audioState
{
    [super setAudioState:audioState];
    
    //如果none啥都没，
    if (audioState == MLAudioPlayButtonStateNone) {
        [self.indicator stopAnimating];
        self.playingSignImageView.hidden = YES;
    }else if (audioState == MLAudioPlayButtonStateDownloading){
        [self.indicator startAnimating];
        self.playingSignImageView.hidden = YES;
    }else if (audioState == MLAudioPlayButtonStateNormal){
        self.playingSignImageView.hidden = NO;
        [self.indicator stopAnimating];
        [self updatePlayingSignImage];
    }
}

- (void)setCustomBundleName:(NSString *)customBundleName
{
    _customBundleName = [customBundleName copy];
    
    [self updatePlayingSignImage];
}

#pragma mark - helper
- (void)updatePlayingSignImage
{
    self.playingSignImageView.image = nil;
    if (self.audioState!=MLAudioPlayButtonStateNormal) {
        return;
    }
    
    NSString *bundleName = self.customBundleName;
    if (!bundleName) {
        bundleName = @"MLPlayAudioButtonImages.bundle";
    }
    
    NSString *prefix = self.locationRight?@"Sender音频播放00":@"Receiver音频播放00";
    if (self.isAudioPlaying) {
        UIImage *image = [UIImage animatedImageNamed:[bundleName stringByAppendingPathComponent:prefix] duration:1.0f];
        self.playingSignImageView.image = image;
    }else{
        NSString *imageName = self.locationRight?@"Sender音频未播放":@"Receiver音频未播放";
        UIImage *image = [UIImage imageNamed:[bundleName stringByAppendingPathComponent:imageName]];
        self.playingSignImageView.image = image;
    }
}


#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
#define kVoicePlaySignSideLength 17.0f
    if (self.locationRight) {
        self.playingSignImageView.frame = CGRectMake(self.frame.size.width-kVoicePlaySignSideLength-15.0f, (self.frame.size.height-kVoicePlaySignSideLength)/2, kVoicePlaySignSideLength, kVoicePlaySignSideLength);
    }else{
        self.playingSignImageView.frame = CGRectMake(15.0f, (self.frame.size.height-kVoicePlaySignSideLength)/2, kVoicePlaySignSideLength, kVoicePlaySignSideLength);
    }
    
    self.indicator.frame = self.playingSignImageView.frame;
}

@end
