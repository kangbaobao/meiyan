//
//  CustomDrawTouchPointView.swift
//  meiyan
//
//  Created by 康子文 on 2019/11/4.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit
struct  DWStroke  {
    fileprivate var path :CGMutablePath
    fileprivate var blendMode :CGBlendMode;
    fileprivate var strokeWidth :CGFloat;
    fileprivate var lineColor :UIColor;
    func strokeWithContext(context : CGContext) -> Void{
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(strokeWidth)
        context.setBlendMode(blendMode)
        context.beginPath()
        context.addPath(path)
        context.strokePath()
    }
}
class CustomDrawTouchPointView: UIView {
    //混合模式，用来控制擦除，清屏，和画线 的h混合模式
    private var isEarse :Bool = false;
    private var stroks :[DWStroke] = Array();
    private var lineColor : UIColor = UIColor.clear;
    private var lineWidth :CGFloat = 1;
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
