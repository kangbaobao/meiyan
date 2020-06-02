//
//  MYCustomBitFilter.m
//  meiyan
//
//  Created by kzw on 2020/5/27.
//  Copyright © 2020 康子文. All rights reserved.
//

#import "MYCustomBitFilter.h"
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
@interface  MYCustomBitFilter(){
    
}
@property(nonatomic,assign)GLuint thresholdUniform;
@end
@implementation MYCustomBitFilter
-(instancetype)init{
    if (self = [super initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:kGPUImageCustomBitFragShaderString]){
        self.thresholdUniform = [filterProgram uniformIndex:@"threshold"];
    }
    return self;
}
-(void)setupFilterForSize:(CGSize)filterFrameSize{
//    runSynchronouslyOnVideoProcessingQueue(^{
//        [GPUImageContext setActiveShaderProgram:filterProgram];
//
//    });
}
-(void)setThreshold:(CGFloat)threshold{
    _threshold = threshold;
    [self setFloat:threshold forUniform:self.thresholdUniform program:filterProgram];
}
@end
