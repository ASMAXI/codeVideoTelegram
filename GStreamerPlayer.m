//
//  GStreamerPlayer.m
//  PlayerOnTelegram
//
//  Created by  Max on 06.10.2024.
//

#import "GStreamerPlayer.h"

@interface GStreamerPlayer ()

@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) GstElement *pipeline;
@property (nonatomic, strong) GstElement *videoSink;

@end

@implementation GStreamerPlayer

- (instancetype)initWithVideoView:(UIView *)videoView {
    self = [super init];
    if (self) {
        self.videoView = videoView;
        gst_init(NULL, NULL);
    }
    return self;
}

- (void)playHLSStream:(NSString *)url {
    [self stop];

    self.pipeline = gst_pipeline_new("hls-player");
    GstElement *source = gst_element_factory_make("souphttpsrc", "source");
    GstElement *demuxer = gst_element_factory_make("hlsdemux", "demuxer");
    GstElement *videoQueue = gst_element_factory_make("queue", "video-queue");
    GstElement *audioQueue = gst_element_factory_make("queue", "audio-queue");
    GstElement *videoDecoder = gst_element_factory_make("avdec_h264", "video-decoder");
    GstElement *audioDecoder = gst_element_factory_make("aacparse", "audio-parser");
    GstElement *audioConverter = gst_element_factory_make("audioconvert", "audio-converter");
    GstElement *audioResample = gst_element_factory_make("audioresample", "audio-resample");
    GstElement *audioSink = gst_element_factory_make("autoaudiosink", "audio-sink");
    self.videoSink = gst_element_factory_make("autovideosink", "video-sink");

    if (!self.pipeline || !source || !demuxer || !videoQueue || !audioQueue || !videoDecoder || !audioDecoder || !audioConverter || !audioResample || !audioSink || !self.videoSink) {
        NSLog(@"Не удалось создать все элементы.");
        return;
    }

    g_object_set(source, "location", [url UTF8String], NULL);

    gst_bin_add_many(GST_BIN(self.pipeline), source, demuxer, videoQueue, audioQueue, videoDecoder, audioDecoder, audioConverter, audioResample, audioSink, self.videoSink, NULL);

    if (!gst_element_link_many(source, demuxer, NULL)) {
        NSLog(@"Не удалось связать элементы source и demuxer.");
        return;
    }

    if (!gst_element_link_many(videoQueue, videoDecoder, self.videoSink, NULL)) {
        NSLog(@"Не удалось связать элементы videoQueue, videoDecoder и videoSink.");
        return;
    }

    if (!gst_element_link_many(audioQueue, audioDecoder, audioConverter, audioResample, audioSink, NULL)) {
        NSLog(@"Не удалось связать элементы audioQueue, audioDecoder, audioConverter, audioResample и audioSink.");
        return;
    }

    GstPad *videoPad = gst_element_get_static_pad(videoQueue, "sink");
    GstPad *audioPad = gst_element_get_static_pad(audioQueue, "sink");

    gst_pad_link(gst_element_get_static_pad(demuxer, "video_0"), videoPad);
    gst_pad_link(gst_element_get_static_pad(demuxer, "audio_0"), audioPad);

    gst_object_unref(videoPad);
    gst_object_unref(audioPad);

    GstStateChangeReturn ret = gst_element_set_state(self.pipeline, GST_STATE_PLAYING);
    if (ret == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Не удалось запустить pipeline.");
        gst_object_unref(self.pipeline);
        return;
    }

    GstBus *bus = gst_element_get_bus(self.pipeline);
    gst_bus_add_watch(bus, (GstBusFunc)bus_call, (__bridge gpointer)(self));
    gst_object_unref(bus);
}

- (void)stop {
    if (self.pipeline) {
        gst_element_set_state(self.pipeline, GST_STATE_NULL);
        gst_object_unref(self.pipeline);
        self.pipeline = NULL;
    }
}

static gboolean bus_call(GstBus *bus, GstMessage *msg, gpointer data) {
    GStreamerPlayer *player = (__bridge GStreamerPlayer *)data;

    switch (GST_MESSAGE_TYPE(msg)) {
        case GST_MESSAGE_ERROR: {
            GError *err;
            gchar *debug;
            gst_message_parse_error(msg, &err, &debug);
            NSLog(@"Ошибка: %s", err->message);
            g_error_free(err);
            g_free(debug);
            [player stop];
            break;
        }
        case GST_MESSAGE_EOS:
            NSLog(@"Конец потока.");
            [player stop];
            break;
        default:
            break;
    }

    return TRUE;
}

@end
