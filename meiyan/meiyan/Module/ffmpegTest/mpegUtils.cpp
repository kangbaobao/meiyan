//
//  mpegUtils.cpp
//  ffmpegTest
//
//  Created by 康子文 on 2020/3/21.
//  Copyright © 2020 e-lead. All rights reserved.
//

#include "mpegUtils.hpp"
#include <string>
#include <memory>
#include <thread>
#include <iostream>
#include <sstream>
using namespace std;

AVFormatContext *inputContext = nullptr;
AVFormatContext *outputContext = nullptr;
//test
static  AVCodecContext *codecContext = nullptr;
int64_t lastReadpackTime;

static int ineterrupt_cb(void *ctx){
    cout<< "ineterrupt_cb..." << endl;
    int timeout = 3;
    if (av_gettime() - lastReadpackTime > timeout *1000 *1000){
        return -1;
    }
    return 0;
}

int OpenInput(string inputUrl){
    inputContext = avformat_alloc_context();
    lastReadpackTime = av_gettime();
    inputContext->interrupt_callback.callback = ineterrupt_cb;
    int ret =avformat_open_input(&inputContext, inputUrl.c_str(), nullptr, nullptr);
    if (ret < 0 ){
        std::cout << "path error :"<<inputUrl.c_str()<<endl;
        av_log(nullptr, AV_LOG_ERROR,  "Input file open input failed\n");
        return ret;
    }
    ret = avformat_find_stream_info(inputContext, nullptr);
    if (ret < 0 ){
        std::cout << "Find input file stream inform failed\n"<<endl;
        return ret;
    }else{
        std::cout << "Open input file  %s success:\n"<<inputUrl.c_str() <<endl;

    }
    return ret;
}
shared_ptr<AVPacket> ReadPacketFromSource(){
    shared_ptr<AVPacket> packet(static_cast<AVPacket *>(av_malloc(sizeof(AVPacket))),
                                [&](AVPacket *p){
//        av_packet_free(&p);
//        av_free(&p);
    });
    av_init_packet(packet.get());
    lastReadpackTime = av_gettime();
    int ret = av_read_frame(inputContext, packet.get());
    if (ret >=0){
        return packet;
    }else{
        return nullptr;
    }
}
int OpenJPEGOutput(string outUrl){
    int ret = avformat_alloc_output_context2(&outputContext, nullptr, "singlejpeg", outUrl.c_str());
    if (ret < 0){
        std::cout << "open output context failed\n"<<endl;
        goto Error;
    }
    ret = avio_open2(&outputContext->pb, outUrl.c_str(), AVIO_FLAG_WRITE,nullptr, nullptr);
        if(ret < 0){
            av_log(NULL, AV_LOG_ERROR, "open avio failed");
            goto Error;
        }
    
        for(int i = 0; i < inputContext->nb_streams; i++){
             if (inputContext->streams[i]->codecpar->codec_type == AVMediaType::AVMEDIA_TYPE_AUDIO){
                continue;
            }
            AVStream *stream = avformat_new_stream(outputContext, avcodec_find_encoder(inputContext->streams[i]->codecpar->codec_id));
            ret = avcodec_parameters_copy(stream->codecpar, inputContext->streams[i]->codecpar);
            if(ret < 0)
            {
                av_log(NULL, AV_LOG_ERROR, "copy coddec context failed");
                goto Error;
            }
        }
        ret = avformat_write_header(outputContext, nullptr);
        if(ret < 0)
        {
            av_log(NULL, AV_LOG_ERROR, "format write header failed");
            goto Error;
        }
    
        av_log(NULL, AV_LOG_FATAL, " Open output file success %s\n",outUrl.c_str());
        return ret ;
    Error:
        if(outputContext)
        {
            for(int i = 0; i < outputContext->nb_streams; i++)
            {
                avcodec_parameters_free(&outputContext->streams[i]->codecpar);
            }
            avformat_close_input(&outputContext);
        }
        return ret ;
}

int OpenMP4Output(string outUrl){
    int ret = avformat_alloc_output_context2(&outputContext, nullptr, "mp4", outUrl.c_str());
    if (ret < 0){
        std::cout << "open output context failed\n"<<endl;
        goto Error;
    }
    ret = avio_open2(&outputContext->pb, outUrl.c_str(), AVIO_FLAG_WRITE,nullptr, nullptr);
        if(ret < 0){
            av_log(NULL, AV_LOG_ERROR, "open avio failed");
            goto Error;
        }
        for(int i = 0; i < inputContext->nb_streams; i++){
            //⚠️注意此处获取为巧合 mov和mp4 音频、视频一致c才可以这样写，否则会报 Codec type or id mismatches InitDecodeCodec failed!
            AVStream *stream = avformat_new_stream(outputContext, avcodec_find_encoder(inputContext->streams[i]->codecpar->codec_id));
            ret = avcodec_parameters_copy(stream->codecpar, inputContext->streams[i]->codecpar);
            if(ret < 0){
                av_log(NULL, AV_LOG_ERROR, "copy coddec context failed");
                goto Error;
            }
        }
        ret = avformat_write_header(outputContext, nullptr);
        if(ret < 0){
            av_log(NULL, AV_LOG_ERROR, "format write header failed");
            goto Error;
        }
    
        av_log(NULL, AV_LOG_FATAL, " Open output file success %s\n",outUrl.c_str());
        return ret ;
    Error:
        if(outputContext){
            for(int i = 0; i < outputContext->nb_streams; i++){
                avcodec_parameters_free(&outputContext->streams[i]->codecpar);
            }
            avformat_close_input(&outputContext);
        }
        return ret ;
}

void Init()
{
//    av_register_all();
//    avfilter_register_all();
    avformat_network_init();
    av_log_set_level(AV_LOG_WARNING);
}

void CloseInput(){
    if(inputContext != nullptr){
        avformat_close_input(&inputContext);
    }
}

void CloseOutput()
{
    if(outputContext != nullptr){
         av_write_trailer(outputContext);
        for(int i = 0 ; i < outputContext->nb_streams; i++){
            avcodec_parameters_free(&outputContext->streams[i]->codecpar);
        }
        avformat_close_input(&outputContext);
    }
}

int WritePacket(shared_ptr<AVPacket> packet){
    return av_interleaved_write_frame(outputContext, packet.get());
}

int InitDecodeContext(AVStream *inputStream){
    auto codecId = inputStream->codecpar->codec_id;
    auto codec = avcodec_find_decoder(codecId);
    if (!codec)
    {
        return -1;
    }
    codecContext = avcodec_alloc_context3(nullptr);
    avcodec_parameters_to_context(codecContext, inputStream->codecpar);

   int ret = avcodec_open2(codecContext, codec, nullptr);
    if (ret < 0) {
        std::cout << "InitDecodeContext : " <<ret << endl;
    }
    return ret;
}
int initMJPEGEncoderCodec(AVStream* inputStream,AVCodecContext **encodeContext)
    {
        AVCodec *  picCodec;
        picCodec = avcodec_find_encoder(AV_CODEC_ID_MJPEG);
        (*encodeContext) = avcodec_alloc_context3(picCodec);
    
        (*encodeContext)->codec_id = picCodec->id;
        (*encodeContext)->time_base.num = inputStream->time_base.num;
        (*encodeContext)->time_base.den = inputStream->time_base.den;
        (*encodeContext)->pix_fmt =  *picCodec->pix_fmts;
        (*encodeContext)->width = inputStream->codecpar->width;
        (*encodeContext)->height = inputStream->codecpar->height;
        int ret = avcodec_open2((*encodeContext), picCodec, nullptr);
        
        std::cout <<"initEncoderCodec : "<<inputStream->time_base.num<<" : "<< inputStream->time_base.den<<endl;
        if (ret < 0)
        {
            std::cout<<"open video codec failed"<<endl;
            return  ret;
        }
    return 1;
}

bool Decode(AVStream* inputStream,AVPacket* packet, AVFrame *frame){
    int ret = avcodec_send_packet(codecContext, packet);

    if (ret >= 0 ){
        ret =  avcodec_receive_frame(codecContext, frame);
        if (ret >=0 ){
            return true;
        }
    }
    return false;
}


std::shared_ptr<AVPacket> Encode(AVCodecContext *encodeContext,AVFrame * frame)
{
    std::shared_ptr<AVPacket> pkt(static_cast<AVPacket*>(av_malloc(sizeof(AVPacket))), [&](AVPacket *p) { av_packet_free(&p); av_freep(&p); });
    av_init_packet(pkt.get());
    pkt->data = NULL;
    pkt->size = 0;
    
    int ret = avcodec_send_frame(encodeContext, frame);
    if (ret >= 0 ){
        ret = avcodec_receive_packet(encodeContext, pkt.get());
        if (ret >=0){
            return pkt;
        }
    }
    return nullptr;
}
//获取一张图片
int puctureMain(string inputStr,string outpuStr)
{
    Init();
    unsigned version = avcodec_version();
    printf("version : %d\n",version);
    int ret = OpenInput(inputStr.c_str());//("rtsp://admin:admin12345@192.168.1.65:554/h264/ch1/main/av_stream");
    if(ret >= 0)
    {
        ret = OpenJPEGOutput(outpuStr.c_str());
    }
    if(ret <0) {
        CloseInput();
        CloseOutput();
        return  -1;
    }
    int videoIndex = 0;
    for (int i = 0;i <inputContext->nb_streams;i++){
        if (inputContext->streams[i]->codecpar->codec_type == AVMediaType::AVMEDIA_TYPE_VIDEO){
            videoIndex = i;
            break;
        }
    }
    AVCodecContext *encodeContext = nullptr;
    InitDecodeContext(inputContext->streams[videoIndex]);
    AVFrame *videoFrame = av_frame_alloc();
    initMJPEGEncoderCodec(inputContext->streams[videoIndex],&encodeContext);
     while(true)
     {
        auto packet = ReadPacketFromSource();
        if(packet && packet->stream_index == videoIndex)
        {
            if(Decode(inputContext->streams[videoIndex],packet.get(),videoFrame))
            {
                auto packetEncode = Encode(encodeContext,videoFrame);
                if(packetEncode)
                {
                    ret = WritePacket(packetEncode);
                    if(ret >= 0)
                    {
                        break;
                    }
                }
            }
                        
        }
     }
     cout <<"Get Picture End "<<endl;
     av_frame_free(&videoFrame);
     avcodec_close(encodeContext);
    CloseInput();
    CloseOutput();
    return 0;
}
//获取一张RGB纹理
int puctureswsScale(string inputStr,RGBSWSCALLBACK block)
{
    Init();
    unsigned version = avcodec_version();
    printf("version : %d\n",version);
    int ret = OpenInput(inputStr.c_str());//("rtsp://admin:admin12345@192.168.1.65:554/h264/ch1/main/av_stream");

    if(ret <0) {
        CloseInput();
        return  -1;
    }
    int videoIndex = 0;
    for (int i = 0;i <inputContext->nb_streams;i++){
        if (inputContext->streams[i]->codecpar->codec_type == AVMediaType::AVMEDIA_TYPE_VIDEO){
            videoIndex = i;
            break;
        }
    }
    AVCodecContext *encodeContext = nullptr;
    InitDecodeContext(inputContext->streams[videoIndex]);
    AVFrame *videoFrame = av_frame_alloc();
    SwsContext *sws_cxt = sws_getContext(codecContext->width,  codecContext->height, codecContext->pix_fmt, codecContext->width, codecContext->height, AV_PIX_FMT_RGB24, SWS_BILINEAR, nullptr, nullptr, nullptr);
     while(true)
     {
        auto packet = ReadPacketFromSource();
        if(packet && packet->stream_index == videoIndex)
        {
            if(Decode(inputContext->streams[videoIndex],packet.get(),videoFrame))
            {
                AVFrame *RGBFrame = av_frame_alloc();
                //sws_scale转码
                std::cout << "width: "<< codecContext->width << " height: "<<codecContext->height<<endl;
                std::cout << "pix_fmt: "<< av_get_pix_fmt_name(codecContext->pix_fmt) <<endl;
                
              int ret =  av_image_alloc(RGBFrame->data, RGBFrame->linesize, codecContext->width, codecContext->height, AV_PIX_FMT_RGB24, 1);

//                int num = av_image_get_buffer_size(AV_PIX_FMT_RGB24, codecContext->width, codecContext->height, 1);
//                uint8_t * buffer = (uint8_t *) av_malloc(num * sizeof(uint8_t));
//                av_image_fill_arrays(RGBFrame->data, RGBFrame->linesize, buffer, AV_PIX_FMT_RGB24, codecContext->width, codecContext->height, 1);
                std::cout << "RGBFrame linesize: "<< RGBFrame->linesize <<endl;

                if (!sws_cxt&& ret < 0){
                    std::cout<<"sws_cxt failed"<<endl;
                    av_frame_free(&RGBFrame);
                    av_free(RGBFrame);
                  //  av_free(buffer);
                    continue;
                }
                sws_scale(sws_cxt, videoFrame->data, videoFrame->linesize, 0, videoFrame->height, RGBFrame->data, RGBFrame->linesize);
                // 回调给参数
                block(codecContext->width,codecContext->height,RGBFrame->data[0],RGBFrame->linesize[0]);
                av_frame_free(&RGBFrame);
                av_free(RGBFrame);
                av_frame_free(&videoFrame);
                av_free(videoFrame);
              //  av_free(buffer);
                break;

            }
                        
        }
     }
     cout <<"Get Picture End "<<endl;

     av_frame_free(&videoFrame);
     avcodec_close(encodeContext);
    sws_freeContext(sws_cxt);

    CloseInput();
    CloseOutput();
    return 0;
}

//获取一张RGB纹理
/*
 //  休眠时间 ffmpeg 建议这样写  为什么 要这样写 有待研究
 av_usleep(actual_delay * 1000000.0 + 6000);
 //获取当前帧的pts
 double pts = av_frame_get_best_effort_timestamp(avFrame);
 double timestamp = pts * av_q2d(time_base);//time_base是流的time_base，用来计算这帧在整个视频中的时间位置
 
 + (void)stream:(AVStream *)stream fps:(double *)fps timebase:(double *)timebase default:(double)defaultTimebase {
     double f = 0, t = 0;
     if (stream->time_base.den > 0 && stream->time_base.num > 0) {
         t = av_q2d(stream->time_base);
     } else {
         t = defaultTimebase;
     }
     
     if (stream->avg_frame_rate.den > 0 && stream->avg_frame_rate.num) {
         f = av_q2d(stream->avg_frame_rate);
     } else if (stream->r_frame_rate.den > 0 && stream->r_frame_rate.num > 0) {
         f = av_q2d(stream->r_frame_rate);
     } else {
         f = 1 / t;
     }
     
     if (fps != NULL) *fps = f;
     if (timebase != NULL) *timebase = t;
 }
 [DLGPlayerDecoder stream:fmtctx->streams[vstream] fps:&_videoFPS timebase:&_videoTimebase default:0.04];
 
 f.position = frame->best_effort_timestamp * _videoTimebase;
        double duration = frame->pkt_duration;
        if (duration > 0) {
            f.duration = duration * _videoTimebase;
                    
            f.duration += frame->repeat_pict * _videoTimebase * 0.5; //repeat_pict(解码时，这表示图片必须延迟多少时间 extra_delay = repeat_pict / (2*fps))
        } else {
            f.duration = 1 / _videoFPS;
        }
 **/
//连续解码video
int videoswsScaleplay(string inputStr,RGBSWSCALLBACK block,VIDEOBLOCK videoBlock)
{
    Init();
    int ret = OpenInput(inputStr.c_str());
    if(ret <0) {
        CloseInput();
        return  -1;
    }
    int videoIndex = 0;
    for (int i = 0;i <inputContext->nb_streams;i++){
        if (inputContext->streams[i]->codecpar->codec_type == AVMediaType::AVMEDIA_TYPE_VIDEO){
            videoIndex = i;
            break;
        }
    }
    AVCodecContext *encodeContext = nullptr;
    InitDecodeContext(inputContext->streams[videoIndex]);
    AVFrame *videoFrame = av_frame_alloc();
     SwsContext *sws_cxt = sws_getContext(codecContext->width,  codecContext->height, codecContext->pix_fmt, codecContext->width, codecContext->height, AV_PIX_FMT_RGB24, SWS_BILINEAR, nullptr, nullptr, nullptr);
    //inputContext->streams[videoIndex]->avg_frame_rate;
     //inputContext->duration
    AVRational frameRate = inputContext->streams[videoIndex]->avg_frame_rate;
    float fps = 0.04;
    if (frameRate.num > 0 && frameRate.den > 0){
        fps = 1.0/av_q2d(frameRate);
    }
    std::cout<<"fps : "<<fps<<endl; //405.2 ，秒数

    std::cout <<"frameRate : "<<av_q2d(frameRate)<<endl; //30 每秒30帧
    AVRational timeBase = inputContext->streams[videoIndex]->time_base;
    std::cout<<"timeBase : "<<av_q2d(timeBase)<<endl;
    int64_t duration = inputContext->streams[videoIndex]->duration;
    std::cout<<"duration : "<<duration * av_q2d(timeBase)<<endl; //405.2 ，秒数
    
    AVFrame *RGBFrame = av_frame_alloc();
      //sws_scale转码 写在while循环里会造成严重的内容泄漏问题，⚠️⚠️⚠️
     ret =  av_image_alloc(RGBFrame->data, RGBFrame->linesize, codecContext->width, codecContext->height, AV_PIX_FMT_RGB24, 1);
      if (!sws_cxt&& ret < 0){
          std::cout<<"sws_cxt failed"<<endl;
          av_frame_free(&RGBFrame);
          av_free(RGBFrame);
         // continue;
      }
     while(true){
        auto packet = ReadPacketFromSource();
         if (!packet){
             //解码失败停止解码 并且 快结束时
             break;
         }
        if(packet && packet->stream_index == videoIndex){
            if(Decode(inputContext->streams[videoIndex],packet.get(),videoFrame)) {

                sws_scale(sws_cxt, videoFrame->data, videoFrame->linesize, 0, videoFrame->height, RGBFrame->data, RGBFrame->linesize);
                //延迟
                av_usleep(fps * 1000*1000);
                // 回调给参数
                block(codecContext->width,codecContext->height,RGBFrame->data[0],RGBFrame->linesize[0]);
                // 传递进度 并且返回bool 是否中断视频播放
                if (videoBlock != nullptr) {
                    float pro = (float)videoFrame->pts/duration;
                    struct VIDEOPARM vs;
                    vs.pro = pro;
                    struct VIDEOPARM *v = &vs;
                    videoBlock((void *)v);
                    if (v->zhongduan == true){
                        break;
                    }
                }


            }
        }
     }
     cout <<"Get Video End "<<endl;
    av_frame_free(&RGBFrame);
    av_free(RGBFrame);
    sws_freeContext(sws_cxt);
     av_frame_free(&videoFrame);
     avcodec_close(encodeContext);
    CloseInput();
    CloseOutput();
    return 0;
}
//转码
int toMP4Main(string inputStr,string outpuStr){
    Init();
    int ret = OpenInput(inputStr.c_str());
    if(ret >= 0){
        ret = OpenMP4Output(outpuStr.c_str());
    }
    if(ret <0) {
        CloseInput();
        CloseOutput();
        return  -1;
    }
    int videoIndex = 0;
    for (int i = 0;i <inputContext->nb_streams;i++){
        if (inputContext->streams[i]->codecpar->codec_type == AVMediaType::AVMEDIA_TYPE_VIDEO){
            videoIndex = i;
            break;
        }
    }
    InitDecodeContext(inputContext->streams[videoIndex]);
    AVFrame *videoFrame = av_frame_alloc();
     while(true){
        auto packet = ReadPacketFromSource();
         if (!packet){
             break;
         }
         ret = WritePacket(packet);
         if(ret >= 0){
             cout<<"WritePacket Success!"<<endl;
         }else{
             cout<<"WritePacket failed!"<<endl;
         }
     }
     cout <<" MP4 End "<<endl;
     av_frame_free(&videoFrame);
    // avcodec_close(encodeContext);
    CloseInput();
    CloseOutput();
    return 0;
}
//打印头信息
std::string achieve_header(const char *dst_file_path) {
    std::stringstream strStream;
    strStream << "文件头信息 "<<endl;
    std::string start;
  FILE *dst_file = fopen(dst_file_path, "r");
  if (dst_file != NULL) {
    struct AVFormatContext *ctx = avformat_alloc_context();
   // av_register_all();
    // 打开输入流，并且解析头部，解码器并不会打开，必须使用avformat_close_input()关闭
    // 返回结果0代表成功, 负数AVERROR表示失败.
    if (avformat_open_input(&ctx, dst_file_path, NULL, NULL) != 0) {
      printf("open dst file error!!!");
    } else {
      /**
       * 元数据
       */
      AVDictionary *metadata = ctx->metadata;
      int count = av_dict_count(metadata);
      AVDictionaryEntry *prev = NULL;
      if (count) {
        printf("achieve meta datas :\n");
        for (int i = 0; i < count; i++) {
          prev = av_dict_get(metadata, "", prev, AV_DICT_IGNORE_SUFFIX);
          if (prev) {
            printf("%s = %s \n", prev->key, prev->value);
              strStream << prev->key << " : " <<prev->value <<endl;
          }
        }
      }
      printf("\nmetadata count size %d \n", count);
      /**
       * 视频时长
       */
      int64_t duration = ctx->duration;
      if (duration != AV_NOPTS_VALUE) {
        double_t duration_seconds = (double_t)duration / AV_TIME_BASE;
        printf("video duration %.2f seconds \n", duration_seconds);
          strStream << "duration :" <<duration_seconds <<endl ;
      }
      /**
       * 码率，如果为0，则不存在码率；如果知道文件大小和时长的情况下无需直接手动设置，ffmpeg会自动计算
       */
      int64_t bit_rate = ctx->bit_rate;
      if (bit_rate > 0) {
        printf("video bitrate %d\n", bit_rate);
      } else {
        printf("video bitrate N/A\n");
      }
      /**
       * 第一帧起始时间，无需手动设置，由AVStream中推导出来，单位是xxx/AV_TIME_BASE(秒)
       */
      int64_t start_time = ctx->start_time;
      if (start_time != AV_NOPTS_VALUE) {
        double_t start_time_seconds = (double_t)start_time / AV_TIME_BASE;
        printf("video start time %.5f\n", start_time_seconds);
      }
      /**
       * 流信息
       */
      printf("\n-----STREAM_INFOS-----\n");
      AVStream **streams = ctx->streams;
      int stream_counts = ctx->nb_streams;
      if (stream_counts > 0) {
        for (int index = 0; index < stream_counts; index++) {
          printf("\n---STREAM---\n");
          AVStream *stream = streams[index];
          int stream_index = stream->index;
          printf("stream index %d\n", stream_index);
          // 后续讲到视频播放的时候会再次重点解析一下这个区域的信息
          printf("stream info parse...");
        }
      }

      printf("\n\nstream count %d\n", stream_counts);
    }

    avformat_close_input(&ctx);
  } else {
    printf("open dst file error!!!");
  }
    strStream << "输出结束" <<endl ;
    start = strStream.str();

    //strStream>>start;
    // 在进行多次类型转换前，必须先运行clear()
    strStream.clear();
    return start;
}
//调试打印头信息一次性打开
void print_header(char *dst_file_path) {
  FILE *dst_file = fopen(dst_file_path, "r");
  if (dst_file != NULL) {
    struct AVFormatContext *ctx = avformat_alloc_context();
    av_register_all();
    // 打开输入流，并且解析头部，解码器并不会打开，必须使用avformat_close_input()关闭
    // 返回结果0代表成功, 负数AVERROR表示失败.
    if (avformat_open_input(&ctx, dst_file_path, NULL, NULL) != 0) {
      printf("open dst file error!!!");
    } else {
      // 读取avformat_open_input后，头部信息就存在于ctx中，这里进行一个简单的打印，当然你也可以自己独子获取其中的某些变量
      av_dump_format(ctx, 0, dst_file_path, 0);
    }
    avformat_close_input(&ctx);
  } else {
    printf("open dst file error!!!");
  }
}


