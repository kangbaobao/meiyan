//
//  MYMetalMainViewController.swift
//  meiyan
//
//  Created by kzw on 2020/5/19.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit

class MYMetalMainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
     var dataArray = [

            (title:"Metal使用",data:[
                (title:"创建三角形",key:"metalTri"),
                (title:"添加了模型矩阵三角形",key:"MetalModel"),
                (title:"渲染纹理",key:"MetalTexture"),
                (title:"渲染纹理视频（FFmpeg解码）",key:"MetalTextureVideo"),

               //MYMetalTextureVideoController
            ]),
            
        ]
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.tabBarItem = UITabBarItem.init(title: "Metal", image: R.image.me_noselect()?.withRenderingMode(.alwaysOriginal), selectedImage:R.image.me_select()?.withRenderingMode(.alwaysOriginal))
            self.tabBarItem.setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor :RGB_ColorHex(rgb: 0x999999),
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11)
            ], for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    



}
extension MYMetalMainViewController :UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          let cData = dataArray[section].data
          return cData.count
      }
      func numberOfSections(in tableView: UITableView) -> Int {
          return dataArray.count

      }
      func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
          let lab = UILabel.init()
          let title = dataArray[section].title
          lab.text = title
          return lab
      }
      
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "MYGPUMainTableViewCell") as! MYGPUMainTableViewCell
          let (title,_) = dataArray[indexPath.section].data[indexPath.row]
          cell.lab.text = title
          return  cell
      }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let (_,key) = dataArray[indexPath.section].data[indexPath.row]
           let storyboard = self.storyboard
        switch key {
         case "metalTri":
               let vc = MYMetalTriViewController.init()
               self.navigationController?.pushViewController(vc, animated: true)
               //
               print("")
        case "MetalModel":
            let vc = MYMetalModelViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        case "MetalTexture":
            let vc = MYMetalTextureController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        case "MetalTextureVideo":
            let vc = MYMetalTextureVideoController.init()
            self.navigationController?.pushViewController(vc, animated: true)

            //
        default:
            print("")
        }
    }
}
