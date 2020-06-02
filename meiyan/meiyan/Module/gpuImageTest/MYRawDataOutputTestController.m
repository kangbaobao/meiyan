//
//  MYRawDataOutputTestController.m
//  meiyan
//
//  Created by kzw on 2020/6/2.
//  Copyright © 2020 康子文. All rights reserved.
//

#import "MYRawDataOutputTestController.h"
#import "GPUImage.h"
@interface MYRawDataOutputTestController (){
    GPUImageVideoCamera *videoCamera;

}
@property (nonatomic , strong) UIImageView *mImageView;
@property (nonatomic , strong) GPUImageRawDataOutput *mOutput;
@end

@implementation MYRawDataOutputTestController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.mImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.mImageView.contentMode = UIViewContentModeScaleAspectFill;//UIViewContentModeScaleAspectFit;
     [self.view addSubview:self.mImageView];
     
     videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
     videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
     videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
     self.mOutput = [[GPUImageRawDataOutput alloc] initWithImageSize:CGSizeMake(640, 480) resultsInBGRAFormat:YES];
     [videoCamera addTarget:self.mOutput];
    
    __weak typeof(self) wself = self;
    __weak typeof(self.mOutput) weakOutput = self.mOutput;
    [self.mOutput setNewFrameAvailableBlock:^{
        __strong GPUImageRawDataOutput *strongOutput = weakOutput;
        __strong typeof(wself) strongSelf = wself;
        [strongOutput lockFramebufferForReading];
        GLubyte *outputBytes = [strongOutput rawBytesForImage];
        NSInteger bytesPerRow = [strongOutput bytesPerRowInOutput];
        
        CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, outputBytes, bytesPerRow * 480, NULL);
        CGImageRef cgImage = CGImageCreate(640, 480, 8, 32, bytesPerRow, rgbColorSpace, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little, provider, NULL, true, kCGRenderingIntentDefault);
        
        UIImage *image = [UIImage imageWithCGImage:cgImage];
        [strongSelf updateWithImage:image];
        CGImageRelease(cgImage);
        [strongOutput unlockFramebufferAfterReading];

    }];
    [videoCamera startCameraCapture];


}
- (void)updateWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mImageView.image = image;
    });
}



@end
