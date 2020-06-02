//
//  FilterProcessViewController.swift
//  meiyan
//
//  Created by 康子文 on 2019/10/31.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit

class FilterProcessViewController: MYBaseViewController {

    private var scrollView: UIScrollView =  UIScrollView.init();
    var originalImage:UIImage!
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.originalImage = image
        self.automaticallyAdjustsScrollViewInsets = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "滤镜"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "保存", style: .done, target: self, action: #selector(rightAction))
        let view = FilterProcessView.init(image: originalImage)//init(frame: CGRect.zero)
        self.view.addSubview(view)
        view.snp.makeConstraints { (make ) in
            make.top.equalTo(self.view.snp.top).offset(MYSeetings.SafeTopHeight)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(self.view.snp.bottom).offset(-(MYSeetings.SafeBottomHeight));
            
        }
    }
    // 创建子视图
    func createView()  {
        
    }
    
//    保存事件
    @objc func rightAction(){
        
    }



}
