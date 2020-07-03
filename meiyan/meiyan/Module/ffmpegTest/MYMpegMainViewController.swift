//
//  MYMpegMainViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/21.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVKit
import AVFoundation
import MobileCoreServices
//GPUImageGPUImageRawDataInput
class MYMpegMainViewController: UIViewController {
    var picker :UIImagePickerController?
    var currentKey :String?
     var dataArray = [
            (title:"ffmpeg的使用",data:[
                (title:"读取第一帧(保存到cachesl目录)",key:"mpegFirstPicture"),
                (title:"sws_scale转码RGB，RawDataInput读入",key:"mpegswsScalePicture"),
                (title:"ffmpeg播放视频（无音频）",key:"mpegOnlyVideo"),
                (title:"转码（MOV->MP4）",key:"toMp4Video"),
                (title:"ffmpeg调用摄像头（无音频）",key:"mpegOnlyCerma"),
                (title:"FFmpeg硬件解码(Metal渲染)",key:"MetalTextureVideoHW")

                //MYMpegOnlyCermaController
            ]),
            
        ]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tabBarItem = UITabBarItem.init(title: "FFmpeg", image: R.image.products_noselect()?.withRenderingMode(.alwaysOriginal), selectedImage:R.image.products_select()?.withRenderingMode(.alwaysOriginal))
            self.tabBarItem.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor :RGB_ColorHex(rgb: 0x999999),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11)
            ], for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension MYMpegMainViewController :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          let cData = dataArray[section].data
          return cData.count
      }
      func numberOfSections(in tableView: UITableView) -> Int {
          return dataArray.count

      }
      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let lab = UILabel.init()
          let title = dataArray[section].title
          lab.text = title
          return lab
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "MYGPUMainTableViewCell") as! MYGPUMainTableViewCell
          let (title,_) = dataArray[indexPath.section].data[indexPath.row]
          cell.lab.text = title
          return  cell
      }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let (_,key) = dataArray[indexPath.section].data[indexPath.row]
           let storyboard = self.storyboard
        
        switch key {
         case "mpegFirstPicture":
            readvideoFromLibrary()
            currentKey = "mpegFirstPicture"
        case "mpegswsScalePicture":
            readvideoFromLibrary()
            currentKey = "mpegswsScalePicture"
        case "mpegOnlyVideo":
               readvideoFromLibrary()
               currentKey = "mpegOnlyVideo"
        case "toMp4Video":
            readvideoFromLibrary()
            currentKey = "toMp4Video"
        case "mpegOnlyCerma":
             mpegOnlyCerma()
        case "MetalTextureVideoHW":
            readvideoFromLibrary()
            currentKey = "MetalTextureVideoHW"
        default:
            print("")
        }
    }
    
    func readvideoFromLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
              if self.picker == nil {
                  self.picker = UIImagePickerController()
                self.picker?.sourceType = UIImagePickerController.SourceType.photoLibrary
                  self.picker?.delegate = self
                  //控制相册中显示视频和照片
                
                  self.picker?.mediaTypes = [kUTTypeMovie as String]//["public.movie", "public.image"]
                  
                  self.picker?.allowsEditing = false
                  
              }
              self.present(picker!, animated: true, completion: nil)
          } else {
              print("读取图库失败")
          }
    }
}

extension MYMpegMainViewController:UIImagePickerControllerDelegate , UINavigationControllerDelegate{
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("info :\(info)")
        print("info :\(String(describing: info[UIImagePickerController.InfoKey.mediaURL].self))")
        let video :URL? = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        print("video :\(String(describing: video))")
        picker.dismiss(animated: true, completion: nil)
        mpegselect(video: video)
    }
    func mpegselect(video :URL?){
        let cPtah = PTFileHandler.pathCaches + "/" + (video?.lastPathComponent  ?? "ffVideo")
        PTFileHandler.clearChacheFile([cPtah])
        print("cpath : %@",cPtah)
        let fileUrl = URL.init(fileURLWithPath: cPtah)
        PTFileHandler.copyNameSourcePath(src: video!, to: fileUrl)
        if currentKey == "mpegFirstPicture" {
            mpegFirstView(fileUrl: fileUrl)
        } else if currentKey == "mpegswsScalePicture"{
          SWSPicView(fileUrl: fileUrl)
        }else if currentKey == "mpegOnlyVideo"{
            mpegOnlyVideo(fileUrl: fileUrl)
        }else if currentKey == "toMp4Video"{
            toMp4Video(fileUrl: fileUrl)
        }else if currentKey == "MetalTextureVideoHW"{
            hwMetalVideo(fileUrl: fileUrl)
        }
//        else if currentKey == "mpegOnlyCerma"{
//        }
   
    }
    func mpegFirstView(fileUrl:URL){
        let vc =  MYMpegFirstViewController.init()
        vc.srcPath = fileUrl.absoluteString
        self.navigationController?.pushViewController(vc, animated: true)
        vc.message =
        """
        mpegUtils.cpp 文件中
        
        //获取一张图片
        int puctureMain(string inputStr,string outpuStr)
        {
            Init();
            unsigned version = avcodec_version();
            printf("version : %d\n",version);
            int ret = OpenInput(inputStr.c_str());//("rtsp://admin:admin12345@192.168.1.65:554/h264/ch1/main/av_stream");
            if(ret >= 0)
            {
                ret = OpenOutput(outpuStr.c_str());
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
            initEncoderCodec(inputContext->streams[videoIndex],&encodeContext);

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

        """
    }
    func SWSPicView(fileUrl:URL){
        let vc =  MYMpegSWSPicViewController.init()
          vc.srcPath = fileUrl.absoluteString//video?.absoluteString
          self.navigationController?.pushViewController(vc, animated: true)

          vc.message =
          """
          mpegUtils.cpp 文件中 yuv转RGB：
          
               int ret =  av_image_alloc(RGBFrame->data, RGBFrame->linesize, codecContext->width, codecContext->height, AV_PIX_FMT_RGB24, 1);
                           SwsContext *sws_cxt = sws_getContext(codecContext->width,  codecContext->height, codecContext->pix_fmt, codecContext->width, codecContext->height, AV_PIX_FMT_RGB24, SWS_BILINEAR, nullptr, nullptr, nullptr);
                          std::cout << "RGBFrame linesize: "<< RGBFrame->linesize <<endl;

                          if (!sws_cxt&& ret < 0){
                              std::cout<<"sws_cxt failed"<<endl;
                              av_frame_free(&RGBFrame);
                              av_free(RGBFrame);
                              continue;
                          }
                          sws_scale(sws_cxt, videoFrame->data, videoFrame->linesize, 0, videoFrame->height, RGBFrame->data, RGBFrame->linesize);
                          // 函数指针回调给参数
                          block(codecContext->width,codecContext->height,RGBFrame->data[0],RGBFrame->linesize[0]);
          
          
          VideoUtils.mm 文件 处理c语言的函数指针回调：
          
          typedef  void (^RGBBlock)(uint8_t *,CGSize);
           static RGBBlock golbalRGBBlock = nil;

           +(void) swsPicture:(NSString *)src block:(RGBBlock)rgbBlock{
               golbalRGBBlock = rgbBlock;
               puctureswsScale(src.UTF8String, swsData);
           }
           +(void)dataRGB:(int)width height:(int)height r:(uint8_t *)r linsize:(int)linesize {
               NSLog(@"dataRGB...");
               CGSize size = CGSizeMake(width, height);
               if (golbalRGBBlock != nil) {
                   golbalRGBBlock(r,size);
               }
           }
           //回调
           static void swsData(int width, int height, uint8_t *r, int linesize){
               [VideoUtils dataRGB:width height:height r:r linsize:linesize];
           }
          
          
          
          MYMpegSWSPicViewController.swift 文件中处理转码后的RGB 送给GPUImageRawDataInput加载
          
          VideoUtils.swsPicture(srcPath!) {[weak self]  (rgb, size) in
              self?.pictureInput = GPUImageRawDataInput.init(bytes: rgb, size: size, pixelFormat: GPUPixelFormatRGB)
                  self?.pictureInput?.addTarget(self?.filter)
                  self?.filter?.addTarget(self?.imgView)
                  self?.filter?.useNextFrameForImageCapture()
                   self?.pictureInput?.processData()
          }
          
          """
    }
    func mpegOnlyVideo(fileUrl:URL){
        let vc =  MYMpegOnlyVideoController.init()
        vc.srcPath = fileUrl.absoluteString
        self.navigationController?.pushViewController(vc, animated: true)
        vc.message =
        """
        mpegUtils.cpp 文件中 yuv转RGB：

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
            std::cout <<"frameRate : "<<av_q2d(frameRate)<<endl; //30 每秒30帧
            AVRational timeBase = inputContext->streams[videoIndex]->time_base;
            std::cout<<"timeBase : "<<av_q2d(timeBase)<<endl;
            int64_t duration = inputContext->streams[videoIndex]->duration;
            std::cout<<"duration : "<<duration * av_q2d(timeBase)<<endl; //405.2 ，秒数

             while(true){
                auto packet = ReadPacketFromSource();
                 if (!packet){
                     //解码失败或解码完成则停止解码
                         break;
                 }
                if(packet && packet->stream_index == videoIndex){
                  //  std::cout<<"pts timebase : "<<packet->pts*av_q2d(timeBase)<<endl; //8.46667 秒数
                    if(Decode(inputContext->streams[videoIndex],packet.get(),videoFrame))
                    {
                        AVFrame *RGBFrame = av_frame_alloc();
                        //sws_scale转码
                      int ret =  av_image_alloc(RGBFrame->data, RGBFrame->linesize, codecContext->width, codecContext->height, AV_PIX_FMT_RGB24, 1);
                        if (!sws_cxt&& ret < 0){
                            std::cout<<"sws_cxt failed"<<endl;
                            av_frame_free(&RGBFrame);
                            av_free(RGBFrame);
                            continue;
                        }
                        sws_scale(sws_cxt, videoFrame->data, videoFrame->linesize, 0, videoFrame->height, RGBFrame->data, RGBFrame->linesize);
                        //延迟
                        av_usleep(fps * 1000);
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
                        
                        av_frame_free(&RGBFrame);
                        av_free(RGBFrame);
                    }
                }
             }
             cout <<"Get Video End "<<endl;
            sws_freeContext(sws_cxt);
             av_frame_free(&videoFrame);
             avcodec_close(encodeContext);
            CloseInput();
            CloseOutput();
            return 0;
        }
        """
    }
    func mpegOnlyCerma(){
        let vc =  MYMpegOnlyCermaController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        vc.message =
        """
        mpegUtils.cpp 文件中 yuv转RGB：
        //打开摄像头
        static int OpenCermaInput(){
            avdevice_register_all();
            inputContext = avformat_alloc_context();
            lastReadpackTime = av_gettime();
            inputContext->interrupt_callback.callback = ineterrupt_cb;
            AVDictionary* options = NULL;
        //    av_dict_set(&options, "framerate", "30", 0);
            av_dict_set(&options, "framerate", "60", 0);
            // 640x480 不支持帧率30
            av_dict_set(&options, "video_size", "640x480", 0);//"1280x720"
            //传1 是前置摄像头，默认是0 后置摄像头
            av_dict_set(&options, "video_device_index", "1", 0);
            AVInputFormat *iformat = av_find_input_format("avfoundation");
            //iformat->priv_class
            int ret = avformat_open_input(&inputContext,"0",iformat,&options);
            if(ret!=0){ //
                printf("Couldn't open input stream.\n");
                char errbuf[1024] = {0};
                av_strerror(ret, errbuf, 1024);
                std::cout << "出错原因 ：" <<errbuf<<endl;
                return -1;
            }
             ret = avformat_find_stream_info(inputContext, nullptr);
            if (ret < 0 ){
                std::cout << "Find input file stream inform failed\n"<<endl;
                return ret;
            }else{
                std::cout << "打开摄像头成功haha \n"<<endl;
            }
            return ret;
        }
        """
    }
    func toMp4Video(fileUrl:URL){
        let vc =  MYMpegToMp4VideoController.init()
        vc.srcPath = fileUrl.absoluteString
        self.navigationController?.pushViewController(vc, animated: true)
        vc.message =
        """
         mpegUtils.cpp
        
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
        """
    }
    func hwMetalVideo(fileUrl: URL){
        let vc = MYMetalTextureVideoController.init()
        vc.isHW = true
        vc.srcPath = fileUrl.absoluteString
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
