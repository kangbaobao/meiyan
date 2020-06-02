//
//  MYMpegDraw.cpp
//  meiyan
//
//  Created by kzw on 2020/5/26.
//  Copyright © 2020 康子文. All rights reserved.
//

#include "MYMpegDraw.hpp"
#include <string>
using namespace std;
MYMpegDraw:: MYMpegDraw() {
    
}
 MYMpegDraw::~MYMpegDraw(){
    
}
int MYMpegDraw::interrupt_cb(void *cxt){
    return 0;
}

void MYMpegDraw::Init(){
//    av_register_all();
//    avfilter_register_all();
    avformat_network_init();
//    avdevice_register_all();
    av_log_set_flags(AV_LOG_ERROR);
}

int MYMpegDraw::OpenInput(char *fileName){
    context = avformat_alloc_context();
    context->interrupt_callback.callback = MYMpegDraw::interrupt_cb;
    AVDictionary *format_opts = nullptr;
    int ret = avformat_open_input(&context, fileName, nullptr, &format_opts);
    if (ret < 0){
        return ret;
    }
    ret = avformat_find_stream_info(context, nullptr);
    //打印
    av_dump_format(context, 0, fileName, 0);
    if (ret >= 0){
        std::cout<<"open input stream successfully"<<endl;
    }
    for (int i = 0;i <context->nb_streams;i++){
      if (context->streams[i]->codecpar->codec_type == AVMediaType::AVMEDIA_TYPE_VIDEO){
          videoIndex = i;
          break;
      }
    }
    return ret;
}
shared_ptr<AVPacket> MYMpegDraw::ReadPacketFromSource(){
    std::shared_ptr<AVPacket> packet(static_cast<AVPacket*>(av_malloc(sizeof(AVPacket))),[&](AVPacket *p){
    });
    av_init_packet(packet.get());
    int ret = av_read_frame(context, packet.get());
    if (ret >=0){
        return packet;
    }else{
        return nullptr;
    }
}
//保存成ts流
int MYMpegDraw::OpenOutput(char *fileName){
    int ret = 0;
    ret = avformat_alloc_output_context2(&outputContext, nullptr, "mpegts", fileName);
    if (ret <0){
        goto ErrorOutPut;
    }
    ret = avio_open2(&outputContext->pb, fileName, AVIO_FLAG_READ_WRITE, nullptr, nullptr);
    if (ret < 0){
        goto ErrorOutPut;
    }

    for(int i = 0;i < context->nb_streams;i++){
//        if (i == videoIndex){
            AVStream *stream = avformat_new_stream(outputContext, avcodec_find_encoder(outPutEncContext->codec_id));
           ret = avcodec_parameters_from_context(stream->codecpar, outPutEncContext);
            if (ret < 0){
                goto ErrorOutPut;
            }
//        }else{
//            //音频 有待确定先这么写着...
//            AVStream *stream = avformat_new_stream(outputContext, avcodec_find_encoder(context->streams[i]->codecpar->codec_id));
//            ret = avcodec_parameters_copy(stream->codecpar, context->streams[i]->codecpar);
//            if (ret < 0){
//                goto ErrorOutPut;
//            }
//        }
    }
    av_dump_format(outputContext, 0, fileName, 1);
    ret = avformat_write_header(outputContext, nullptr);
    if(ret < 0){
        std::cout<<"output文件失败"<<endl;

        goto ErrorOutPut;
    }
    if (ret>=0){
        std::cout<<"output文件成功"<<endl;
    }
    return ret;
ErrorOutPut:
    if (outputContext){
        avformat_close_input(&outputContext);
    }
    return ret;
    return 0;
}
void MYMpegDraw::CloseInput(){
    if (context){
        avformat_close_input(&context);
    }
}
void MYMpegDraw::CloseOutput(){
    if(outputContext != nullptr){
        for(int i = 0 ; i < outputContext->nb_streams; i++){
            avcodec_parameters_free(&outputContext->streams[i]->codecpar);
        }
        avformat_close_input(&outputContext);
    }
}
int MYMpegDraw::InitEncoderCodec( int iWidth, int iHeight){
    //avcodec_find_encoder(AV_CODEC_ID_AAC);
    AVCodec *  pH264Codec = avcodec_find_encoder(AV_CODEC_ID_H264);
        if(NULL == pH264Codec){
            printf("%s", "avcodec_find_encoder failed");
            return  -1;
        }
        outPutEncContext = avcodec_alloc_context3(pH264Codec);
        outPutEncContext->gop_size = 30;
        outPutEncContext->has_b_frames = 0;
        outPutEncContext->max_b_frames = 0;
        outPutEncContext->codec_id = pH264Codec->id;
    outPutEncContext->time_base.num = context->streams[videoIndex]->time_base.num;//context->streams[0]->codec->time_base.num;
    outPutEncContext->time_base.den = context->streams[videoIndex]->time_base.den;//context->streams[0]->codec->time_base.den;
        outPutEncContext->pix_fmt            = *pH264Codec->pix_fmts;
        outPutEncContext->width              =  iWidth;
        outPutEncContext->height             = iHeight;
    
        outPutEncContext->me_subpel_quality = 0;
        outPutEncContext->refs = 1;
        av_opt_set_int(outPutEncContext->priv_data, "scenechange_threshold", 0, 0);
       // outPutEncContext->scenechange_threshold = 0;
        outPutEncContext->trellis = 0;
        AVDictionary *options = nullptr;
        outPutEncContext->flags |= AV_CODEC_FLAG_GLOBAL_HEADER;
    /*

     版权声明：本文为CSDN博主「牧羊女说」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
     原文链接：https://blog.csdn.net/deliapu/java/article/details/81216718
     通过av_opt_set()的方式设置AVCodecContext中的priv_data
     //AVDictionary *param;
     if(pCodecCtx->codec_id == AV_CODEC_ID_H264)
     {
         //av_dict_set(&param, "preset", "veryfast", 0);
         //av_dict_set(&param, "tune", "zerolatency", 0);
         av_opt_set(pCodecCtx->priv_data, "preset", "superfast", 0); //设置priv_data的option
         av_opt_set(pCodecCtx->priv_data, "tune", "zerolatency", 0); //设置priv_data的option
     }

     **/
    
        int ret = avcodec_open2(outPutEncContext, pH264Codec, &options);
        if (ret < 0)
        {
            printf("%s", "open codec failed");
            return  ret;
        }
    return 1;
}

int MYMpegDraw::InitDecodeCodec(AVCodecID codecId)
{
    auto codec = avcodec_find_decoder(codecId);
    if(!codec) {
        return -1;
    }
    decoderContext = avcodec_alloc_context3(nullptr);
    avcodec_parameters_to_context(decoderContext,  context->streams[videoIndex]->codecpar);
   // decoderContext = context->streams[0]->codec;
    if (!decoderContext) {
        fprintf(stderr, "Could not allocate video codec context\n");
        exit(1);
    }

    if (codec->capabilities & AV_CODEC_CAP_TRUNCATED)
        decoderContext->flags |= AV_CODEC_FLAG_TRUNCATED;
    int ret = avcodec_open2(decoderContext, codec, NULL);
    return ret;
}
bool MYMpegDraw::DecodeVideo(AVPacket* packet, AVFrame* frame){
    
    int ret = avcodec_send_packet(decoderContext, packet);
    if (ret >= 0 ){
        ret =  avcodec_receive_frame(decoderContext, frame);
        if (ret >=0 ){
            return true;
        }
    }
    return false;
//    int gotFrame = 0;
//    auto hr = avcodec_decode_video2(decoderContext, frame, &gotFrame, packet);
//    if(hr >= 0 && gotFrame != 0)
//    {
//        return true;
//    }
//    return false;
}
//No such filter: 'drawtext' 产生该问题的原因是drawtext这个filter没有被编译进ffmpeg的库里面 （一般来讲直接从官网上下载的库都是不包含drawtext这个filter的），所以我们得更改编译选项重新编译FFmpeg的源码。
int MYMpegDraw::InitFilter(AVCodecContext * codecContext){
    char args[512];
    int ret = 0;
    
    const AVFilter *buffersrc = avfilter_get_by_name("buffer");
    const AVFilter *buffersink = avfilter_get_by_name("buffersink");
    AVFilterInOut *outputs = avfilter_inout_alloc();
    AVFilterInOut *inputs = avfilter_inout_alloc();
    
    std::string filters_descr = "drawtext=fontsize=100:text=mpeg filter:x=100:y=100";
    enum AVPixelFormat pix_fmts[] = {AV_PIX_FMT_YUV420P,AV_PIX_FMT_YUV420P};
    
    filter_graph = avfilter_graph_alloc();
    if (!outputs || !inputs ||!filter_graph){
        ret = -1;
        std::cout<<"Cannot create buffer source"<<endl;
        goto end;
    }
    /* buffer video source: the decoded frames from the decoder will be inserted here. */
    sprintf(args,
               "video_size=%dx%d:pix_fmt=%d:time_base=%d/%d:pixel_aspect=%d/%d",
                codecContext->width, codecContext->height, codecContext->pix_fmt,
               // codecContext->time_base.num, codecContext->time_base.den,
            context->streams[videoIndex]->time_base.num,context->streams[videoIndex]->time_base.den,
                codecContext->sample_aspect_ratio.num, codecContext->sample_aspect_ratio.den);
    std::cout<<args<<endl;
//        sprintf_s(args, sizeof(args),
//            "video_size=%dx%d:pix_fmt=%d:time_base=%d/%d:pixel_aspect=%d/%d",
//            codecContext->width, codecContext->height, codecContext->pix_fmt,
//            codecContext->time_base.num, codecContext->time_base.den,
//            codecContext->sample_aspect_ratio.num, codecContext->sample_aspect_ratio.den);
    
        ret = avfilter_graph_create_filter(&buffersrc_ctx, buffersrc, "in",
            args, NULL, filter_graph);
        if (ret < 0) {
            av_log(NULL, AV_LOG_ERROR, "Cannot create buffer source\n");
            goto end;
        }
    
        /* buffer video sink: to terminate the filter chain. */
        ret = avfilter_graph_create_filter(&buffersink_ctx, buffersink, "out",
            NULL, NULL, filter_graph);
        if (ret < 0) {
            av_log(NULL, AV_LOG_ERROR, "Cannot create buffer sink\n");
            goto end;
        }
    
        ret = av_opt_set_int_list(buffersink_ctx, "pix_fmts", pix_fmts,
            AV_PIX_FMT_YUV420P, AV_OPT_SEARCH_CHILDREN);
        if (ret < 0) {
            av_log(NULL, AV_LOG_ERROR, "Cannot set output pixel format\n");
            goto end;
        }
    
        /* Endpoints for the filter graph. */
        outputs->name       = av_strdup("in");
        outputs->filter_ctx = buffersrc_ctx;
        outputs->pad_idx    = 0;
        outputs->next       = NULL;
    
        inputs->name       = av_strdup("out");
        inputs->filter_ctx = buffersink_ctx;
        inputs->pad_idx    = 0;
        inputs->next       = NULL;
        if ((ret = avfilter_graph_parse_ptr(filter_graph, filters_descr.c_str(),
            &inputs, &outputs, NULL)) < 0)
            goto end;
    
        if ((ret = avfilter_graph_config(filter_graph, NULL)) < 0)
            goto end;
        return ret;
    end:
        avfilter_inout_free(&inputs);
        avfilter_inout_free(&outputs);
    return ret;
}
int  MYMpegDraw::drawTextDain(std::string fileInput,std::string fileOutput,RGBSWSCALLBACK block){
        Init();
        if(OpenInput((char *)fileInput.c_str()) < 0){
            cout << "Open file Input failed!" << endl;
            return 0;
        }
        int ret = InitDecodeCodec(context->streams[videoIndex]->codecpar->codec_id);
        if(ret <0){
            cout << "InitDecodeCodec failed!" << endl;
            return 0;
        }
            ret = InitFilter(decoderContext);

    //        ret = InitEncoderCodec(decoderContext->width,decoderContext->height);
//        if(ret < 0){
//            cout << "open eccoder failed ret is " << ret<<endl;
//            cout << "InitEncoderCodec failed!" << endl;
//            return 0;
//        }
//        if(OpenOutput((char *)fileOutput.c_str()) < 0){
//            cout << "Open file Output failed!" << endl;
//            return 0;
//        }
    
        auto pSrcFrame = av_frame_alloc();
        auto  filterFrame = av_frame_alloc();
        int64_t  timeRecord = 0;
        int64_t  firstPacketTime = 0;
        int64_t outLastTime = av_gettime();
         SwsContext *sws_cxt = sws_getContext(decoderContext->width,  decoderContext->height, decoderContext->pix_fmt, decoderContext->width, decoderContext->height, AV_PIX_FMT_RGB24, SWS_BILINEAR, nullptr, nullptr, nullptr);
    AVRational frameRate = context->streams[videoIndex]->avg_frame_rate;
    float fps = 0.04;
    if (frameRate.num > 0 && frameRate.den > 0){
        fps = 1.0/av_q2d(frameRate);
    }
        while(true)
        {
            outLastTime = av_gettime();
            auto packet = ReadPacketFromSource();
            if(packet){
                if(timeRecord == 0){
                    firstPacketTime = av_gettime();
                    timeRecord++;
                }
                if(DecodeVideo(packet.get(),pSrcFrame)){
                    if (av_buffersrc_add_frame_flags(buffersrc_ctx, pSrcFrame, AV_BUFFERSRC_FLAG_KEEP_REF) >= 0){
                        if (av_buffersink_get_frame(buffersink_ctx, filterFrame) >= 0){
                            AVFrame *RGBFrame = av_frame_alloc();
                            int ret =  av_image_alloc(RGBFrame->data, RGBFrame->linesize, decoderContext->width, decoderContext->height, AV_PIX_FMT_RGB24, 1);
                               if (!sws_cxt&& ret < 0){
                                   std::cout<<"sws_cxt failed"<<endl;
                                   av_frame_free(&RGBFrame);
                                   av_free(RGBFrame);
                                   continue;
                               }
                               sws_scale(sws_cxt, filterFrame->data, filterFrame->linesize, 0, filterFrame->height, RGBFrame->data, RGBFrame->linesize);
                               //延迟
                               av_usleep(fps * 1000);
                               // 回调给参数
                               block(decoderContext->width,decoderContext->height,RGBFrame->data[0],RGBFrame->linesize[0]);
//                            AVPacket *pTmpPkt = (AVPacket *)av_malloc(sizeof(AVPacket));
//                            av_init_packet(pTmpPkt);
//                            pTmpPkt->data = NULL;
//                            pTmpPkt->size = 0;
//                            int ret = avcodec_send_frame(outPutEncContext, filterFrame);
//                            if (ret >= 0 ){
//                                ret = avcodec_receive_packet(outPutEncContext, pTmpPkt);
//                                if (ret >=0){
//                                    ret = av_write_frame(outputContext, pTmpPkt);
//                                    av_packet_unref(pTmpPkt);
//                                }
//                            }
                        }
                    }
                }
            }
            else break;
        }
        CloseInput();
        CloseOutput();
        std::cout <<"Transcode file end!" << endl;
      //  this_thread::sleep_for(chrono::hours(10));
    return ret;
}
