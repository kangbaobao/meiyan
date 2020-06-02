//
//  MYToolUtils.h
//  meiyan
//
//  Created by kzw on 2020/5/22.
//  Copyright © 2020 康子文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage.h>
NS_ASSUME_NONNULL_BEGIN

@interface MYToolUtils : NSObject
+(GPUImageRawDataInput*) imageToGLBytes:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
