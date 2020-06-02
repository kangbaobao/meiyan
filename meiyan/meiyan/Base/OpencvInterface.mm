//
//  OpencvInterface.m
//  meiyan
//
//  Created by 康子文 on 2019/10/24.
//  Copyright © 2019 康子文. All rights reserved.
//

#import "OpencvInterface.h"
#import "UIImage+OpenCV.h"

@implementation OpencvInterface
+(UIImage *)testGray:(UIImage * )srcImg{
    cv::Mat mat = srcImg.CVMat;
    cv::cvtColor(mat, mat, CV_BGR2GRAY);
    return [[UIImage alloc] initWithCVMat:mat];
}
@end
