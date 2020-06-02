//
//  BaseNavigationController.swift
//  meiyan
//
//  Created by 康子文 on 2019/10/24.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController ,UINavigationControllerDelegate,UIGestureRecognizerDelegate{

    var backImage : UIImage? = R.image.arrowleft() //UIImage.init(named: "arrowleft");
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationViewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self;
    }
    
//     初始化
    func navigationViewDidLoad() -> Void {
        self.showImageColorNavigationBarBackground(color: MYSeetings.NavigationBackColor, tintColor: MYSeetings.NavigationTitleColor, translucent: true)
    }
    /**
     *  去除底部线条
     */
    func removeShadowImage(){
        self.navigationBar.shadowImage = UIImage.init()
    }
    
    /**
     *  添加线条
     */
    func addNormalShadowImage(){
        let  color = UIColor.init(red: 0xdd/255.0, green: 0xdd/255.0, blue: 0xdd/255.0, alpha: 1.0)
        self.navigationBar.shadowImage = UIImage.createImageWithColor(color: color)
    }
    /**
     *  设置NavigationBar的背景图片
     *
     *  @param bgImage 图片
     */
    func setNavigationBarBackgroundImage(bgImage : UIImage){
        self.navigationBar.setBackgroundImage(bgImage, for: .default)
    }
    
    func showImageColorNavigationBarBackground(color: UIColor,tintColor:UIColor,translucent:Bool){
        self.navigationBar.isTranslucent = translucent
        self.navigationBar.tintColor = tintColor
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:tintColor]
        self.setNavigationBarBackgroundImage(bgImage: UIImage.createImageWithColor(color: color))
        self.removeShadowImage()
    }
    
//    func showNormalNavigationBarTintColor(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
    @objc func popself()  {
        self.popViewController(animated: true)
    
    }
    func createBackButton() -> UIBarButtonItem{
        let backBtn = UIBarButtonItem.init(image: backImage, style: .plain, target: self, action: #selector(popself))
        return backBtn
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print("self.viewControllers.count : ",self.viewControllers.count)
        if self.viewControllers.count <= 1 {
            return false;
        }
        return true
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        if viewController.navigationItem.leftBarButtonItem == nil && self.viewControllers.count>1{
            viewController.navigationItem.leftBarButtonItem = self.createBackButton()
        }
    }
    
    
    


}
