//
//  MLAudioRecordTipsView.m
//  MLVoice
//
//  Created by molon on 15/6/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "MLAudioRecordTipsView.h"


#define BUNDLEIMG(o) [UIImage imageNamed:[@"MLAudioWeChatStyleTipsImages.bundle" stringByAppendingPathComponent:(o)]]

@interface MLAudioRecordWeChatStyleTipsView()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *volumeImageView;

@property (nonatomic, assign) MLAudioRecordButtonStatus status;
@property (nonatomic, copy) NSString *warningText;

@end

@implementation MLAudioRecordWeChatStyleTipsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if (CGRectIsEmpty(frame)){
            self.frame = CGRectMake(0, 0, 150.0f, 150.0f);
        }
        
        self.layer.cornerRadius = 8.0f;
        self.layer.backgroundColor = [UIColor colorWithWhite:0.053 alpha:0.550].CGColor;
        
        [self addSubview:self.tipsLabel];
        [self addSubview:self.imageView];
        [self addSubview:self.volumeImageView];
    }
    return self;
}

- (void)dealloc
{
    //DLOG(@"dealloc %@",NSStringFromClass([self class]));
}

#pragma mark - getter
- (UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        UILabel* label = [[UILabel alloc]init];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14.0f];
        label.layer.cornerRadius = 4.0f;
        label.textAlignment = NSTextAlignmentCenter;
        label.clipsToBounds = YES;
        
        _tipsLabel = label;
    }
    return _tipsLabel;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        //        imageView.backgroundColor = [UIColor blackColor];
        _imageView = imageView;
    }
    return _imageView;
}

- (UIImageView *)volumeImageView
{
    if (!_volumeImageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        _volumeImageView = imageView;
    }
    return _volumeImageView;
}

#pragma mark - setter
- (void)setStatus:(MLAudioRecordButtonStatus)status
{
    _status = status;
    
    self.hidden = status==MLAudioRecordButtonStatusNormal;
    if (self.hidden) {
        [self removeFromSuperview];
    }else{
        UIWindow *window = [self getMainWindow];
        if (![self.superview isEqual:window]) {
            [self removeFromSuperview];
            [window addSubview:self];
        }
        
        self.center = CGPointMake(CGRectGetWidth(window.bounds)/2, (CGRectGetHeight(window.bounds)-44.0f)/2);
    }
    
    self.volumeImageView.hidden = status!=MLAudioRecordButtonStatusUpToComplete;
    
    self.tipsLabel.textColor = [UIColor colorWithWhite:0.787 alpha:1.000];
    self.tipsLabel.backgroundColor = [UIColor clearColor];
    
    //这里为了方便对warning的处理偷懒，直接插一杠子
    if (self.warningText) {
        self.tipsLabel.text = self.warningText;
        self.imageView.image = BUNDLEIMG(@"RecordWarning");
    }else{
        if (status==MLAudioRecordButtonStatusUpToComplete) {
            self.tipsLabel.text = @"手指上滑，取消发送";
            self.imageView.image = BUNDLEIMG(@"RecordingBkg");
        }else if(status==MLAudioRecordButtonStatusUpToCancel){
            self.tipsLabel.textColor = [UIColor whiteColor];
            self.tipsLabel.backgroundColor = [UIColor colorWithRed:0.794 green:0.000 blue:0.007 alpha:0.460];
            self.tipsLabel.text = @"松开手指，取消发送";
            self.imageView.image = BUNDLEIMG(@"RecordCancel");
        }else{
            self.tipsLabel.text = @"";
        }
    }
    [self setNeedsLayout];
    
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
#define kTipsLabelHeight 20.0f
#define kXSpacing 5.0f
    self.tipsLabel.frame = CGRectMake(kXSpacing, height-kTipsLabelHeight-10.0f, width-kXSpacing*2, kTipsLabelHeight);
    
    CGFloat yOffset = 5.0f;
    if (self.status==MLAudioRecordButtonStatusUpToComplete) {
        self.imageView.frame = CGRectMake(width/2-self.imageView.image.size.width+15.0f, ((height-kTipsLabelHeight-10.0f)-self.imageView.image.size.height)/2+yOffset, self.imageView.image.size.width, self.imageView.image.size.height);
        
        
        self.volumeImageView.frame = CGRectMake(CGRectGetMaxX(self.imageView.frame), ((height-kTipsLabelHeight-10.0f)-self.volumeImageView.image.size.height)/2+yOffset, self.volumeImageView.image.size.width, self.volumeImageView.image.size.height);
    }else{
        self.imageView.frame = CGRectMake((width-self.imageView.image.size.width)/2, ((height-kTipsLabelHeight-10.0f)-self.imageView.image.size.height)/2+yOffset, self.imageView.image.size.width, self.imageView.image.size.height);
    }
    
}

#pragma mark - helper
- (UIWindow*)getMainWindow
{
//    return [UIApplication sharedApplication].delegate.window;
    
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication]windows] reverseObjectEnumerator];
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    for (UIWindow *window in frontToBackWindows) {
        if (window.screen == mainScreen && window.windowLevel == UIWindowLevelNormal && !window.hidden) {
            return window;
        }
    }
    return nil;
}

#pragma mark - outcall
- (void)showWithMLAudioRecordButtonStatus:(MLAudioRecordButtonStatus)status volume:(Float32)volume
{
    self.warningText = nil;
    
    //设置下音量图像
    NSInteger level = floor((volume*10)/(10/8))+1;
    level = MIN(8, level);
    level = MAX(level, 1);
    
    NSString *imageName = [NSString stringWithFormat:@"RecordingSignal00%ld",(long)level];
    self.volumeImageView.image = BUNDLEIMG(imageName);
    
    self.status = status;
}

- (void)hide
{
    //这时候本身就应该隐藏掉
    [self showWithMLAudioRecordButtonStatus:MLAudioRecordButtonStatusNormal volume:0];
}

- (void)showWarning:(NSString*)warningText hideAfterDelay:(NSTimeInterval)delay
{
    self.warningText = warningText;
    //布局和upToCancel一样的。
    self.status = MLAudioRecordButtonStatusUpToCancel;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //这里检测是否在delay中没有进行其他操作
        if ([warningText isEqualToString:self.warningText]){
            [self hide];
        }
    });
    
}


@end
