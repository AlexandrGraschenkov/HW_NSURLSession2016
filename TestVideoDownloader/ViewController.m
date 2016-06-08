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



-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *destinationURL = [NSURL fileURLWithPath:[self getPath]];
    if ([manager fileExistsAtPath:[self getPath]]){
        [manager replaceItemAtURL:destinationURL withItemAtURL:location backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:nil];
    }
    else [manager moveItemAtURL:location toURL:destinationURL error:nil];
    [UIApplication sharedApplication] .networkActivityIndicatorVisible = NO;
    [self setButtonsEnabled:@"download"];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    self.progressView.progress = progress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    player = [[MPMoviePlayerController alloc] init];
    player.controlStyle = MPMovieControlStyleEmbedded;
    player.view.frame = self.videoView.bounds;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.videoView addSubview:player.view];
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    userDefaults = [NSUserDefaults standardUserDefaults];
    [self setButtonsEnabled:@"delete"];
    
}


-(BOOL)fileAlreadyLoad{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    return  [filemanager fileExistsAtPath:[self getPath]] ?  YES : NO;
}

- (NSString *)getPath {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docDir stringByAppendingPathComponent:@"video.mov"];
}

- (NSString *)getDataPath {
    NSString *casheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [casheDir stringByAppendingString:@"data.dat"];
}

- (IBAction)startDownload {
    [UIApplication sharedApplication] .networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/55523423/video.mov"];
    if ([self fileAlreadyLoad]) {
        NSData *resumeData = [NSData dataWithContentsOfFile:[self getDataPath]];
        downloadTask = [session downloadTaskWithResumeData:resumeData];
    }
    else{
        downloadTask = [session downloadTaskWithURL:url];
     
    }
    [self setButtonsEnabled:@"start"];
    [downloadTask resume];
}
-(void)setButtonsEnabled:(NSString*)name{
    if ([name isEqualToString:@"start"]) {
        [self.dowloadButt setEnabled:NO];
        [self.pauseDownloadButt setEnabled:YES];
        [self.progressView setHidden:NO];
    }
    else if ([name isEqualToString:@"pause"]){
        [self.pauseDownloadButt setEnabled:NO];
        [self.dowloadButt setEnabled:YES];
        [self.progressView setHidden:YES];
    }
    else if ([name isEqualToString:@"play"]){
        [self.playButt setEnabled:YES];
        [self.deleteButt setEnabled:YES];
        [self.dowloadButt setEnabled:NO];
        [self.pauseDownloadButt setEnabled:NO];
        [self.progressView setHidden:YES];
        
    }
    else if([name isEqualToString:@"download"]){
        [self.playButt setEnabled:YES];
        [self.deleteButt setEnabled:YES];
        [self.dowloadButt setEnabled:NO];
        [self.pauseDownloadButt setEnabled:NO];
        [self.progressView setHidden:YES];
        
    }
    else {
        [self.dowloadButt setEnabled:YES];
        [self.pauseDownloadButt setEnabled:NO];
        [self.playButt setEnabled:NO];
        [self.deleteButt setEnabled:NO];
    }
    
    
}


- (IBAction)pauseDownload {
    if (downloadTask) {
        [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [resumeData writeToFile:[self getDataPath] atomically:YES];
        }];
        [self setButtonsEnabled:@"pause"];
        [UIApplication sharedApplication] .networkActivityIndicatorVisible = NO;
    }
    else{
    
    }
}



- (IBAction)deleteVideo {
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:[self getPath] error:nil];
    [manager removeItemAtPath:[self getDataPath] error:nil];
    [player stop];
    [self setButtonsEnabled:@"delete"];
    self.progressView.progress = 0;
    [downloadTask cancel];
}

- (IBAction)playVideo:(id)sender {
    [self setButtonsEnabled:@"play"];
    NSURL *myURl = [NSURL fileURLWithPath:[self getPath]];
    player.contentURL = myURl;
    [player play];
}

@end
