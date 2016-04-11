//
//  ViewController.m
//  TestVideoDownloader
//
//  Created by Alexander on 14.03.16.
//  Copyright © 2016 RoadAR. All rights reserved.
//

#import "ViewController.h"
@import MediaPlayer;

@interface ViewController () <NSURLSessionDelegate, NSURLSessionDownloadDelegate>
{
    NSURLSession *session;
    NSURLSessionDownloadTask *downloadTask;
    MPMoviePlayerController *player;
    NSUserDefaults *userDefaults;
}
@property (nonatomic, weak) IBOutlet UIButton *dowloadButt;
@property (nonatomic, weak) IBOutlet UIButton *pauseDownloadButt;
@property (nonatomic, weak) IBOutlet UIButton *playButt;
@property (nonatomic, weak) IBOutlet UIButton *deleteButt;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIView *videoView;
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    player = [[MPMoviePlayerController alloc] init];
    player.controlStyle = MPMovieControlStyleEmbedded;
    player.view.frame = self.videoView.bounds;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.videoView addSubview:player.view];
    self.progressView.hidden = YES;
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    userDefaults = [NSUserDefaults standardUserDefaults];
    if (![self isFileExists]) {
        self.playButt.enabled = NO;
        self.deleteButt.enabled = NO;
        self.pauseDownloadButt.enabled = NO;
    }else {
        self.dowloadButt.enabled = NO;
        self.pauseDownloadButt.enabled = NO;
    }
    
}

- (BOOL)isFileExists {
    NSFileManager *filemgr;
    filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath:[self getDownloadPath] ] == YES)
        return YES;
    else
        return NO;
}

- (NSString *)getResumeDataPath {
    NSString *casheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [casheDir stringByAppendingString:@"resumeData.dat"];
}

- (NSString *)getDownloadPath {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docDir stringByAppendingPathComponent:@"video.mov"];
}

- (IBAction)startDownload {
    self.pauseDownloadButt.enabled = YES;
    self.deleteButt.enabled = NO;
    self.playButt.enabled = NO;
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/55523423/video.mov"];
    [UIApplication sharedApplication] .networkActivityIndicatorVisible = YES;
    self.progressView.hidden = NO;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[self getResumeDataPath]]) {
        NSLog(@"dataWasFounded");
        NSData *resumeData = [NSData dataWithContentsOfFile:[self getResumeDataPath]];
        downloadTask = [session downloadTaskWithResumeData:resumeData];
        [downloadTask resume];
    }else{
        downloadTask = [session downloadTaskWithURL:url];
        [downloadTask resume];
    }
}

- (IBAction)pauseDownload {
    if (downloadTask != nil) {
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [resumeData writeToFile:[self getResumeDataPath] atomically:YES];
        }];
        self.pauseDownloadButt.enabled = NO;
        [UIApplication sharedApplication] .networkActivityIndicatorVisible = NO;
    }
}

- (IBAction)deleteVideo {
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:[self getDownloadPath] error:nil];
    [manager removeItemAtPath:[self getResumeDataPath] error:nil];
    self.playButt.enabled = NO;
    self.deleteButt.enabled = NO;
    self.dowloadButt.enabled = YES;
    [player stop];
    self.progressView.progress = 0;
    NSLog([self isFileExists] ? @"Yes" : @"No");
    downloadTask = nil;
    
}

- (IBAction)playVideo:(id)sender {
    NSURL *myURl = [NSURL fileURLWithPath:[self getDownloadPath]];
    player.contentURL = myURl;
    [player play];
}

- (void)URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *downloadPath = [self getDownloadPath];
    NSURL *destinationURL = [NSURL fileURLWithPath:[self getDownloadPath]];
    if ([manager fileExistsAtPath:downloadPath]){
        [manager replaceItemAtURL:destinationURL withItemAtURL:location backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:nil];
    }else {
        [manager moveItemAtURL:location toURL:destinationURL error:nil];
    }
    self.playButt.enabled = YES;
    self.deleteButt.enabled = YES;
    self.dowloadButt.enabled = NO;
    self.pauseDownloadButt.enabled = NO;
    self.progressView.hidden = YES;
    [UIApplication sharedApplication] .networkActivityIndicatorVisible = NO;
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        self.progressView.progress = progress;
    NSLog(@"%f", progress );
}


@end
