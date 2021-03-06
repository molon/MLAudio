//
//  MLAudioPlayButton.m
//  CustomerPo
//
//  Created by molon on 8/15/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "MLAudioPlayButton.h"
#import "MLDataResponseSerializer.h"
#import "MLAmrPlayManager.h"
#import <AFNetworking.h>
#define AMR_MAGIC_NUMBER "#!AMR\n"

@interface MLAudioPlayButton()

@property (nonatomic, strong) AFHTTPRequestOperation *af_dataRequestOperation;

@property (nonatomic, strong) NSURL *audioURL;

@property (nonatomic, strong) NSURL *filePath;

@property (nonatomic, assign) MLAudioPlayButtonState audioState;

@end

@implementation MLAudioPlayButton

#pragma mark - cache
+ (MLDataCache*)sharedDataCache {
    return [MLDataCache shareInstance];
}

#pragma mark - cancel
- (void)cancelAudioRequestOperation {
    [self.af_dataRequestOperation cancel];
    self.af_dataRequestOperation = nil;
}

#pragma mark - life
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

- (void)setUp
{
    self.audioState = MLAudioPlayButtonStateNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReceiveStart:) name:MLAMRPLAYER_PLAY_RECEIVE_START_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReceiveStop:) name:MLAMRPLAYER_PLAY_RECEIVE_STOP_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReceiveError:) name:MLAMRPLAYER_PLAY_RECEIVE_ERROR_NOTIFICATION object:nil];
    
    [self addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - notification
- (void)playReceiveStart:(NSNotification*)notification
{
    if (![self isNotificationForMe:notification]) {
        return;
    }
    
    if (self.audioWillPlayBlock) {
        self.audioWillPlayBlock(self);
    }
}

- (void)playReceiveStop:(NSNotification*)notification
{
    if (![self isNotificationForMe:notification]) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    BOOL playComplete = [userInfo[@"playComplete"] boolValue];
    //    DLOG(@"发现音频播放停止:%@,如果发现此处执行多次不用在意。那可能是因为tableView复用的关系",[self.filePath path]);
    if (self.audioPlayStoppedBlock) {
        self.audioPlayStoppedBlock(self,playComplete);
    }
}

- (void)playReceiveError:(NSNotification*)notification
{
    if (![self isNotificationForMe:notification]) {
        return;
    }
    NSDictionary *userInfo = notification.userInfo;
    if (self.didReceivePlayErrorBlock) {
        self.didReceivePlayErrorBlock(userInfo[@"error"],self);
    }
}

- (BOOL)isNotificationForMe:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    return [userInfo[@"filePath"] isEqual:self.filePath];
}
            
#pragma mark - event
- (void)click
{
    if (!self.filePath) {
        return;
    }
    
    if (!self.isAudioPlaying) {
        [[MLAmrPlayManager manager]playWithFilePath:self.filePath extra:self.audioURL];
    }else{
        [[MLAmrPlayManager manager]stopPlaying];
    }
}

#pragma mark - getter
- (BOOL)isAudioPlaying
{
    if ([MLAmrPlayManager manager].isPlaying&&[[MLAmrPlayManager manager].filePath isEqual:self.filePath]) {
        return YES;
    }
    return NO;
}

#pragma mark - setter
- (void)setFilePath:(NSURL *)filePath
{
    _filePath = filePath;
    
    BOOL isSetedDuration = NO;
    if (filePath) {
        self.audioState = MLAudioPlayButtonStateNormal;
        if (!self.dontAutoSetDuration) {
            if (self.duration<=0) {
                self.duration = [MLAmrPlayManager durationOfAmrFilePath:filePath];
                isSetedDuration = YES;
            }
        }
    }else{
        self.audioState = MLAudioPlayButtonStateNone;
        if (!self.dontAutoSetDuration) {
            self.duration = 0.0f;
            isSetedDuration = YES;
        }
    }
    
    if (!isSetedDuration) {
        [self updatePreferredWidth];
    }
}

- (void)setAudioState:(MLAudioPlayButtonState)audioState
{
    _audioState = audioState;
    
    if (self.audioStateChangedBlock) {
        self.audioStateChangedBlock(audioState,self);
    }
}

- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    
    if (self.durationChangedBlock) {
        self.durationChangedBlock(duration,self);
    }
    
    [self updatePreferredWidth];
}

#pragma mark - outcall
- (void)setAudioWithURL:(NSURL*)url
{
    [self setAudioWithURL:url withAutoPlay:NO];
}

- (void)setAudioWithURL:(NSURL*)url withAutoPlay:(BOOL)autoPlay
{
    __weak __typeof(self)weakSelf = self;
    [self setAudioWithURL:url success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSURL *audioPath) {
        if (!weakSelf) {
            return;
        }
        
        if (!audioPath) {
            weakSelf.filePath = audioPath;
            return;
        }
        
        weakSelf.filePath = audioPath;
        if (autoPlay) {
            [[MLAmrPlayManager manager]playWithFilePath:weakSelf.filePath extra:weakSelf.audioURL];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        DLOG(@"%@",error);
        weakSelf.filePath = nil;
    }];
}

- (void)setAudioWithURL:(NSURL *)url success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL* audioPath))success
                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    //这里搞是因为我有可能传递进来的url是NSURL的子类，然后这个url如果经过[NSMutableURLRequest requestWithURL:url]再拿出来的话就被其内部转化成NSURL了。
    if ([url isFileURL]) {
        self.audioURL = url;
        self.filePath = nil;
        [self cancelAudioRequestOperation];
        
        if (success) {
            success(nil,nil,self.audioURL);
        }else{
            self.filePath = self.audioURL;
        }
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"*/*" forHTTPHeaderField:@"Accept"];
    
    [self setAudioWithURLRequest:request success:success failure:failure];
}

- (void)setAudioWithURLRequest:(NSURLRequest *)urlRequest success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSURL* audioPath))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    self.audioURL = [urlRequest URL];
    
    self.filePath = nil;
    [self cancelAudioRequestOperation];
    
    if ([self.audioURL isFileURL]) {
        if (success) {
            success(urlRequest, nil, self.audioURL);
        } else if (self.audioURL) {
            self.filePath = self.audioURL;
        }
        return;
    }
    
    if (nil==self.audioURL) {
        if (success) {
            success(urlRequest,nil,self.audioURL);
        }
        return;
    }
    
    NSURL *filePath = [[[self class] sharedDataCache] cachedFilePathForRequest:urlRequest];
    if (filePath) {
        if (success) {
            success(nil, nil, filePath);
        } else {
            self.filePath = filePath;
        }
        self.af_dataRequestOperation = nil;
    } else {
        self.audioState = MLAudioPlayButtonStateDownloading;
        
        DLOG(@"下载音频%@",[urlRequest URL]);
        __weak __typeof(self)weakSelf = self;
        self.af_dataRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
        self.af_dataRequestOperation.responseSerializer = [MLDataResponseSerializer shareInstance];
        [self.af_dataRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_dataRequestOperation.request URL]]) {
                
                static const char* amrHeader = AMR_MAGIC_NUMBER;
                char magic[8];
                [responseObject getBytes:magic length:strlen(amrHeader)];
                
                if (strncmp(magic, amrHeader, strlen(amrHeader)))
                {
                    strongSelf.audioState = MLAudioPlayButtonStateDownloadFailed;
                    NSError *error = [NSError errorWithDomain:kMLAudioPlayButtonErrorDomain code:MLAudioPlayButtonErrorCodeWrongAudioFormat userInfo:@{NSLocalizedDescriptionKey:@"音频非amr文件"}];
                    if (failure) {
                        failure(urlRequest,operation.response,error);
                    }
                    return;
                }
                
                //写入文件
                [[[strongSelf class] sharedDataCache] cacheData:responseObject forRequest:urlRequest afterCacheInFileSuccess:^(NSURL *filePath) {
                    //                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    if (success) {
                        success(urlRequest, operation.response, filePath);
                    } else if (filePath) {
                        strongSelf.filePath = filePath;
                    }
                    //                    });
                } failure:^{
                    strongSelf.audioState = MLAudioPlayButtonStateDownloadFailed;
                    NSError *error = [NSError errorWithDomain:kMLAudioPlayButtonErrorDomain code:MLAudioPlayButtonErrorCodeCacheFailed userInfo:@{NSLocalizedDescriptionKey:@"写入音频缓存文件失败"}];
                    if (failure) {
                        failure(urlRequest, operation.response, error);
                    }
                }];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if ([[urlRequest URL] isEqual:[strongSelf.af_dataRequestOperation.request URL]]) {
                strongSelf.audioState = MLAudioPlayButtonStateDownloadFailed;
                if (failure) {
                    failure(urlRequest, operation.response, error);
                }
            }
        }];
        
        [[MLDataResponseSerializer sharedDataRequestOperationQueue] addOperation:self.af_dataRequestOperation];
    }
}


#pragma mark - preferredWidth
- (CGFloat)preferredWidth
{
#define kMinDefaultWidth 50.0f
#define kMaxWidth 120.0f
    if (self.audioState != MLAudioPlayButtonStateNormal) {
        return kMinDefaultWidth;
    }
    
    CGFloat width = kMinDefaultWidth + (self.duration+0.5f)*5.0f;
    if (width>kMaxWidth) {
        width = kMaxWidth;
    }
    return width;
}

- (void)updatePreferredWidth
{
    if (self.preferredWidthChangedBlock) {
        CGFloat preferredWidth = [self preferredWidth];
        if (self.frame.size.width!= preferredWidth) {
            self.preferredWidthChangedBlock(preferredWidth,self);
        }
    }
}

@end
