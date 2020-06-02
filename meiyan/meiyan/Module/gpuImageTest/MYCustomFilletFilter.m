//
//  MYCustomFilletFilter.m
//  meiyan
//
//  Created by kzw on 2020/5/28.
//  Copyright © 2020 康子文. All rights reserved.
//

#import "MYCustomFilletFilter.h"
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
@interface MYCustomFilletFilter(){
    
}
@property(nonatomic,assign)GLuint filletUniform;

@property(nonatomic,assign)GLuint whScaleUniform;
@property(nonatomic,assign)CGFloat whScale;
@end
@implementation MYCustomFilletFilter
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
@end
