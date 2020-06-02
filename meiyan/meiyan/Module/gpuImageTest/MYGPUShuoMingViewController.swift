//
//  MYGPUShuoMingViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/20.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYGPUShuoMingViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var text :String?{
        set{
            _text = newValue ?? ""
        }
        get{
            return _text
        }
    }
    var _text :String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = text

    }
    
    



}
