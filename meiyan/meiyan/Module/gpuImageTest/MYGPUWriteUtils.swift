//
//  MYGPUWriteUtils.swift
//  meiyan
//
//  Created by 康子文 on 2020/5/24.
//  Copyright © 2020 康子文. All rights reserved.
//

import UIKit
import Photos
class MYGPUWriteUtils: NSObject {
   static func writeVideo(movieUrl :URL,context:UIViewController?){
        let block :((String)->()) = {
           title in
            let alertVC = UIAlertController.init(title: nil, message: title, preferredStyle: .alert)
            let OkAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
              
            }
            alertVC.addAction(OkAction)
            context?.present(alertVC, animated: true, completion: {
            })
        }
        writeVideoToAssetsLibrary(videoURL: movieUrl) { (sucess, error) in
            DispatchQueue.main.async {
                if sucess{
                    block("保存成功")
                }else{
                    block("保存失败")

                }
            }
        }
    }
    
   private static func writeVideoToAssetsLibrary(videoURL :URL,block:((Bool,Error?)->())?){
           PHPhotoLibrary.shared().performChanges({
               //请求创建一个Asset
               let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
               //视频存储的相册
               let collectonRequest = self.photoCollectionWithAlbumName(albumName: "GPUImage相册")
               //为Asset创建一个占位符，放到相册编辑请求中
               let placeHolder = assetRequest?.placeholderForCreatedAsset
               //相册中添加视频
               collectonRequest?.addAssets([placeHolder!] as NSArray)
             
           }) { (success, error) in
               print("error %@",error )
               block?(success,error)
           }
       }
    private static  func photoCollectionWithAlbumName(albumName :String)-> PHAssetCollectionChangeRequest?{
           // 创建搜索集合
           let result = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
           var Ruquest :PHAssetCollectionChangeRequest?
           //遍历相册，获取对应相册的changeRequest
           result.enumerateObjects { (assetCollection, index, _) in
               if assetCollection.localizedTitle?.contains(albumName) ?? false{
                   let collectionRuquest = PHAssetCollectionChangeRequest.init(for: assetCollection)
                   Ruquest = collectionRuquest
               }
           }
           if Ruquest == nil {
               Ruquest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
           }
           return Ruquest
       }
}
/**
/**
albumName：相册名称，没有则创建该相册
*/
+ (PHAssetCollectionChangeRequest *)photoCollectionWithAlbumName:(NSString *)albumName {
    // 创建搜索集合
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    //遍历相册，获取对应相册的changeRequest
    for (PHAssetCollection *assetCollection in result) {
        if ([assetCollection.localizedTitle containsString:albumName]) {
            PHAssetCollectionChangeRequest *collectionRuquest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            return collectionRuquest;
        }
    }
    //不存在，创建albumName为名的相册changeRequest
    PHAssetCollectionChangeRequest *collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
    return collectionRequest;
}
+ (void)lxj_writeVideoToAssetsLibrary:(NSURL *)videoURL completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler{
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //请求创建一个Asset
        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        //视频存储的相册
        PHAssetCollectionChangeRequest *collectonRequest = [PHPhotoLibrary photoCollectionWithAlbumName:@"相册名"];
        //为Asset创建一个占位符，放到相册编辑请求中
        PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
        //相册中添加视频
        [collectonRequest addAssets:@[placeHolder]];
        
    } completionHandler:^(BOOL success, NSError *error) {
        if (completionHandler) {
            completionHandler(success,error);
        }
    }];
    
}

*/
