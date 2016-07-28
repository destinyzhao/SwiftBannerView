//
//  ViewController.swift
//  SwiftBannerView
//
//  Created by Alex on 16/7/27.
//  Copyright © 2016年 Alex. All rights reserved.
//

import UIKit

class ViewController: UIViewController,BannerViewDelegate {
    
    var imageUrlArray = ["http://wenwen.soso.com/p/20130903/20130903223945-1073052939.jpg",
                  "http://pic39.nipic.com/20140226/18071023_162553457000_2.jpg",
                  "http://www.sucaitianxia.com/Photo/pic/201003/bambo15.jpg",
                  "http://pic9.nipic.com/20100917/3650425_083743800076_2.jpg"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 180)
        let bannerView = BannerView(frame:frame,imageUrlArray: imageUrlArray)
        //轮播间隔时间
        bannerView.autoScrollTimeInterval = 2.5
        // 设置小圆点颜色
        bannerView.setPageControlIndicatorTintColor(UIColor.blackColor(), currentPageIndicatorTintColor: UIColor.blueColor())
        //设置代理，监听点击图片的事件
        bannerView.delegate = self
        self.view.addSubview(bannerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didSelectedIndex(currentIndex: Int) {
        print("selectindex:\(currentIndex)")
    }


}

