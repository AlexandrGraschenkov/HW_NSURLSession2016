//
//  ViewController.m
//  TestVideoDownloader
//
//  Created by Alexander on 14.03.16.
//  Copyright © 2016 RoadAR. All rights reserved.
//

#import "ViewController.h"
@import MediaPlayer;

@interface ViewController () <NSURLSessionDelegate>
{
    NSURLSession *session;
    NSURLSessionDownloadTask *downloadTask;
    MPMoviePlayerController *player;
}
@property (nonatomic, weak) IBOutlet UIButton *dowloadButt;
@property (nonatomic, weak) IBOutlet UIButton *pauseDownloadButt;
@property (nonatomic, weak) IBOutlet UIButton *playButt;
@property (nonatomic, weak) IBOutlet UIButton *deleteButt;
@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIView *videoView;

@property NSURL *videoURL;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    player = [[MPMoviePlayerController alloc] init];
    player.controlStyle = MPMovieControlStyleEmbedded;
    player.view.frame = self.videoView.bounds;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.videoView addSubview:player.view];
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.pauseDownloadButt.enabled = NO;
    self.pauseDownloadButt.alpha = 0.5;
    self.playButt.enabled = NO;
    self.playButt.alpha = 0.5;
    self.deleteButt.enabled = NO;
    self.deleteButt.alpha = 0.5;
}

- (NSString *)getDownloadPath {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docDir stringByAppendingPathComponent:@"video.mov"];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    if (location) {
        self.videoURL = [NSURL fileURLWithPath:self.getDownloadPath];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:self.videoURL error:nil];
        self.pauseDownloadButt.enabled = NO;
        self.pauseDownloadButt.alpha = 0.5;
        self.playButt.enabled = YES;
        self.playButt.alpha = 1;
        self.deleteButt.enabled = YES;
        self.deleteButt.alpha = 1;

    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    double progress = (double) (totalBytesWritten/1024) / (double) (totalBytesExpectedToWrite/1024);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress animated:NO];
    });
}

- (IBAction)startDownload {
    self.dowloadButt.enabled = NO;
    self.dowloadButt.alpha = 0.5;
    self.pauseDownloadButt.enabled = YES;
    self.pauseDownloadButt.alpha = 1;
    self.deleteButt.enabled = YES;
    self.deleteButt.alpha = 1;
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/55523423/video.mov"];
    if (!downloadTask && !self.videoURL) {
        downloadTask = [session downloadTaskWithRequest:[NSURLRequest requestWithURL:url]];
    }
    if (downloadTask.state != NSURLSessionTaskStateCompleted) {
        [downloadTask resume];
    }
}

- (IBAction)pauseDownload {
    [downloadTask suspend];
    self.pauseDownloadButt.enabled = NO;
    self.pauseDownloadButt.alpha = 0.5;
    self.dowloadButt.enabled = YES;
    self.dowloadButt.alpha = 1;
}

- (IBAction)deleteVideo {
    [[NSFileManager defaultManager] removeItemAtPath:self.videoURL.path error:nil];
    [downloadTask cancel];
    [player stop];
    [self.progressView setProgress:0 animated:NO];
    self.videoURL = nil;
    downloadTask = nil;
    self.pauseDownloadButt.enabled = NO;
    self.pauseDownloadButt.alpha = 0.5;
    self.playButt.enabled = NO;
    self.playButt.alpha = 0.5;
    self.deleteButt.enabled = NO;
    self.deleteButt.alpha = 0.5;
    self.dowloadButt.enabled = YES;
    self.dowloadButt.alpha = 1;
}

- (IBAction)playVideo:(id)sender {
    [player setContentURL:self.videoURL];
    [player play];
    self.playButt.enabled = NO;
    self.playButt.alpha = 0.5;
}

@end
