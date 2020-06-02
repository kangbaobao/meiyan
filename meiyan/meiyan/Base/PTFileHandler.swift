//
//  PTFileHandler.swift
//  Portal
//
//  Created by kzw on 2019/12/25.
//  Copyright © 2019 e-lead. All rights reserved.
//

import UIKit

class PTFileHandler: NSObject {
    // Caches 目录
    static var pathCaches :String{
        NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
//        get {
//            return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
//        }
    }
    static var pathDocument :String{
        get {
            return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        }
    }
    static var pathTmp :String{
        get {
            return NSTemporaryDirectory()
        }
    }
    //返回展示缓存数量
    static var showChacheSize :String?{
        get{
            print("pathCaches : \(pathCaches)")
           let size =  fileSizeMB([pathCaches,pathTmp])
            return "\(size)MB"
        }
    }
    static func clear(){
        clearChacheFile([pathCaches,pathTmp])
    }
    static func fileSizeKB(_ pathList:Array<String>) -> Int{
        var folderSize = 0
        for path in pathList{
            let files = FileManager.default.subpaths(atPath: path) ?? []
            for file in files {
                // 路径拼接
                let p = path +  ("/\(file)")
                // 计算缓存大小
                folderSize  += fileSizeAtPath(path:p)
            }
        }
        return folderSize
    }
    
    static func fileSizeMB(_ pathList:Array<String>) -> Int{
        var folderSize = 0
        for path in pathList{
            let files = FileManager.default.subpaths(atPath: path) ?? []
            for file in files {
                // 路径拼接
                let p = path +  ("/\(file)")
                // 计算缓存大小
                folderSize  += fileSizeAtPath(path:p)
            }
        }
        return folderSize / (1024*1024)
    }
    
    
    //计算单个文件的大小
    static func fileSizeAtPath(path:String) -> Int{
        if FileManager.default.fileExists(atPath: path) {
            let attr = try! FileManager.default.attributesOfItem(atPath: path)
            return Int(attr[FileAttributeKey.size] as! UInt64)
        }
        return 0
        
    }
    //清除缓存
    static func clearChacheFile(_ pathList:Array<String>){
        for path in pathList{
            let files = FileManager.default.subpaths(atPath: path) ?? []
            for file in files {
                // 路径拼接
                let p = path +  ("/\(file)")
                if FileManager.default.fileExists(atPath: p){
                    do{
                        try FileManager.default.removeItem(atPath: p)
                    }catch{
                        print(error.localizedDescription)
                    }
                }

            }
        }
    }
    //创建文件
    static func createDirectory(path: String,name:String) -> String{
        let filePath =  path + "/" + name
        if FileManager.default.fileExists(atPath:filePath){
            return filePath
        }
        do{
            try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
        }catch{
            
        }
        return filePath
    }
    
    // 删除文件
    @discardableResult
    static func deleteFileOrDirectory(path:String) -> Bool{
        var del = false
        if FileManager.default.fileExists(atPath: path){
            do{
                try FileManager.default.removeItem(atPath: path)
                del = true
            }catch{
                del = false

            }
        }
        return del
    }
    // 同一路径下 可重命名，原文件不删除 不同路径下移动且可重命名 ，若要移动的文件夹下有同名文件，则操作失败
   @discardableResult
    static func moveReNameSourcePath(src:String,to:String) -> Bool{
    var del = false
    do {
        try  FileManager.default.moveItem(atPath: src, toPath: to)
         del = true
    } catch {
        del = false
    }
    return del
    }
    @discardableResult
    static func copyNameSourcePath(src:URL,to:URL) -> Bool{
        var del = false
        do {
            try  FileManager.default.copyItem(at: src, to: to)
             del = true
        } catch {
            del = false
        }
        return del
    }
}
/*
 #pragma mark  1 路径不能是同一路径，2，也可以改名  如 hehe文件夹 c:/kzw/hehe -> c:/aaa/haha 前题c盘必须有kzw和aaa文件 同一路径同名或不同名都失败 操作时要注意
 +(BOOL)copyWenJia:(NSString *)sourcepath Topath:(NSString *)toPth
 {
     NSError *error=nil;
     BOOL mycopy= [[NSFileManager defaultManager] copyItemAtPath:sourcepath toPath:toPth error:&error];
     if(mycopy==YES)
     {
         NSLog(@"copy成功");
     }else
     {
      NSLog(@"copy失败");
     }
     return mycopy;
 }
 **/
