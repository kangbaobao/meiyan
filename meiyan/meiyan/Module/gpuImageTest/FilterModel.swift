//
//  FilterModel.swift
//  meiyan
//
//  Created by kzw on 2020/5/18.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
typealias InitCallback = () -> (AnyObject)
typealias ValueChangedCallback = (AnyObject, CGFloat) -> ()
typealias CustomCallback = (GPUImagePicture, AnyObject, GPUImageView) -> ()

let flowerImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "Flower", ofType: "jpg")!)!
let MaYuImage = R.image.test1()//UIImage.init(named: "test2")//UIImage(contentsOfFile: Bundle.main.path(forResource: "test1", ofType: "")!)!

enum FilterType {
    case imageGenerators
    case basicOperation
    case operationGroup
    case custom
    case blend
}

class FilterModel: NSObject {
    var name: String?
    var filterType: FilterType!
    var range: (Float, Float, Float)?
    var initCallback: InitCallback!
    var valueChangedCallback: ValueChangedCallback?
    var customCallback: CustomCallback?
    var message :String = ""
    init(name: String?, filterType: FilterType, range: (Float, Float, Float)? = (0.0, 1.0, 0.0), initCallback: @escaping InitCallback, valueChangedCallback: ValueChangedCallback? = nil, _ message :String? = nil , _ customCallback: CustomCallback? = nil) {

        self.name = name
        self.filterType = filterType
        self.range = range
        self.initCallback = initCallback
        self.valueChangedCallback = valueChangedCallback
        self.customCallback = customCallback
        if let m = message{
             self.message = m
        }
    }
}

