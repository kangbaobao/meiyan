//
//  UIImage+Tint.swift
//  meiyan
//
//  Created by 康子文 on 2019/10/24.
//  Copyright © 2019 康子文. All rights reserved.
//

import Foundation
extension UIImage{
//    把颜色转化为图片
    static func createImageWithColor(color : UIColor) -> UIImage {
        let rect = CGRect.init(x: 0.0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return theImage!
    }
    
}
