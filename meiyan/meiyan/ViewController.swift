//
//  ViewController.swift
//  meiyan
//
//  Created by 康子文 on 2019/10/24.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.blue
        self.title = "第二页"
        let btn = UIButton.init(type: .system);
        btn.frame = CGRect.init(x: 20, y: 20, width: 100, height: 100)
        btn.setTitle("按钮", for: .normal)
//        btn.addTarget(self, action: #selector(btnDoen(btn:)), for: .touchUpInside)
        self.view.addSubview(btn)
    }
    


}

