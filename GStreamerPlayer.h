//
//  GStreamerPlayer.h
//  PlayerOnTelegram
//
//  Created by  Max on 06.10.2024.
//
#import <Foundation/Foundation.h>
#import <GStreamer/GStreamer.h>

@interface GStreamerPlayer : NSObject

- (instancetype)initWithVideoView:(UIView *)videoView;
- (void)playHLSStream:(NSString *)url;
- (void)stop;

@end
