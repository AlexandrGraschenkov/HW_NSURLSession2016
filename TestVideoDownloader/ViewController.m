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
}

- (NSString *)getDownloadPath {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [docDir stringByAppendingPathComponent:@"video.mov"];
}

- (IBAction)startDownload {
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/55523423/video.mov"];
    // todo
}

- (IBAction)pauseDownload {
    // todo
}

- (IBAction)deleteVideo {
    // todo
}

- (IBAction)playVideo:(id)sender {
    // todo
}

@end
