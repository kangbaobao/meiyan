//
//  MainViewController.swift
//  meiyan
//
//  Created by 康子文 on 2019/10/24.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit
import SnapKit
import Photos
//import BSImagePicker
//import BSImageView
//import BSGridCollectionViewLayout
//
//typealias CallBackVoid = ((String)->(Void));
class MainViewController: MYBaseViewController {
//    private var callback : CallBackVoid?//((String)->(Void))?;
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "美颜";
        self.tabBarItem = UITabBarItem.init(title: "Home", image: R.image.home_noselect()?.withRenderingMode(.alwaysOriginal), selectedImage:R.image.home_select()?.withRenderingMode(.alwaysOriginal))
        print("yuyan en: ",R.string.englishLocalize.选择图片(preferredLanguages: ["en"]))
        print("yuyan zh-Hans: ",R.string.englishLocalize.选择图片(preferredLanguages: ["zh-Hans"]))

//        callback = { (str :String) -> Void in
//
//        };
//        if callback != nil{
//            callback!("haha");
//        }
//        R.image.testJpg()
        /*
        let image =  UIImage.init(named: "test.jpg")
        let image1 = OpencvInterface.testGray(image!)
        let img = UIImageView.init(frame: CGRect.init(x: 20, y: 64+44+10, width: 300, height: 300))
        img.image = image1
        img.backgroundColor = UIColor.red
        self.view.addSubview(img)
    */
        let btn = UIButton.init(type: .system);
        btn.frame = CGRect.init(x: 20, y: 0, width: 100, height: 100)
        
        btn.setTitle(NSLocalizedString("选择图片", tableName: "EnglishLocalize", bundle: Bundle.main, value: "", comment: ""), for: .normal)//("选择图片", comment: "EnglishLocalize"), for: .normal)
        btn.backgroundColor = UIColor.red
        btn.addTarget(self, action: #selector(btnDoen(btn:)), for: .touchUpInside)
        self.view.addSubview(btn)
        btn.tag = 100;
        btn.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX);
            make.centerY.equalTo(self.view.snp.centerY).offset(-50);
            make.height.equalTo(50)
            make.width.equalTo(80)
        }
        
        let camerBtn = UIButton.init(type: .system);
        camerBtn.frame = CGRect.init(x: 20, y: MYSeetings.NavigationHeight + MYSeetings.SafeTopHeight+20, width: 100, height: 100)
        camerBtn.setTitle("开启摄像头", for: .normal)
        camerBtn.backgroundColor = UIColor.blue

        camerBtn.addTarget(self, action: #selector(btnDoen(btn:)), for: .touchUpInside)
        self.view.addSubview(camerBtn)
        camerBtn.tag = 101;
        camerBtn.snp.makeConstraints { (make) in
            make.top.equalTo(btn.snp.bottom).offset(20);
            make.left.equalTo(btn.snp.left)
            make.right.equalTo(btn.snp.right)
            make.height.equalTo(btn.snp.height)
        }
    }
    
    @objc func btnDoen(btn: UIButton){
        if  btn.tag == 100 {
           pictureHander()
        }else{
         self.navigationController?.pushViewController(ViewController.init(), animated: true)

        }
    }
    
    //图片处理
    func pictureHander() -> Void {
//        let vc = BSImagePickerViewController()
//        vc.maxNumberOfSelections = 1;
//        bs_presentImagePickerController(vc, animated: true,
//                                        select: { (asset: PHAsset) -> Void in
//                                            // User selected an asset.
//                                            // Do something with it, start upload perhaps?
//        }, deselect: { (asset: PHAsset) -> Void in
//            // User deselected an assets.
//            // Do something, cancel upload?
//        }, cancel: { (assets: [PHAsset]) -> Void in
//            // User cancelled. And this where the assets currently selected.
//        }, finish: { (assets: [PHAsset]) -> Void in
//            // User finished with these assets
//            print("assets : ",assets);
//            let phot:PHAsset = assets[0]
//            if(phot.mediaType == .image){
//                //开始处理图片
//                PHImageManager.default().requestImage(for: phot, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: nil, resultHandler: { (image:UIImage?, info: [AnyHashable : Any]?) in
////                    let urlstr :NSURL = info?["PHImageFileURLKey"] as! NSURL;
////                    print("urlstr: ",urlstr)
//                    let vc = FilterProcessViewController.init(image: image!)
//                    self.navigationController?.pushViewController(vc, animated: true)
//                    
//                    } )
//            }
//            
//        }, completion: nil)
    }
   
}
