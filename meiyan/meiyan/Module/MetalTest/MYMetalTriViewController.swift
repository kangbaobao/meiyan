//
//  MYMetalTriViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/15.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import MetalKit
class MYMetalTriViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let mView = MYMetalTriView.init(frame: self.view.bounds, device:  MTLCreateSystemDefaultDevice())
       //mView.frame = self.view.bounds
        self.view.addSubview(mView)
        // Do any additional setup after loading the view.
    }
    



}
