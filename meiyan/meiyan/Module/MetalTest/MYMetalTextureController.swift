//
//  MYMetalTextureController.swift
//  meiyan
//
//  Created by kzw on 2020/6/23.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYMetalTextureController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
         let mView = MYMetalTextureView.init(frame: self.view.bounds, device:  MTLCreateSystemDefaultDevice())
        //mView.frame = self.view.bounds
         self.view.addSubview(mView)
    }
    


}
