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
    
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
}

- (NSString *)getDownloadPath {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docDir stringByAppendingPathComponent:@"video.mov"];
}

- (IBAction)startDownload {
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/55523423/video.mov"];
    downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

- (IBAction)pauseDownload {
    // todo
}

- (IBAction)deleteVideo {
    // todo
}

- (IBAction)playVideo:(id)sender {
    player.
//    player.contentURL =[NSURL URLWithString: @"https://dl.dropboxusercontent.com/u/55523423/video.mov"];
    [player play];
}

-(void)URLSession:(NSURLSession *)session
             downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSFileManager *manager = [NSFileManager defaultManager];
        NSData *videoData = [NSData dataWithContentsOfURL:location];
        NSString *downloadPath = [self getDownloadPath];
        if ([manager fileExistsAtPath:downloadPath]){
            [manager createFileAtPath:downloadPath contents:videoData attributes:nil];
        }else {
            [manager createDirectoryAtPath:downloadPath withIntermediateDirectories:NO attributes:nil error:nil];
            [manager createFileAtPath:downloadPath contents:videoData attributes:nil];
        }
    });
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
}


@end
