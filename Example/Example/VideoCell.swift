//
//  VideoCell.swift
//  Example
//
//  Created by JiongXing on 2019/12/13.
//  Copyright © 2019 JiongXing. All rights reserved.
//

//
//  VideoCell.swift
//  Example
//
//  Created by JiongXing on 2019/12/13.
//  Copyright © 2019 JiongXing. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import JXPhotoBrowser
import AVKit

class VideoCell: UIView, JXPhotoBrowserCell, UIGestureRecognizerDelegate {
    open lazy var topPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            if let window = window {
                return window.safeAreaInsets.top
            }
        }
        return 20
    }()
    
    open lazy var bottomPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
            if let window = window {
                return window.safeAreaInsets.bottom
            }
        }
        return 0
    }()
    weak var photoBrowser: JXPhotoBrowser?
    
    lazy var player = AVPlayer()
    var playerVc = AVPlayerViewController()
    lazy var bgView = UIView()

    private weak var existedPan: UIPanGestureRecognizer?

    static func generate(with browser: JXPhotoBrowser) -> Self {
        let instance = Self.init(frame: .zero)
        instance.photoBrowser = browser
        return instance
    }
    
    required override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(click))
        addGestureRecognizer(tap)
        addSubview(bgView)
        bgView.backgroundColor = UIColor.clear
        playerVc.player = player
        bgView.addSubview(playerVc.view)
        /// 拖动手势
        addPanGesture()
        
        self.bgView.frame = CGRect(x: 0, y: self.topPadding + 44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height -  self.topPadding - 44 -  bottomPadding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 添加拖动手势
    open func addPanGesture() {
        guard existedPan == nil else {
            return
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        // 必须加在图片容器上，否则长图下拉不能触发
        self.addGestureRecognizer(pan)
        existedPan = pan
        
        self.photoBrowser?.addChild(playerVc)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("layoutSubviews")
        playerVc.view.frame = bgView.bounds
    }
    
    @objc private func click() {
        photoBrowser?.dismiss()
    }
    
    /// 记录pan手势开始时imageView的位置
    private var beganFrame = CGRect.zero
    
    /// 记录pan手势开始时，手势位置
    private var beganTouch = CGPoint.zero
    
    /// 响应拖动
    @objc open func onPan(_ pan: UIPanGestureRecognizer) {
     
        switch pan.state {
        case .began:
            beganFrame = self.bounds
            beganTouch = pan.location(in: self)
            print("beganFrame===\(beganFrame)")
            print("beganTouch===\(beganTouch)")

        case .changed:
            let result = panResult(pan)
            bgView.frame = result.frame
            print("changgeeee====\(bgView.frame)")
            photoBrowser?.maskView.alpha = result.scale * result.scale
            photoBrowser?.pageIndicator?.isHidden = result.scale < 0.99
        case .ended, .cancelled:
            bgView.frame = panResult(pan).frame
            let isDown = pan.velocity(in: self).y > 0
            if isDown {
                photoBrowser?.dismiss()
            } else {
                photoBrowser?.maskView.alpha = 1.0
                photoBrowser?.pageIndicator?.isHidden = false
                resetImageViewPosition()
            }
        default:
            resetImageViewPosition()
        }
    }
    
    /// 计算拖动时图片应调整的frame和scale值
    private func panResult(_ pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
        // 拖动偏移量
        let translation = pan.translation(in: self)
        let currentTouch = pan.location(in: self)
        
        // 由下拉的偏移值决定缩放比例，越往下偏移，缩得越小。scale值区间[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / bounds.height))
        
        let width = beganFrame.size.width * scale
        let height = beganFrame.size.height * scale
        
        // 计算x和y。保持手指在图片上的相对位置不变。
        // 即如果手势开始时，手指在图片X轴三分之一处，那么在移动图片时，保持手指始终位于图片X轴的三分之一处
        let xRate = (beganTouch.x - beganFrame.origin.x) / beganFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (beganTouch.y - beganFrame.origin.y) / beganFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
    
    /// 复位ImageView
    private func resetImageViewPosition() {
        // 如果图片当前显示的size小于原size，则重置为原size
//        let size = computeImageLayoutSize(for: imageView.image, in: bgView)
//        let needResetSize = imageView.bounds.size.width < size.width || imageView.bounds.size.height < size.height
        UIView.animate(withDuration: 0.25) {
//            self.imageView.center = self.computeImageLayoutCenter(in: self.scrollView)
//            if needResetSize {
//                self.imageView.bounds.size = size
//            }
            self.bgView.frame = CGRect(x: 0, y: self.topPadding + 44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height -  self.topPadding - 44 -  self.bottomPadding)
        }
    }
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 只处理pan手势
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = pan.velocity(in: self)
        // 向上滑动时，不响应手势
        if velocity.y < 0 {
            return false
        }
        // 横向滑动时，不响应pan手势
        if abs(Int(velocity.x)) > Int(velocity.y) {
            return false
        }
        // 响应允许范围内的下滑手势
        return true
    }
}
