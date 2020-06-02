//
//  MYCustomFilletFilter.h
//  meiyan
//
//  Created by kzw on 2020/5/28.
//  Copyright © 2020 康子文. All rights reserved.
//

#import <GPUImage/GPUImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface MYCustomFilletFilter : GPUImageFilter
@property(nonatomic,assign)CGFloat fillet; // 0.0 ~ 1.0
@end

NS_ASSUME_NONNULL_END
