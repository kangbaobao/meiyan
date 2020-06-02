//
//  MYCustomCirleFilter.m
//  meiyan
//
//  Created by kzw on 2020/5/28.
//  Copyright © 2020 康子文. All rights reserved.
//

#import "MYCustomCirleFilter.h"
//计算宽高比 防止非正方形切成椭圆 中心点跟随宽高比变化，不然切出来的原中心点移位
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
//        float dist = distance(textureCoordinate,vec2(0.5,0.5));
       float dist = distance(newCoord,centerCoord);
        if (dist < 0.5){
           gl_FragColor = vec4(rgbColor,1.0);
        }else{
            discard;
        }
    }
);
@interface  MYCustomCirleFilter(){
    
}
@property(nonatomic,assign)GLuint whScaleUniform;
@property(nonatomic,assign)CGFloat whScale;
@end
@implementation MYCustomCirleFilter
-(instancetype)init{
    if (self = [super initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:kGPUImageCustomCirleFragShaderString]){
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
//-(void)setThreshold:(CGFloat)threshold{
//    _threshold = threshold;
//    [self setFloat:threshold forUniform:self.thresholdUniform program:filterProgram];
//}
@end
