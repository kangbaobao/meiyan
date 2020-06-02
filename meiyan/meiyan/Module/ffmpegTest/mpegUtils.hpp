//
//  mpegUtils.hpp
//  ffmpegTest
//
//  Created by 康子文 on 2020/3/21.
//  Copyright © 2020 e-lead. All rights reserved.
//

#ifndef mpegUtils_hpp
#define mpegUtils_hpp

#include <stdio.h>
#include <string>
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
}
#include "mpegHeader.h"

//打开w输入文件
int OpenInput(std::string inputUrl);
//获取一z张图片
int puctureMain(std::string inputStr,std::string outpuStr);
//获取一张图片
int puctureswsScale(std::string inputStr,RGBSWSCALLBACK block);

//连续解码video
int videoswsScaleplay(std::string inputStr,RGBSWSCALLBACK block,VIDEOBLOCK videoBlock);
//转码
int toMP4Main(std::string inputStr,std::string outpuStr);
//打印头信息
std::string achieve_header(const char *dst_file_path) ;
#endif /* mpegUtils_hpp */
