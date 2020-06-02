//
//  MYGPUTwoImageViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/15.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYGPUTwoImageViewController: UIViewController {
    @IBOutlet weak var srcImage: UIImageView!
    @IBOutlet weak var dstImage: UIImageView!
    var arr:Array<UIImage>?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
           srcImage.contentMode = .scaleAspectFit
         if let src = arr?.first{
            srcImage.image = src
        }
         if let dst = arr?.last{
            dstImage.image = dst

        }

    }
    
  



}
