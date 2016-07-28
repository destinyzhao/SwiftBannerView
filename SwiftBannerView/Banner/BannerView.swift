//
//  BannerView.swift
//  SwiftBannerView
//
//  Created by Alex on 16/7/27.
//  Copyright © 2016年 Alex. All rights reserved.
//

import UIKit
import Kingfisher

public protocol BannerViewDelegate: NSObjectProtocol {
    func didSelectedIndex(currentIndex: Int)
}

class BannerView: UIView,UIScrollViewDelegate{
    
    var width:CGFloat = 0
    var height:CGFloat = 0
    
    var currentIndex:Int = 0
    var nextIndex:Int = 0
    
    var timer:NSTimer?
    
    var imageModelArray = [BannerModel]()
    
    var isAutoBanner:Bool = true {
        didSet {
            if isAutoBanner {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }
    
    ///处理图片点击事件的代理
    var delegate: BannerViewDelegate?
    
    ///自动轮播的时间间隔，默认是2s。如果设置这个参数，之前不是自动轮播，现在就变成了自动轮播
    var autoScrollTimeInterval: NSTimeInterval = 2 {
        didSet { isAutoBanner = true }
    }
    
    //subviews
    private lazy var scrollView: UIScrollView = self.setupScollView()
    private lazy var currentImageView: UIImageView = self.setupImageView()
    private lazy var nextImageView: UIImageView = self.setupImageView()
    private lazy var pageControl: UIPageControl = self.setupPageControl()
    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                 action: #selector(tapImageView))
    //MARK: - init cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        width = frame.size.width
        height = frame.size.height
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    // 用于显示网络图片
    init(frame: CGRect, imageUrlArray: [String]) {
        super.init(frame: frame)
        
        var modelArray = [BannerModel]()
        var model: BannerModel
        for imageUrlStr in imageUrlArray {
            model = BannerModel(imageUrl: imageUrlStr)
            modelArray.append(model)
        }
        imageModelArray = modelArray
        
        commonInit()
    }
    
    private func commonInit() {
        width = frame.size.width
        height = frame.size.height
        
        setupViews()
        addNotification()
        updateBannerView()
    }

    // MARK: - setup views
    private func setupViews() {
        addSubview(scrollView)
        scrollView.addSubview(currentImageView)
        scrollView.addSubview(nextImageView)
        addSubview(pageControl)
        
        scrollView.addGestureRecognizer(tapGesture)
    }

    // MARK: - 初始化ScrollView
    private func setupScollView() -> UIScrollView {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIScrollView(frame: rect)
        view.contentOffset = CGPoint(x: width, y: 0)
        view.pagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = UIColor.whiteColor()
        view.delegate = self
        view.backgroundColor = UIColor.blackColor()
        
        return view
    }
    
    // MARK: - 初始化ImageView
    private func setupImageView() -> UIImageView {
        let imageView: UIImageView = UIImageView(frame: CGRect(x: width, y: 0, width: width, height: height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
    
    // MARK: - 初始化PageControl
    private func setupPageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.currentPage = currentIndex
        pageControl.hidesForSinglePage = true
        
        return pageControl
    }
    
    // MARK: - 图片点击
    func tapImageView() {
        if let delegate = self.delegate {
            delegate.didSelectedIndex(currentIndex)
        }
    }
    
    // MARK: -  更新PageControl
    private func updatePageControl() -> Void {
        pageControl.numberOfPages = imageModelArray.count
        pageControl.currentPage = currentIndex
        
        let size = pageControl.sizeForNumberOfPages(pageControl.numberOfPages)
        let point = CGPoint(x: width/2 - size.width/2, y: height - size.height)
        
        pageControl.frame = CGRect(origin: point, size: size)
    }
    
    // MARK: - 根据图片链接设置图片
    private func setImageWithImageUrl() {
        
        for model in imageModelArray {
            if self.currentIndex == self.imageModelArray.indexOf(model) {
                self.currentImageView.kf_setImageWithURL(NSURL(string: model.imageUrl!)!)
            }
        }
    }
    
    // MARK: - 设置 ScrollView ContentSize
    func updateScrollViewContentSize() -> Void {
        scrollView.contentSize = CGSize(width: width * CGFloat(imageModelArray.count), height: 0)
    }
    
    // MARK: - 更新Banner View
    private func updateBannerView() -> Void {
        setImageWithImageUrl()
        updatePageControl()
        updateScrollViewContentSize()
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset: CGFloat = scrollView.contentOffset.x
        if offset < width {  //right
            nextImageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            nextIndex = (currentIndex - 1) < 0 ? imageModelArray.count - 1 : (currentIndex - 1)
            
            if offset <= 0 {
                nextPage()
            }
        } else if offset > width { //left
            nextImageView.frame = CGRect(x: 2*width, y: 0, width: width, height: height)
            nextIndex = (currentIndex + 1) > imageModelArray.count - 1 ? 0 : (currentIndex + 1)
            
            if offset >= 2 * width {
                nextPage()
            }
        }
        
        let model = imageModelArray[nextIndex]
       
        nextImageView.kf_setImageWithURL(NSURL(string: model.imageUrl!)!)
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
    
    // MARK: - nextPage
    private func nextPage() {
        currentImageView.image = nextImageView.image
        scrollView.contentOffset = CGPoint(x: width, y: 0)
        currentIndex = nextIndex
        pageControl.currentPage = currentIndex
    }
    
    //MARK: - start timer
    func startTimer() {
        if isAutoBanner && imageModelArray.count > 1 {
            if timer != nil {
                stopTimer()
            }
        
            timer = NSTimer.scheduledTimerWithTimeInterval(autoScrollTimeInterval,
                                                           target:self,
                                                           selector:#selector(autoCycle),
                                                           userInfo:nil,
                                                           repeats:true)
            NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        }
    }
    
    // MARK: - stop timer
    func stopTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    // MARK: - 自动滚动
    @objc private func autoCycle() {
        scrollView.setContentOffset(CGPoint(x: 2*width, y: 0), animated: true)
    }

    
    // MARK: - add notification
    private func addNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(stopTimer), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startTimer), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    // MARK: - remove notification
    private func removeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    // MARK: -修改PageControl的小圆点颜色值
    func setPageControlIndicatorTintColor(pageIndicatorTintColor: UIColor,
                               currentPageIndicatorTintColor: UIColor) {
        pageControl.pageIndicatorTintColor = pageIndicatorTintColor
        pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
