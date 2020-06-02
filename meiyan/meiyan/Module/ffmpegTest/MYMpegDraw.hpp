//
//  MYMpegDraw.hpp
//  meiyan
//
//  Created by kzw on 2020/5/26.
//  Copyright © 2020 康子文. All rights reserved.
//

#ifndef MYMpegDraw_hpp
#define MYMpegDraw_hpp

#include <stdio.h>
#include <iostream>
#include <memory>
#include "mpegHeader.h"
extern "C"{
    #include <libavutil/opt.h>
    #include <libavutil/channel_layout.h>
    #include <libavutil/common.h>
    #include <libavutil/imgutils.h>
    #include <libavutil/samplefmt.h>
    #include <libavutil/time.h>
    #include <libavutil/fifo.h>
    #include <libavcodec/avcodec.h>
    #include <libavformat/avformat.h>
    #include <libavformat/avio.h>
    #include <libavfilter/avfilter.h>
    #include <libavfilter/buffersrc.h>
    #include <libavfilter/buffersink.h>
    #include <libswscale/swscale.h>
    #include <libswresample/swresample.h>
//包含sdl的函数 iOS不要调用 会报错
//    #include <libavdevice/avdevice.h>
}

class  MYMpegDraw{
public:
    MYMpegDraw();
    ~MYMpegDraw();
    int drawTextDain(std::string fileInput,std::string fileOutput,RGBSWSCALLBACK block);
private:
    AVFormatContext *context =nullptr;
    AVFormatContext* outputContext = nullptr;
    AVCodecContext* outPutEncContext = nullptr;
    //视频流索引
    int videoIndex = 0;
    AVCodecContext *decoderContext = nullptr;
    
    AVFilterGraph * filter_graph = nullptr;
    AVFilterContext *buffersink_ctx  = nullptr;;
    AVFilterContext *buffersrc_ctx  = nullptr;;

    void Init();
    std::shared_ptr<AVPacket> ReadPacketFromSource();
    int OpenOutput(char *fileName);
    void CloseInput();
    void CloseOutput();
    int InitEncoderCodec( int iWidth, int iHeight);
    int InitDecodeCodec(AVCodecID codecId);
    bool DecodeVideo(AVPacket* packet, AVFrame* frame);
    int InitFilter(AVCodecContext * codecContext);
    static int interrupt_cb(void *cxt);
    int OpenInput(char *fileName);

};
#endif /* MYMpegDraw_hpp */
