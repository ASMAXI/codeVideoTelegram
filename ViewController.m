//
//  ViewController.m
//  PlayerOnTelegram
//
//  Created by  Max on 06.10.2024.
//

#import "ViewController.h"
#import "GStreamerPlayer.h"

@interface ViewController ()

@property (strong, nonatomic) GStreamerPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.player = [[GStreamerPlayer alloc] initWithVideoView:self.videoView];
    [self.player playHLSStream:@"http://example.com/playlist.m3u8"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.player stop];
}

@end
