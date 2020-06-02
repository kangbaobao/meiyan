//
//  MYSeetings.swift
//  meiyan
//
//  Created by 康子文 on 2019/10/24.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit

class MYSeetings: NSObject {
    //ec881b
    static let  NavigationBackColor : UIColor = UIColor.init(red: 0xec/255.0, green: 0x88/255.0, blue: 0x1b/255.0, alpha: 1.0)//UIColor.white
    static let NavigationTitleColor : UIColor = UIColor.black
    static let MainColor = MYSeetings.NavigationBackColor
//    黑色字体
    static let BlockColor = UIColor.init(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0);
//    屏幕的宽
    static let S_WIDTH :CGFloat = UIScreen.main.bounds.size.width
//    屏幕的高
    static let S_HEIGHT :CGFloat = UIScreen.main.bounds.size.height
//    nav 高
    static let NavigationHeight:CGFloat = 44.0;
//    顶部的安全距离 20 or 44
    static let SafeTopHeight :CGFloat = UIApplication.shared.statusBarFrame.size.height;
    static let isIphoneXseriers : Bool = MYSeetings.SafeTopHeight == 44.0 ? true: false
//    底部安全高度
    static let SafeBottomHeight : CGFloat = MYSeetings.isIphoneXseriers ? 34.0 : 0.0
    

    
}
