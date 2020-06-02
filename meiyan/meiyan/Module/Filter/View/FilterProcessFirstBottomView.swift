//
//  FilterProcessFirstBottomView.swift
//  meiyan
//
//  Created by 康子文 on 2019/11/1.
//  Copyright © 2019 康子文. All rights reserved.
//

import UIKit

class FilterProcessFirstBottomView: UIView ,UICollectionViewDelegate,UICollectionViewDataSource{

    
    private var collectionView : UICollectionView?
    private let nameList :[String] = ["智能优化","编辑","增强","滤镜","边框","马赛克","美容"];
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView.init(frame: CGRect(x:0, y:0, width:MYSeetings.S_WIDTH, height:80), collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView!)
           // 注册cell
        collectionView?.register(UINib(resource: R.nib.filterProcessFirstBottomcollCell), forCellWithReuseIdentifier: "FilterProcessFirstBottomcollCell")//UINib.init(nibName: "FilterProcessFirstBottomcollCell", bundle: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : FilterProcessFirstBottomcollCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterProcessFirstBottomcollCell", for: indexPath) as! FilterProcessFirstBottomcollCell
        cell.lab.text = nameList[indexPath.item]
        return cell
    }
   
}
