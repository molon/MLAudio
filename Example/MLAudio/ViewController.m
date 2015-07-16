//
//  ViewController.m
//  MLVoice
//
//  Created by molon on 15/6/27.
//  Copyright (c) 2015年 molon. All rights reserved.
//

#import "ViewController.h"
#import "MLTipsAudioRecordButton.h"
#import "MLCommonAudioPlayButton.h"

#define kAudioDirName @"audioData"

@interface ViewController ()

@property (nonatomic, strong) MLTipsAudioRecordButton *recordButton;
@property (nonatomic, strong) MLCommonAudioPlayButton *playButton;
@property (nonatomic, strong) MLCommonAudioPlayButton *playLocalButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"语音测试";
    self.view.backgroundColor = [UIColor colorWithRed:0.898 green:0.902 blue:0.906 alpha:1.000];
    
    [self.view addSubview:self.recordButton];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.playLocalButton];
    
    
    [self.playButton setAudioWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/molon/MLAudioRecorder/master/record1.amr"]];
    
    //    self.playButton.type = MLAudioPlayButtonTypeRight;
    //    [self.playButton setVoiceWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/molon/MLAudioRecorder/master/record2.amr"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.playButton.frame = CGRectMake(20, 100, [self.playButton preferredWidth], 40);
    
    CGFloat preferredWidth = [self.playLocalButton preferredWidth];
    self.playLocalButton.frame = CGRectMake(self.view.bounds.size.width-20-preferredWidth, CGRectGetMaxY(self.playButton.frame)+20.0f, preferredWidth, 40.0f);
    
    self.recordButton.frame = CGRectMake(10, self.view.frame.size.height-65, self.view.frame.size.width-10*2, 60);
}

#pragma mark - getter
- (MLTipsAudioRecordButton *)recordButton
{
    if (!_recordButton) {
        MLAudioRecordWeChatStyleTipsView *tipsView = [MLAudioRecordWeChatStyleTipsView new];
        MLTipsAudioRecordButton *button = [[MLTipsAudioRecordButton alloc]initWithMLAudioRecordTipsView:tipsView];
        //        button.maxDuration = 5;
        //        button.maxFileSize = 5*1024;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        __weak __typeof(self)weakSelf = self;
        [button setBackgroundImageBlock:^UIImage *(MLAudioRecordButtonStatus status, MLAudioRecordButton *button) {
            if (status == MLAudioRecordButtonStatusNormal) {
                return [[UIImage imageNamed:@"VoiceBtn_Black"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            }else{
                return [[UIImage imageNamed:@"VoiceBtn_BlackHL"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
            }
        }];
        [button setTitleBock:^NSString *(MLAudioRecordButtonStatus status, MLAudioRecordButton *button) {
            return @[@"按住 说话",@"松开 结束",@"松开 取消"][status];
        }];
        
        [button setDidRecordAudioBlock:^(NSURL *url, NSTimeInterval duration, MLAudioRecordButton *button) {
            [weakSelf.playLocalButton setAudioWithURL:url];
        }];
        
        [button setNewFilePathBlock:^NSURL *(MLAudioRecordButton *button) {
            NSSearchPathDirectory searchDir = NSDocumentDirectory;
            NSSearchPathDomainMask searchMask = NSUserDomainMask;
            
            //这里检测是否存在此文件夹，不存在就建立
            NSArray *paths = NSSearchPathForDirectoriesInDomains(searchDir, searchMask, YES);
            NSString *audioDir = [[paths firstObject] stringByAppendingPathComponent:kAudioDirName];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:audioDir]){
                if([[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:NULL]){
//                    [[NSFileManager defaultManager]addSkipBackupAttributeToItemAtPath:audioDir];
                }
            }
            
            //设置一个新文件名字
            time_t curUnixTime = 0;
            time(&curUnixTime);
            NSString *key = [NSString stringWithFormat:@"%ld-%ld", curUnixTime,(NSInteger)(arc4random()%10000)];
            NSURL *url = [NSURL fileURLWithPath:[audioDir stringByAppendingPathComponent:key] isDirectory:NO];
            return url;
        }];
        _recordButton = button;
        
    }
    return _recordButton;
}

- (MLCommonAudioPlayButton *)playButton
{
    if (!_playButton) {
        _playButton = [MLCommonAudioPlayButton new];
        [_playButton setBackgroundImage:[[UIImage imageNamed:@"Receiver背景"]resizableImageWithCapInsets:UIEdgeInsetsMake(28, 12.5f, 5, 5)] forState:UIControlStateNormal];
        [_playButton setPreferredWidthChangedBlock:^(CGFloat preferredWidth,MLAudioPlayButton *button) {
            CGRect frame = button.frame;
            frame.size.width = preferredWidth;
            button.frame = frame;
        }];
        
    }
    return _playButton;
}

- (MLCommonAudioPlayButton *)playLocalButton
{
    if (!_playLocalButton) {
        _playLocalButton = [MLCommonAudioPlayButton new];
        _playLocalButton.locationRight = YES;
        [_playLocalButton setBackgroundImage:[[UIImage imageNamed:@"Sender背景"]resizableImageWithCapInsets:UIEdgeInsetsMake(28, 5, 5, 12.5f)] forState:UIControlStateNormal];
        [_playLocalButton setPreferredWidthChangedBlock:^(CGFloat preferredWidth,MLAudioPlayButton *button) {
            CGRect frame = button.frame;
            frame.origin.x -= preferredWidth-frame.size.width;
            frame.size.width = preferredWidth;
            button.frame = frame;
        }];
        
    }
    return _playLocalButton;
}

@end
