//
//  ESMarquee.swift
//  ESMarquee_swift
//
//  Created by codeLocker on 2020/5/13.
//  Copyright © 2020 codeLocker. All rights reserved.
//

import UIKit

public enum ESMarqueeDirection {
    case left
    case right
    case up
    case down
}

public class ESMarquee: UIView {
    
    /// 跑马灯上放置两个UILabel进行左右滚动替换
    private static let labelCount: Int = 2

    /// 跑马灯文案之间的间隔距离
    fileprivate var marqueeSpacing: CGFloat = 20
    /// 跑马的滚动速度
    fileprivate var scrollSpeed: CGFloat = 100
    /// 开始跑马效果延迟
    fileprivate var scrollDelay: Double = 1
    /// 是否是暂停状态
    fileprivate var isPaused: Bool = false
    /// 是否是滚动状态
    fileprivate var isScrolling: Bool = false
    
    public private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = false
        return scrollView
    }()
    
    fileprivate lazy var clickGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(click_method))
        return gesture
    }()
    
    /// 显示文本的UILabel
    fileprivate lazy var labels: [UILabel] = {
        var labels = [UILabel]()
        for index in 0 ..< ESMarquee.labelCount {
            labels.append(UILabel())
        }
        return labels
    }()
    
    //主显示的UILabel
    fileprivate lazy var mainLabel: UILabel = {
        return self.labels.first ?? UILabel()
    }()
    
    /// 滚动方向
    public var scrollDirection: ESMarqueeDirection = .left
    
    /// 内容
    public var text: String? {
        get {
            return self.mainLabel.text
        }
        set {
            if newValue == self.text {
                return
            }
            var newText = ""
            if self.scrollDirection == .up || self.scrollDirection == .down {
                let _ = newValue?.enumerated().map({ (element) in
                    newText.append(element.element)
                    newText.append("\n")
                })
                newText = String(newText.dropLast())
                let _ = self.labels.map { (label) in
                    label.text = newText
                }
            } else {
                let _ = self.labels.map { (label) in
                    label.text = newValue
                }
            }
            //UILabel的布局发生变化
            self.refreshLabels()
        }
    }
    
    /// 字体
    public var font: UIFont? {
        get {
            return self.mainLabel.font
        }
        set {
            if newValue == self.font {
                return
            }
            let _ = self.labels.map { (label) in
                label.font = newValue
            }
            //UILabel的布局发生变化
            self.refreshLabels()
        }
    }
    
    /// 字体颜色
    public var textColor: UIColor? {
        get {
            return self.mainLabel.textColor
        }
        set {
            if newValue == self.textColor {
                return
            }
            let _ = self.labels.map { (label) in
                label.textColor = newValue
            }
        }
        
    }
    
    public override var bounds: CGRect {
        get {
            return super.bounds
        }
        set {
            if newValue == self.bounds {
                return
            }
            //自动布局后确定尺寸后会执行
            super.bounds = newValue
            self.updateBounds()
        }
    }
    
    public var click: (() -> ())? {
        didSet {
            guard let _ = self.click else {
                self.removeGestureRecognizer(self.clickGesture)
                return
            }
            self.addGestureRecognizer(self.clickGesture)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        loadUI()
    }
    
    public init(frame: CGRect, marqueeSpacing: CGFloat = 20, scrollSpeed: CGFloat = 100, scrollDelay: Double = 1, scrollDirection: ESMarqueeDirection = .left) {
        super.init(frame: frame)
        self.marqueeSpacing = marqueeSpacing
        self.scrollSpeed = scrollSpeed
        self.scrollDirection = scrollDirection
        self.scrollDelay = scrollDelay
        loadUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadUI() {
        self.addSubview(self.scrollView)
        //添加UILabel
        let _ = self.labels.enumerated().map { (index, label) in
            label.autoresizingMask = autoresizingMask
            switch self.scrollDirection {
            case .left, .right:
                label.numberOfLines = 1
            case .up, .down:
                label.numberOfLines = 0
            }
            label.textAlignment = .center
            self.scrollView.addSubview(label)
        }
    }
    
    private func updateBounds() {
        self.refreshLabels()
    }
    
    /// 更新UILables的Frame
    private func refreshLabels() {
        if self.bounds == CGRect.zero {
            //self的Bounds还未初始化完成
            return
        }
        
        var offset_x: CGFloat = 0
        var offset_y: CGFloat = 0
        
        // 是否启动跑马灯效果
        var enableMarquee: Bool = false
        
        let _ = self.labels.map { (label) in
            switch self.scrollDirection {
            case .left, .right:
                label.sizeToFit()
                var frame = label.frame
                frame.origin = CGPoint.init(x: offset_x, y: 0)
                frame.size.height = self.bounds.height
                label.frame = frame
                offset_x += label.bounds.width + self.marqueeSpacing
                label.isHidden = false
                enableMarquee = self.mainLabel.bounds.width > self.bounds.width
            case .up, .down:
                label.sizeToFit()
                var frame = label.frame
                frame.origin = CGPoint.init(x: 0, y: offset_y)
                frame.size.width = self.bounds.width
                label.frame = frame
                offset_y += label.bounds.height + self.marqueeSpacing
                label.isHidden = false
                enableMarquee = self.mainLabel.bounds.height > self.bounds.height
            }
        }
        
        self.scrollView.layer.removeAllAnimations()
        
        if enableMarquee {
            //文本的宽度大于容器的宽度 启动跑马灯效果
            //设置UIScrollView的contentSize
            
            switch self.scrollDirection {
            case .left, .right:
                self.scrollView.contentSize = CGSize.init(width: self.mainLabel.bounds.width * 2 + self.marqueeSpacing, height: self.bounds.height)
                if self.scrollDirection == .left {
                    self.scrollView.contentOffset = CGPoint.zero
                } else {
                    self.scrollView.contentOffset = CGPoint.init(x: self.scrollView.contentSize.width - self.bounds.width, y: 0)
                }
                
            case .up, .down:
                self.scrollView.contentSize = CGSize.init(width: self.bounds.width, height: self.mainLabel.bounds.height * 2 + self.marqueeSpacing)
                if self.scrollDirection == .up {
                    self.scrollView.contentOffset = CGPoint.zero
                } else {
                    self.scrollView.contentOffset = CGPoint.init(x: 0, y: self.scrollView.contentSize.height - self.bounds.height)
                }
                break
            }
            
            //开始跑马灯效果
            self.startMarquee()
            
        } else {
            //文本的宽度大于容器的宽度 不启动跑马灯效果
            let _ = self.labels.map { (label) in
                label.isHidden = label != self.mainLabel
            }
            self.scrollView.contentSize = self.bounds.size
            self.scrollView.contentOffset = CGPoint.zero
            self.scrollView.layer.removeAllAnimations()
        }
    }
    
    /// 开始跑马灯效果
    @objc private func startMarquee() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            if self.text == nil || (self.text?.isEmpty ?? true) {
                return
            }
            self.scrollView.layer.removeAllAnimations()
            
            //滚动目标位置
            var targetOffset = CGPoint.zero
            //滚动的时间
            var duration: CGFloat = 5
            //滚动方向
            switch self.scrollDirection {
            case .left:
                duration = self.mainLabel.bounds.width / self.scrollSpeed
                self.scrollView.contentOffset = CGPoint.zero
                targetOffset = CGPoint.init(x: self.mainLabel.bounds.width + self.marqueeSpacing, y: 0)
            case .right:
                duration = self.mainLabel.bounds.width / self.scrollSpeed
                self.scrollView.contentOffset = CGPoint.init(x: self.scrollView.contentSize.width - self.bounds.width, y: 0)
                targetOffset = CGPoint.init(x: self.scrollView.contentSize.width - (self.mainLabel.bounds.width + self.marqueeSpacing + self.bounds.width), y: 0)
            case .up:
                duration = self.mainLabel.bounds.height / self.scrollSpeed
                self.scrollView.contentOffset = CGPoint.zero
                targetOffset = CGPoint.init(x: 0, y: self.mainLabel.bounds.height + self.marqueeSpacing)
            case .down:
                duration = self.mainLabel.bounds.height / self.scrollSpeed
                self.scrollView.contentOffset = CGPoint.init(x: 0, y: self.scrollView.contentSize.height - self.bounds.height)
                targetOffset = CGPoint.init(x: 0, y: self.mainLabel.bounds.height - self.bounds.height)
            }
            

            UIView.animate(withDuration: TimeInterval(duration),
                           delay: self.scrollDelay,
                           options: [.curveLinear, .allowUserInteraction],
                           animations: {
                            self.scrollView.contentOffset = targetOffset
                            
            }) { (complete) in
                if complete {
                    self.performSelector(inBackground: #selector(self.startMarquee), with: nil)
                }
            }
        }
    }
}

extension ESMarquee {
    
    /// 点击事件
    @objc func click_method() {
        self.click?()
    }
    
    /// 暂停动画
    public func pause() {
        if self.isPaused {
            return
        }
        let pausedTime: CFTimeInterval = self.layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
        self.isPaused = true
        self.isScrolling = false
    }
    
    /// 恢复动画
    public func resume() {
        if self.isScrolling {
            return
        }
        let pausedTime: CFTimeInterval = self.layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause: CFTimeInterval = self.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        self.layer.beginTime = timeSincePause
        self.isScrolling = true
        self.isPaused = false
    }
}
