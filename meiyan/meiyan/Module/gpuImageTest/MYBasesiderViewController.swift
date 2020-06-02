//
//  MYBasesiderViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/18.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import SnapKit
class MYBasesiderViewController: UIViewController {

    
    @IBOutlet weak var backView: UIView!
    var imgView: GPUImageView = GPUImageView.init(frame: CGRect.zero)
//    var imgView: GPUImageView = {
//       let renderView = GPUImageView.init(frame: CGRect.zero)
//          renderView.fillMode =  kGPUImageFillModePreserveAspectRatio //kGPUImageFillModePreserveAspectRatioAndFill//
//          renderView.backgroundColor = .white
//        return renderView
//    }()
    @IBOutlet weak var slider: UISlider!
    var filterModel: FilterModel!
    var pictureInput :GPUImagePicture = GPUImagePicture.init(image: MaYuImage)
    var filter: AnyObject!
    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
      //  pictureInput = GPUImagePicture.init(image: MaYuImage)

        imgView.fillMode =  kGPUImageFillModePreserveAspectRatio //kGPUImageFillModePreserveAspectRatioAndFill//
        imgView.backgroundColor = .black
        self.backView.addSubview(imgView)
        imgView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        title = filterModel.name
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "说明", style: .done, target: self, action: #selector(rightAction))
        /*
         //不延迟高斯处理首次会l黑屏

         **/
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + .milliseconds(20)) {
            [weak self] in
            self?.setupFilterChain()

        }

    }
    
//    override  func awakeFromNib() {
//        super.awakeFromNib()
//
//    }
    override func viewWillDisappear(_ animated: Bool) {
        pictureInput.removeAllTargets()
        super.viewWillDisappear(animated)
    }
    func setupFilterChain() {
        slider.minimumValue = filterModel.range?.0 ?? 0
       slider.maximumValue = filterModel.range?.1 ?? 0
       slider.value = filterModel.range?.2 ?? 0
       filter = filterModel.initCallback()
        
        if filterModel.filterType! == .basicOperation {
            // GPUImageFilter GPUImageOutput <GPUImageInput>
            if let actualFilter = filter as? GPUImageOutput&GPUImageInput{
                pictureInput.addTarget(actualFilter)
                actualFilter.addTarget(imgView)
                pictureInput.processImage()
            }
        }else if filterModel.filterType! == .custom{
            filterModel.customCallback?(pictureInput,filter,imgView)
        }else if filterModel.filterType! == .operationGroup{
            if let actualFilter = filter as? GPUImageFilterGroup{
                pictureInput.addTarget(actualFilter)
                actualFilter.addTarget(imgView)
                pictureInput.processImage()
            }
        }
        
        /*
         switch filterModel.filterType! {
             
         case .imageGenerators:
             filter as! ImageSource --> renderView
             
         case .basicOperation:
             if let actualFilter = filter as? BasicOperation {
                 pictureInput --> actualFilter --> renderView
                 pictureInput.processImage()
             }
             
         case .operationGroup:
             if let actualFilter = filter as? OperationGroup {
                 pictureInput --> actualFilter --> renderView
             }
             
         case .blend:
             if let actualFilter = filter as? BasicOperation {
                 let blendImgae = PictureInput(image: flowerImage)
                 blendImgae --> actualFilter
                 pictureInput --> actualFilter --> renderView
                 blendImgae.processImage()
                 pictureInput.processImage()
             }
             
         case .custom:
             filterModel.customCallback!(pictureInput, filter, renderView)
         }
         **/
        self.sliderAction( slider)
    }
    

    @IBAction func sliderAction(_ sender: UISlider) {
        print("slider value: \(slider.value)")
        if let actualCallback = filterModel.valueChangedCallback {
            actualCallback(filter,CGFloat(slider.value))
        } else {
            slider.isHidden = true
        }
        
        if filterModel.filterType! != .imageGenerators {
            self.pictureInput.processImage()


        }
    }
    
    @objc func rightAction(){
        
        if filterModel.message.isEmpty{
            return
        }
        if filterModel.message.count > 70 {
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc = mainStoryboard.instantiateViewController(withIdentifier: "MYGPUShuoMingViewController") as! MYGPUShuoMingViewController
            vc.text = filterModel.message
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let alertVC = UIAlertController.init(title: nil, message: filterModel.message, preferredStyle: .alert)
            let OkAction = UIAlertAction.init(title:  "OK", style: .default) { (action) in
            }
            alertVC.addAction(OkAction)
            self.present(alertVC, animated: true, completion: {
            })
        }

    }
    

}
