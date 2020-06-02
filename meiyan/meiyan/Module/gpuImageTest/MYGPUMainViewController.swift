//
//  MYGPUMainViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/14.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
func RGB_ColorHex(rgb :Int) -> UIColor{
    let r = (rgb & 0xff0000) >> 16
    let g = (rgb & 0x00ff00) >> 8
    let b = (rgb & 0x0000ff) >> 0
    return UIColor.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
}
class MYGPUMainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataArray = [
        (title:"GPUimage的基本使用",data:[
           //
           (title:"PipeLine的使用",key:"usePipeLine"),
           (title:"GPUImageFilterGroup的使用",key:"ImageFilterGroup"),
           (title:"调用摄像头（VideoCamera）",key:"sampleCamera"),
           (title:"保存视频（MovieWriter）",key:"MovieWriter"),
           (title:"视频合并（GPUImageMovie）",key:"GPUMovie"),
           (title:"原始rgba输出（RawDataOutput）",key:"RawDataOutput"),
           (title:"UI操作合并到视频（UIElement）",key:"UIElement"),

           //
               ]),
        (title:"自定义shader",data:[
           //
           (title:"二值图像(GPUImageFilter子类)",key:"CustomBitFilter"),
           (title:"圆形图像",key:"CirleFilter"),
           (title:"圆角图像",key:"CustomFillet"),

           //
               ]),
        (title:"GPUimage的滤镜的使用",data:[
            (title:"灰色图sample filter",key:"sampleFilter"),
            (title:"模糊图片处理",key:"tiltShiftFilter"),
            (title:"GPUImageTransformFilter的使用",key:"TransformFilter"),
            (title:"裁剪(GPUImageCropFilter)",key:"CropFilter"),
            (title:"锐化(GPUImageSharpenFilter)",key:"SharpenFilter"),
            (title:"运动模糊(GPUImageMotionBlurFilter)",key:"MotionBlurFilter"),
            (title:"运动模糊2(GPUImageZoomBlurFilter)",key:"ZoomBlurFilter"),
            (title:"高斯模糊(GPUImageGaussianBlurFilter)",key:"GaussianBlurFilter"),
            (title:"单通道高斯(GPUImageSingleComponentGaussianBlurFilter)",key:"SingleComponentGaussianBlurFilter"),
            (title:"双边模糊(GPUImageBilateralFilter)",key:"BilateralFilter"),
            (title:"膨胀(GPUImageDilationFilter)",key:"DilationFilter"),
            (title:"腐蚀(GPUImageErosionFilter)",key:"ErosionFilter"),
            (title:"中值滤波(GPUImageMedianFilter)",key:"MedianFilter"),
            (title:"自定义3*3卷积核(GPUImage3x3Convolution)",key:"3x3ConvolutionFilter"),
            (title:"Sobel算子(GPUImageSobelEdgeDetection",key:"SobelEdgeDetectionFilter"),
            (title:"二进制算子(GPUImageLocalBinaryPattern)",key:"LocalBinaryPatternFilter"),
            (title:"反锐化(GPUImageUnsharpMaskFilter)",key:"UnsharpMaskFilter"),
            (title:"iOS Blur(GPUImageiOSBlurFilter)",key:"iOSBlurFilter"),
            (title:"TiltShift(GPUImageTiltShiftFilter)",key:"TiltShiftFilter"),
        ]),
    ]

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tabBarItem = UITabBarItem.init(title:  "GPUImage", image: R.image.home_noselect()?.withRenderingMode(.alwaysOriginal), selectedImage:R.image.home_select()?.withRenderingMode(.alwaysOriginal))
        self.tabBarItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor :RGB_ColorHex(rgb: 0x999999),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11)
        ], for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "GPUImage的使用"

        
    }

    
}
extension MYGPUMainViewController :UITableViewDelegate,UITableViewDataSource{
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
        ////取得UIStoryboard对象
          // UIStoryboard *storyboard=self.storyboard;//获取当前的storyboard对象
           //UIStoryboard * main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        let storyboard = self.storyboard
        switch key {
        case "sampleFilter":
          let arr = MYGPUImageUtils.sampleFilter()
          let vc = storyboard?.instantiateViewController(withIdentifier: "MYGPUTwoImageViewController") as! MYGPUTwoImageViewController
            vc.arr = arr
          self.navigationController?.pushViewController(vc, animated: true)
            print("")
        case  "sampleCamera":
            let vc = storyboard?.instantiateViewController(withIdentifier: "MYGPUSampleCameraViewController") as! MYGPUSampleCameraViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case "tiltShiftFilter":
            let vc = MYGPUTiltShiftViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        case "ImageFilterGroup":
            let vc = MYGPUFilterGroupViewController.init()
              self.navigationController?.pushViewController(vc, animated: true)
        case  "TransformFilter":
              let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
              vc.filterModel = FilterModel.init(name: "旋转", filterType: .basicOperation, range: (0.0, Float(Double.pi), 0.0), initCallback: { () -> (AnyObject) in
                return GPUImageTransformFilter.init()
              }, valueChangedCallback: { (filter, value) in
                 (filter as! GPUImageTransformFilter).affineTransform = CGAffineTransform(rotationAngle:CGFloat(value))
              }, nil)
            self.navigationController?.pushViewController(vc, animated: true)
        case "CustomBitFilter":
              let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
              vc.filterModel = FilterModel.init(name: "自定义二值图", filterType: .basicOperation, range: (0.0, 1.0, 0.8), initCallback: { () -> (AnyObject) in
                return MYCustomBitFilter.init()
              }, valueChangedCallback: { (filter, value) in
                let f = (filter as! MYCustomBitFilter)
                f.threshold = value
              }, nil)
              vc.filterModel.message =
              """
              NSString *const  kGPUImageCustomBitFragShaderString =
              SHADER_STRING(
                  precision highp float;
                  varying highp vec2 textureCoordinate;
                  uniform sampler2D inputImageTexture;
                  uniform float threshold;
                  void main()
                  {
                      const vec3 W = vec3(0.2125,0.7154,0.0721);
                      vec3 rgb = texture2D(inputImageTexture, textureCoordinate).rgb;
                      float gray = dot(rgb,W);
                      float oColor = 0.0;
                      if (gray > threshold){
                          oColor = 1.0;
                      }
                      gl_FragColor = vec4(vec3(oColor),1.0);
                  }
              );
              -(void)setThreshold:(CGFloat)threshold{
                  _threshold = threshold;
                  [self setFloat:threshold forUniform:self.thresholdUniform program:filterProgram];
              }
              """
            self.navigationController?.pushViewController(vc, animated: true)
        case  "CropFilter":
          CropFilter()
        case "SharpenFilter":
            SharpenFilter()
        case "MotionBlurFilter":
            MotionBlurFilter()
        case "ZoomBlurFilter":
             ZoomBlurFilter()
        case "GaussianBlurFilter":
            GaussianBlur()
        case "SingleComponentGaussianBlurFilter":
            SingleComponentGaussianBlurFilter()
        case "BilateralFilter":
            BilateralFilter()
        case "DilationFilter":
            DilationFilter()
        case "ErosionFilter":
            ErosionFilter()
        case "MedianFilter":
             MedianFilter()
        case "3x3ConvolutionFilter":
            g3x3ConvolutionFilter()
        case "SobelEdgeDetectionFilter":
            SobelEdgeDetectionFilter()
        case "LocalBinaryPatternFilter":
            LocalBinaryPattern()
        case "UnsharpMaskFilter":
            UnsharpMaskFilter()
        case "iOSBlurFilter":
            iOSBlurFilter()
        case "TiltShiftFilter":
            TiltShiftFilter()
        case "MovieWriter":
            MovieWriter()
        case "GPUMovie":
            GPUMovie()
        case "usePipeLine":
            usePipeLine()
        case "CirleFilter":
            CirleFilter()
        case "CustomFillet":
            CustomFillet()
        case "RawDataOutput":
            RawDataOutput()
        case "UIElement":
            UIElement()
            
        default:
           print("")
        }
    }
}
//处理
extension MYGPUMainViewController {
    func RawDataOutput(){
        //MYRawDataOutputTestController
        let vc = MYRawDataOutputTestController.init()
        self.navigationController?.pushViewController(vc, animated: true)

    }
    func UIElement(){
        //MYRawDataOutputTestController
        let vc = MYUIElementViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)

    }
    //
    func CropFilter(){
             let shuoming =
           """
           传入局部的纹理坐标实现剪裁效果，不必在着色器里操作
           主要实现：
           CGFloat minX = _cropRegion.origin.x;
           CGFloat minY = _cropRegion.origin.y;
           CGFloat maxX = CGRectGetMaxX(_cropRegion);
           CGFloat maxY = CGRectGetMaxY(_cropRegion);
           """
          let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
            vc.filterModel = FilterModel.init(name: "剪裁", filterType: .basicOperation, range: (0.0, 1.0, 1.0), initCallback: { () -> (AnyObject) in
                           return GPUImageCropFilter.init()
                         }, valueChangedCallback: { (filter, value) in
                            
                            let mFilter = filter as! GPUImageCropFilter
                            if value > 0.05 && value < 0.99{
                              mFilter.cropRegion =  CGRect.init(x:  CGFloat((1.0 - value) / 2.0) , y:   CGFloat((1.0 - value)/2.0), width:   CGFloat(value), height:  CGFloat(value))
//                                mFilter.cropRegion =  CGRect.init(x: 0.0 , y: 0.0, width:   CGFloat(value), height:  CGFloat(value))
                            }

            }, shuoming)
            self.navigationController?.pushViewController(vc, animated: true)
    }
    func CirleFilter(){
        //
         let shuoming =
       """
       计算宽高比 防止非正方形切成椭圆 中心点跟随宽高比变化，不然切出来的原中心点移位
       NSString *const  kGPUImageCustomCirleFragShaderString =
       SHADER_STRING(
       precision highp float;
       varying highp vec2 textureCoordinate;
       uniform sampler2D inputImageTexture;
       uniform float whScale;
       void main()
       {
        vec3 rgbColor = texture2D(inputImageTexture, textureCoordinate).rgb;
        vec2 newCoord;
        vec2 centerCoord;
        if (whScale > 1.0){
            newCoord = vec2(textureCoordinate.x/whScale,textureCoordinate.y);
            centerCoord = vec2(0.5/whScale,0.5);
        }else{
            newCoord = vec2(textureCoordinate.x,textureCoordinate.y/whScale);
            centerCoord = vec2(0.5,0.5/whScale);
        }
       // float dist = distance(textureCoordinate,vec2(0.5,0.5));
       float dist = distance(newCoord,centerCoord);

        if (dist < 0.5){
           gl_FragColor = vec4(rgbColor,1.0);
        }else{
            discard;
        }
       }
       );

       -(void)setupFilterForSize:(CGSize)filterFrameSize{
           runSynchronouslyOnVideoProcessingQueue(^{
                [GPUImageContext setActiveShaderProgram:self->filterProgram];
                [self setFloat:filterFrameSize.width/filterFrameSize.height forUniform:self.whScaleUniform program:self->filterProgram];
           });
       }
       """
      let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "剪裁", filterType: .basicOperation, range: (0.0, 1.0, 1.0), initCallback: { () -> (AnyObject) in
                        MYCustomCirleFilter.init()
                     }, valueChangedCallback: { (filter, value) in
        }, shuoming)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func CustomFillet(){
        //MYCustomFilletFilter
           let shuoming =
         """
         // 圆角 弧度较大 有待完善
         NSString *const  kGPUImageCustomFilletFragShaderString =
         SHADER_STRING(
         precision highp float;
         varying highp vec2 textureCoordinate;
         uniform sampler2D inputImageTexture;
         uniform float whScale;
         uniform float fillet;
         void main()
         {
         vec3 rgbColor = texture2D(inputImageTexture, textureCoordinate).rgb;
         vec2 newCoord;
         if (whScale > 1.0){
            newCoord = vec2(1.0 - fillet ,1.0);
         }else{
            newCoord = vec2(1.0,1.0 - fillet);
         }
         float nei = distance(textureCoordinate,vec2(0.5,0.5));
         float dist = distance(newCoord,vec2(0.5,0.5));
         if (nei < dist){
           gl_FragColor = vec4(rgbColor,1.0);
         }else{
            discard;
         }
         }
         );

         -(instancetype)init{
         if (self = [super initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:kGPUImageCustomFilletFragShaderString]){
         self.filletUniform = [filterProgram uniformIndex:@"fillet"];
         self.whScaleUniform = [filterProgram uniformIndex:@"whScale"];
         }
         return self;
         }
         -(void)setupFilterForSize:(CGSize)filterFrameSize{
         runSynchronouslyOnVideoProcessingQueue(^{
         [GPUImageContext setActiveShaderProgram:self->filterProgram];
         [self setFloat:filterFrameSize.width/filterFrameSize.height forUniform:self.whScaleUniform program:self->filterProgram];
         });
         }
         - (void)setFillet:(CGFloat)fillet{
         _fillet = fillet;
         [self setFloat:_fillet/2.0 forUniform:self.filletUniform program:self->filterProgram];

         }
         """
        let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "圆角", filterType: .basicOperation, range: (0.0, 1.0, 0.7), initCallback: { () -> (AnyObject) in
                          MYCustomFilletFilter.init()
                       }, valueChangedCallback: { (filter, value) in
                        let f = filter as! MYCustomFilletFilter
                        f.fillet = value
          }, shuoming)
          self.navigationController?.pushViewController(vc, animated: true)
    }
    //锐化
    func SharpenFilter(){
        let shuoming = """
卷积操作 中心点和上下左右四个点加权，
在定点中计算加权值：
    centerMultiplier = 1.0 + 4.0 * sharpness;
    edgeMultiplier = sharpness;
片元中计算色值：
  gl_FragColor = vec4((textureColor * centerMultiplier - (leftTextureColor * edgeMultiplier + rightTextureColor * edgeMultiplier + topTextureColor * edgeMultiplier + bottomTextureColor * edgeMultiplier)), texture2D(inputImageTexture, bottomTextureCoordinate).w);

"""
            let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
            vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range:  (-4.0, 4.0, 0.0), initCallback: { () -> (AnyObject) in
                           return GPUImageSharpenFilter.init()
                         }, valueChangedCallback: { (filter, value) in
                            let mFilter = filter as! GPUImageSharpenFilter
                            mFilter.sharpness = CGFloat(value)
            },
          shuoming)
            self.navigationController?.pushViewController(vc, animated: true)
    }
    func MotionBlurFilter(){
         let shuoming = """
        3*3卷积核操作 进度条修改blurSize，着色器传入uniform vec2 directionalTexelStep;
        默认 self.blurSize = 2.5;
        self.blurAngle = 0.0;
        计算 directionalTexelStep
        aspectRatio = (inputTextureSize.width / inputTextureSize.height);
        texelOffsets.x = _blurSize * sin(_blurAngle * M_PI / 180.0) * aspectRatio / inputTextureSize.height;
        texelOffsets.y = _blurSize * cos(_blurAngle * M_PI / 180.0) / inputTextureSize.height;

        """
        let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
                       return GPUImageMotionBlurFilter.init()
                     }, valueChangedCallback: { (filter, value) in
                        let mFilter = filter as! GPUImageMotionBlurFilter
                        mFilter.blurSize = value
        },
      shuoming)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func ZoomBlurFilter(){
         let shuoming = """
        3*3卷积核操作 进度条修改blurSize(0.0 ~ 1.0)

        highp vec2 samplingOffset = 1.0/100.0 * (blurCenter - textureCoordinate) * blurSize;

        lowp vec4 fragmentColor = texture2D(inputImageTexture, textureCoordinate) * 0.18;
        fragmentColor += texture2D(inputImageTexture, textureCoordinate + samplingOffset) * 0.15;
        fragmentColor += texture2D(inputImageTexture, textureCoordinate + (2.0 * samplingOffset)) *  0.12;
        fragmentColor += texture2D(inputImageTexture, textureCoordinate + (3.0 * samplingOffset)) * 0.09;
        fragmentColor += texture2D(inputImageTexture, textureCoordinate + (4.0 * samplingOffset)) * 0.05;
        fragmentColor += texture2D(inputImageTexture, textureCoordinate - samplingOffset) * 0.15;
        fragmentColor += texture2D(inputImageTexture, textureCoordinate - (2.0 * samplingOffset)) *  0.12;
        fragmentColor += texture2D(inputImageTexture, textureCoordinate - (3.0 * samplingOffset)) * 0.09;
        fragmentColor += texture2D(inputImageTexture, textureCoordinate - (4.0 * samplingOffset)) * 0.05;

        gl_FragColor = fragmentColor;
        """
        let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
                       return GPUImageZoomBlurFilter.init()
                     }, valueChangedCallback: { (filter, value) in
                        let mFilter = filter as! GPUImageZoomBlurFilter
                        mFilter.blurSize = value
        },
      shuoming)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func GaussianBlur(){
         let shuoming = """
        动态计算卷积核大小 进度条修改blurRadiusInPixels，用以计算卷积核大小
        """
        let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 5, 0.8), initCallback: { () -> (AnyObject) in
                       return GPUImageGaussianBlurFilter.init()
                     }, valueChangedCallback: { (filter, value) in
                        let mFilter = filter as! GPUImageGaussianBlurFilter
                        mFilter.blurRadiusInPixels = value
                    
        },
      shuoming)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func SingleComponentGaussianBlurFilter(){
           let shuoming = """
          只在红色通道上高斯处理
          """
          let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.5, 5.0, 2.0), initCallback: { () -> (AnyObject) in
                         return GPUImageSingleComponentGaussianBlurFilter.init()
                       }, valueChangedCallback: { (filter, value) in
                          let mFilter = filter as! GPUImageSingleComponentGaussianBlurFilter
                          mFilter.blurRadiusInPixels = value
          },
        shuoming)
          self.navigationController?.pushViewController(vc, animated: true)
    }
    func BilateralFilter(){
        let shuoming = """
             3*3卷积
             """
             let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
           vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
                            return GPUImageBilateralFilter.init()
                          }, valueChangedCallback: { (filter, value) in
                             let mFilter = filter as! GPUImageBilateralFilter
                             mFilter.blurRadiusInPixels = value
             },
           shuoming)
             self.navigationController?.pushViewController(vc, animated: true)
    }
    //膨胀
    func DilationFilter(){
        let shuoming = """
              取最大值 可传入半径 1 2 3 4 就是要生成的卷积核大小，取的是红色通道数据，所以是灰色

             float centerIntensity = texture2D(inputImageTexture, centerTextureCoordinate).r;
             float oneStepPositiveIntensity = texture2D(inputImageTexture, oneStepPositiveTextureCoordinate).r;
             float oneStepNegativeIntensity = texture2D(inputImageTexture, oneStepNegativeTextureCoordinate).r;
             
             lowp float maxValue = max(centerIntensity, oneStepPositiveIntensity);
             maxValue = max(maxValue, oneStepNegativeIntensity);

             gl_FragColor = vec4(vec3(maxValue), 1.0);
             """
             let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
           vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
                            return GPUImageDilationFilter.init(radius: 3)
                          }, valueChangedCallback: { (filter, value) in
             },
           shuoming)
        
             self.navigationController?.pushViewController(vc, animated: true)
    }
    func ErosionFilter(){
        let shuoming = """
                   取最小值 可传入半径 1 2 3 4 就是要生成的卷积核，取的是红色通道数据，所以是灰色
                  """
                  let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
                vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
                    return GPUImageErosionFilter.init(radius: 3)
                               }, valueChangedCallback: { (filter, value) in
                  },
                shuoming)
                  self.navigationController?.pushViewController(vc, animated: true)
    }
     // GPUImageMedianFilter MedianFilter
    func MedianFilter(){
        let shuoming = """
                  3*3 卷积核 rgb取中值
                  进度条无效果

                  #define s2(a, b)                temp = a; a = min(a, b); b = max(temp, b);
                  #define mn3(a, b, c)            s2(a, b); s2(a, c);
                  #define mx3(a, b, c)            s2(b, c); s2(a, c);
                  
                  #define mnmx3(a, b, c)            mx3(a, b, c); s2(a, b);                                   // 3 exchanges
                  #define mnmx4(a, b, c, d)        s2(a, b); s2(c, d); s2(a, c); s2(b, d);                   // 4 exchanges
                  #define mnmx5(a, b, c, d, e)    s2(a, b); s2(c, d); mn3(a, c, e); mx3(b, d, e);           // 6 exchanges
                  #define mnmx6(a, b, c, d, e, f) s2(a, d); s2(b, e); s2(c, f); mn3(a, b, c); mx3(d, e, f); // 7 exchanges

                  vec3 v[6];
                  v[0] = texture2D(inputImageTexture, bottomLeftTextureCoordinate).rgb;
                  .
                  .
                  .
                  v[5] = texture2D(inputImageTexture, rightTextureCoordinate).rgb;

                  vec3 temp;

                  mnmx6(v[0], v[1], v[2], v[3], v[4], v[5]);
                  v[5] = texture2D(inputImageTexture, bottomTextureCoordinate).rgb;
                  mnmx5(v[1], v[2], v[3], v[4], v[5]);
                  v[5] = texture2D(inputImageTexture, topTextureCoordinate).rgb;
                  mnmx4(v[2], v[3], v[4], v[5]);
                  v[5] = texture2D(inputImageTexture, textureCoordinate).rgb;
                  mnmx3(v[3], v[4], v[5]);
                  gl_FragColor = vec4(v[4], 1.0);
                  """
                  let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
                vc.filterModel = FilterModel.init(name: "中值滤波", filterType: .basicOperation, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
                    return GPUImageMedianFilter.init()
                               }, valueChangedCallback: { (filter, value) in
                  },
                shuoming)
         self.navigationController?.pushViewController(vc, animated: true)
       // GPUImage3x3ConvolutionFilter
    }
    func g3x3ConvolutionFilter(){
        let shuoming = """
                      自定义 3*3 卷积核,
                      进度条无效果
                      [
                      -1.0, 0.0, 1.0,
                      -2.0, 0.0, 2.0,
                      -1.0, 0.0, 1.0]
                      .
                      .
                      .
                      vec3 topLeftColor = texture2D(inputImageTexture, topLeftTextureCoordinate).rgb;
                      
                      vec3 resultColor = topLeftColor * convolutionMatrix[0][0] + topColor * convolutionMatrix[0][1] + topRightColor * convolutionMatrix[0][2];
                      resultColor += leftColor * convolutionMatrix[1][0] + centerColor.rgb * convolutionMatrix[1][1] + rightColor * convolutionMatrix[1][2];
                      resultColor += bottomLeftColor * convolutionMatrix[2][0] + bottomColor * convolutionMatrix[2][1] + bottomRightColor * convolutionMatrix[2][2];
                      
                      gl_FragColor = vec4(resultColor, centerColor.a);
                      """
          let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "自定义卷积核", filterType: .custom, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
             GPUImage3x3ConvolutionFilter.init()
                       }, valueChangedCallback: { (filter, value) in
          },
           shuoming,{
                (pictureInput, basicOperation, renderView) in
            let mFilter = basicOperation as! GPUImage3x3ConvolutionFilter
            //The matrix is specified in row-major order, with the top left pixel being one.one and the bottom right three.three
//                        If the values in the matrix don't add up to 1.0, the image could be brightened or darkened.
            mFilter.convolutionKernel = GPUMatrix3x3.init(one: GPUVector3.init(one: -1.0, two: 0.0, three: 1.0), two: GPUVector3.init(one: -2.0, two: 0.0, three: 2.0), three: GPUVector3.init(one: -1.0, two: 0.0, three: 1.0))
            pictureInput.addTarget(mFilter)
            mFilter.addTarget(renderView)

        })
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func SobelEdgeDetectionFilter(){
        let shuoming = """
                  3*3 卷积核 Sobel算子,取红色通道上的颜色,进度条更改edgeStrength，0.0～1.0之间

                  float bottomLeftIntensity = texture2D(inputImageTexture, bottomLeftTextureCoordinate).r;
                   .
                   .
                   .
                  float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;

                  float h = -topLeftIntensity - 2.0 * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0 * bottomIntensity + bottomRightIntensity;
                  float v = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity;
                  float mag = length(vec2(h, v)) * edgeStrength;
                  gl_FragColor = vec4(vec3(mag), 1.0);
                  """
        let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "Sobel算子", filterType: .basicOperation, range: (0.0, 1.0, 0.5), initCallback: { () -> (AnyObject) in
            return GPUImageSobelEdgeDetectionFilter.init()
                       }, valueChangedCallback: { (filter, value) in
                        let mFilter = filter as! GPUImageSobelEdgeDetectionFilter
                        mFilter.edgeStrength = value
          },
        shuoming)
         self.navigationController?.pushViewController(vc, animated: true)
    }
    func LocalBinaryPattern(){
        let shuoming = """
                  3*3 卷积核 LocalBinaryPattern,取红色通道值计算
                  进度条无效果

                  lowp float centerIntensity = texture2D(inputImageTexture, textureCoordinate).r;
                  .
                  .
                  .
                  lowp float topIntensity = texture2D(inputImageTexture, topTextureCoordinate).r;

                  lowp float byteTally = 1.0 / 255.0 * step(centerIntensity, topRightIntensity);
                  byteTally += 2.0 / 255.0 * step(centerIntensity, topIntensity);
                  byteTally += 4.0 / 255.0 * step(centerIntensity, topLeftIntensity);
                  byteTally += 8.0 / 255.0 * step(centerIntensity, leftIntensity);
                  byteTally += 16.0 / 255.0 * step(centerIntensity, bottomLeftIntensity);
                  byteTally += 32.0 / 255.0 * step(centerIntensity, bottomIntensity);
                  byteTally += 64.0 / 255.0 * step(centerIntensity, bottomRightIntensity);
                  byteTally += 128.0 / 255.0 * step(centerIntensity, rightIntensity);
                  gl_FragColor = vec4(byteTally, byteTally, byteTally, 1.0);

                  注：
                  genType step (genType edge, genType x)，genType step (float edge, genType x)
                  如果x < edge，返回0.0，否则返回1.0
                  """
        let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
             GPUImageLocalBinaryPatternFilter.init()
                       }, valueChangedCallback: { (filter, value) in
          },
        shuoming)
         self.navigationController?.pushViewController(vc, animated: true)
    }
    func UnsharpMaskFilter(){
        let shuoming = """
                  3*3 卷积核 反锐化 继承自GPUImageFilterGroup 需要两张纹理，先高斯

                  blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
                  [self addFilter:blurFilter];
                  
                  unsharpMaskFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kGPUImageUnsharpMaskFragmentShaderString];
                  [self addFilter:unsharpMaskFilter];
                  
                  [blurFilter addTarget:unsharpMaskFilter atTextureLocation:1];
                  
                  self.initialFilters = [NSArray arrayWithObjects:blurFilter, unsharpMaskFilter, nil];
                  self.terminalFilter = unsharpMaskFilter;

                    片元着色器
                  lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
                  lowp vec3 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2).rgb;

                  gl_FragColor = vec4(sharpImageColor.rgb * intensity + blurredImageColor * (1.0 - intensity), sharpImageColor.a);
                  
                  """
        let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.0), initCallback: { () -> (AnyObject) in
             GPUImageUnsharpMaskFilter.init()
                       }, valueChangedCallback: { (filter, value) in
                        let mFilter = filter as! GPUImageUnsharpMaskFilter
                        mFilter.intensity = value
          },
        shuoming)
         self.navigationController?.pushViewController(vc, animated: true)
    }
    func iOSBlurFilter(){
         let shuoming = """
                   继承自GPUImageFilterGroup, 滑动条调整blurRadiusInPixels模糊半径
                   saturationFilter = [[GPUImageSaturationFilter alloc] init];
                   [self addFilter:saturationFilter];

                   blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
                   [self addFilter:blurFilter];

                   luminanceRangeFilter = [[GPUImageLuminanceRangeFilter alloc] init];
                   [self addFilter:luminanceRangeFilter];
                   [saturationFilter addTarget:blurFilter];
                   [blurFilter addTarget:luminanceRangeFilter];

                   self.initialFilters = [NSArray arrayWithObject:saturationFilter];
                   self.terminalFilter = luminanceRangeFilter;
                   """
         let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
        vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.3), initCallback: { () -> (AnyObject) in
              GPUImageiOSBlurFilter.init()
                        }, valueChangedCallback: { (filter, value) in
                         let mFilter = filter as! GPUImageiOSBlurFilter
                         mFilter.blurRadiusInPixels = value * 100
           },
         shuoming)
          self.navigationController?.pushViewController(vc, animated: true)
         
     }
    func TiltShiftFilter(){
           let shuoming = """
                     继承自GPUImageFilterGroup, 滑动条调整blurRadiusInPixels模糊半径
                     片元着色器:
                     varying highp vec2 textureCoordinate;
                     varying highp vec2 textureCoordinate2;
                     
                     uniform sampler2D inputImageTexture;
                     uniform sampler2D inputImageTexture2;
                     
                     uniform highp float topFocusLevel;
                     uniform highp float bottomFocusLevel;
                     uniform highp float focusFallOffRate;
                     
                     void main()
                     {
                         lowp vec4 sharpImageColor = texture2D(inputImageTexture, textureCoordinate);
                         lowp vec4 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate2);
                         
                         lowp float blurIntensity = 1.0 - smoothstep(topFocusLevel - focusFallOffRate, topFocusLevel, textureCoordinate2.y);
                         blurIntensity += smoothstep(bottomFocusLevel, bottomFocusLevel + focusFallOffRate, textureCoordinate2.y);
                         
                         gl_FragColor = mix(sharpImageColor, blurredImageColor, blurIntensity);
                     }
                     主要代码：
                     blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
                     [self addFilter:blurFilter];
                     
                     tiltShiftFilter = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromString:kGPUImageTiltShiftFragmentShaderString];
                     [self addFilter:tiltShiftFilter];
                     
                     [blurFilter addTarget:tiltShiftFilter atTextureLocation:1];
                     
                     self.initialFilters = [NSArray arrayWithObjects:blurFilter, tiltShiftFilter, nil];
                     self.terminalFilter = tiltShiftFilter;

                     滑动条设置值
                     blurFilter.blurRadiusInPixels = newValue;


                     帧缓存区设置：
                     glGenFramebuffers(1, &framebuffer);
                     glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);

                     CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, (int)_size.width, (int)_size.height, kCVPixelFormatType_32BGRA, attrs, &renderTarget);
                     if (err)
                     {
                     NSLog(@"FBO size: %f, %f", _size.width, _size.height);
                     NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
                     }
                     
                     err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, coreVideoTextureCache, renderTarget,
                                                            NULL, // texture attributes
                                                            GL_TEXTURE_2D,
                                                            _textureOptions.internalFormat, // opengl format
                                                            (int)_size.width,
                                                            (int)_size.height,
                                                            _textureOptions.format, // native iOS format
                                                            _textureOptions.type,
                                                            0,
                                                            &renderTexture);

                     glBindTexture(CVOpenGLESTextureGetTarget(renderTexture), CVOpenGLESTextureGetName(renderTexture));
                     _texture = CVOpenGLESTextureGetName(renderTexture);
                     glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _textureOptions.wrapS);
                     glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _textureOptions.wrapT);
                     
                     glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTexture), 0);
                     """
           let vc = storyboard?.instantiateViewController(withIdentifier: "MYBasesiderViewController") as! MYBasesiderViewController
          vc.filterModel = FilterModel.init(name: "", filterType: .basicOperation, range: (0.0, 1.0, 0.3), initCallback: { () -> (AnyObject) in
                GPUImageTiltShiftFilter.init()
                          }, valueChangedCallback: { (filter, value) in
                           let mFilter = filter as! GPUImageTiltShiftFilter
                           mFilter.blurRadiusInPixels = value * 10
             },
           shuoming)
            self.navigationController?.pushViewController(vc, animated: true)
       //    GPUImageCannyEdgeDetectionFilter
       }
    func MovieWriter(){
        let vc = MYGPUWriteVideoController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func GPUMovie(){
        let vc = MYGPUMovieViewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func usePipeLine(){
        let vc = MYGPUPipeLineController.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //
}
