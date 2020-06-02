//
//  MYMpegToMp4VideoController.swift
//  meiyan
//
//  Created by kzw on 2020/5/26.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYMpegToMp4VideoController: UIViewController,MYRightShuoMingProtocol  {
    var message: String?
    var srcPath :String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let textView = UITextView.init()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        self.view.addSubview(textView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "说明", style: .done, target: self, action: #selector(rightAction))
        textView.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(88)
            make.bottom.equalTo(34)
        }

        let dst = PTFileHandler.pathCaches + "/mpegFirstaaq.mp4"
       //先删除文件，再创建
       PTFileHandler.deleteFileOrDirectory(path: dst)
       let str = VideoUtils.ffmpeg(toMP4: srcPath!, with: dst)
        textView.text = str
        
        
    }
    @objc func rightAction(){
        gotoShuoMing()
    }


}
