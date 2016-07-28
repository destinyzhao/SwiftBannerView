//
//  BannerModel.swift
//  SwiftBannerView
//
//  Created by Alex on 16/7/27.
//  Copyright © 2016年 Alex. All rights reserved.
//

import UIKit

class BannerModel: NSObject {
    
    var localImage:UIImage?
    var title:String?
    var imageUrl:String?
    
    init(localImage: String?) {
        self.localImage = UIImage(named: localImage!)
    }
    
    init(imageUrl: String?) {
        self.imageUrl = imageUrl
    }
}
