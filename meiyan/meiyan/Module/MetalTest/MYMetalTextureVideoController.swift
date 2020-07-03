//
//  MYMetalTextureVideoController.swift
//  meiyan
//
//  Created by kzw on 2020/6/23.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYMetalTextureVideoController: UIViewController {
    var stop = false
    var isHW = false
    var srcPath :String?
    override func viewDidLoad() {
        super.viewDidLoad()
         let mView = MYMetalTextureVideoView.init(frame: self.view.bounds, device:  MTLCreateSystemDefaultDevice())
        //必须设置
        mView.contentMode = .scaleAspectFit
         self.view.addSubview(mView)
        DispatchQueue.global().async {
            [weak self] in
            if self?.isHW ?? false {
                VideoUtils.videoswsHWRGBAScaleplay((self?.srcPath!)!, metal: mView, block: { (texture0, texture1) in
                    
                }) { (pro) -> Bool in
                    return  self?.stop ?? true
                }
            }else{
                VideoUtils.creamswsRGBAScaleplay({ (rgba, size) in
                    mView.setupTexture(imageBytes: rgba, size: size)
                }) { (pro) -> Bool in
                  return  self?.stop ?? true
                }
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
