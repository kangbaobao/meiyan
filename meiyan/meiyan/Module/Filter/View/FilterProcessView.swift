//
//  FilterProcessView.swift
//  meiyan
//
//  Created by 康子文 on 2019/10/31.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit

class FilterProcessView: UIView ,UIScrollViewDelegate{

    var originalImage:UIImage!;
    var scrollView: UIScrollView = UIScrollView.init(frame: CGRect.zero);
//    底部view
    var bottomBackView : UIView  = UIView.init();
//    展示图片的imgview
    var imageView: UIImageView = UIImageView.init()
    //底部的高度
    let bottomFirstHeight : CGFloat = 80.0;
    let bootomTwoHeight : CGFloat = 100;
    lazy var firstBottomView: FilterProcessFirstBottomView = {
        
        return FilterProcessFirstBottomView.init()
    }()
//    记录操作的切换状态
    var bState: Int?
    var bottomState : Int { set{
         bState = newValue
        if bState == 0 {
            //初始状态 高 bottomFirstHeight view FilterProcessFirstBottomView
            bottomBackView.addSubview(firstBottomView)
            firstBottomView.snp.makeConstraints { (make) in
                make.size.equalTo(bottomBackView.snp.size).offset(0)
                make.top.equalTo(bottomBackView.snp.top).offset(0)
                make.left.equalTo(bottomBackView.snp.left).offset(0)
            }
            
        }else{
            
        }
        
        }
        get{
           
            return  bState!
        }
    }
    init(image: UIImage) {
        super.init(frame: CGRect.zero)
        self.originalImage = image
//        self.backgroundColor = UIColor.red
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI(){
        scrollView.delegate = self ;
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11,*)  {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.backgroundColor = UIColor.init(red: 0x33/255.0, green:  0x33/255.0, blue:  0x33/255.0, alpha: 1.0)
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0);
            make.top.equalTo(self.snp.top).offset(MYSeetings.NavigationHeight)
            make.bottom.equalTo(self.snp.bottom).offset(-bottomFirstHeight)
        }
        scrollView.contentSize = originalImage.size;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = 0.5;
        // Add gesture,double tap zoom imageView.
        let doubleTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleDoubleTap(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)
        
        imageView.image = originalImage
        imageView.contentMode = .scaleAspectFit;
        let height =  ( MYSeetings.S_HEIGHT - MYSeetings.SafeBottomHeight - MYSeetings.SafeTopHeight
            - MYSeetings.NavigationHeight - bottomFirstHeight)
        imageView.frame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: MYSeetings.S_WIDTH, height:height))
        scrollView.addSubview(imageView)
        
        self.addSubview(bottomBackView)
        bottomBackView.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView.snp.bottom).offset(0)
            make.bottom.equalTo(self.snp.bottom).offset(0)
            make.left.equalTo(self.snp.left).offset(0)
            make.right.equalTo(self.snp.right).offset(0)
        }
        bottomState = 0
        
    }
    @objc func handleDoubleTap(gesture: UIGestureRecognizer){
        let newScale = scrollView.zoomScale * 1.5;//zoomScale这个值决定了contents当前扩展的比例
        let zoomRect = zoomRectForScale(scale: newScale, center:gesture.location(in: gesture.view))
        scrollView.zoom(to: zoomRect, animated: true)
    }
    func zoomRectForScale(scale: CGFloat,center : CGPoint) -> CGRect{

        var zoomRect = CGRect.zero
        zoomRect.size.height = scrollView.frame.size.height / scale
        zoomRect.size.width  = scrollView.frame.size.width  / scale;
        zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
        return zoomRect
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //当scrollView自身的宽度或者高度大于其contentSize的时候, 增量为:自身宽度或者高度减去contentSize宽度或者高度除以2,或者为0
        let delta_x = scrollView.bounds.size.width > scrollView.contentSize.width ? (scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
        let delta_y = scrollView.bounds.size.height > scrollView.contentSize.height ? (scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
        imageView.center = CGPoint.init(x: scrollView.contentSize.width/2 + delta_x, y: scrollView.contentSize.height/2 + delta_y)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(scale, animated: false)
    }
}
