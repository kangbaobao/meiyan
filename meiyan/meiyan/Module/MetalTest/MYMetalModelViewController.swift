//
//  MYMetalModelViewController.swift
//  meiyan
//
//  Created by kzw on 2020/6/22.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYMetalModelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
         let mView = MYMetalModelView.init(frame: self.view.bounds, device:  MTLCreateSystemDefaultDevice())
        //mView.frame = self.view.bounds
         self.view.addSubview(mView)
    }
    




}
