//
//  JXPhotoBrowserNavView.swift
//  JXPhotoBrowser
//
//  Created by 侣途 on 2024/9/11.
//

import Foundation

class JXPhotoBrowserNavView: UIView, JXPhotoBrowserPageIndicator {
    /// 弱引用PhotoBrowser
    open weak var photoBrowser: JXPhotoBrowser?
    
    open lazy var closeImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
   
    open lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.textColor = UIColor.white
        return view
    }()
    
    open lazy var pageStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .fill
        view.isLayoutMarginsRelativeArrangement = true
        view.insetsLayoutMarginsFromSafeArea = false
        view.spacing = 0
        return view
    }()

    open lazy var pageLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.textColor = UIColor.white
        view.textAlignment = .center
        return view
    }()
    
    private var total: Int = 0

    var currentIndex: Int = 0
    
    var titleString: String = "" {
        didSet {
            titleLabel.text = titleString
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(closeImageView)
        self.addSubview(titleLabel)
        self.addSubview(pageStackView)
        pageStackView.addArrangedSubview(pageLabel)
        closeImageView.frame = CGRect(x: 0, y: 4, width: 44, height: 44)
        titleLabel.frame = CGRect(x: CGRectGetMaxX(closeImageView.frame), y: 0, width: 162, height: 44)
        pageStackView.frame = CGRect(x: UIScreen.main.bounds.width - 36 - 16, y: 8, width: 36, height: 28)

        pageStackView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        pageStackView.layer.cornerRadius = 10
        pageStackView.layer.masksToBounds = true
        
        // 单击手势
        let closeTap = UITapGestureRecognizer(target: self, action: #selector(closeTap(_:)))
        closeImageView.isUserInteractionEnabled = true
        closeImageView.addGestureRecognizer(closeTap)
    }
    
    /// 单击
    @objc open func closeTap(_ tap: UITapGestureRecognizer) {
        photoBrowser?.dismiss()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with browser: JXPhotoBrowser) {
        
    }
    
    func reloadData(numberOfItems: Int, pageIndex: Int) {
        total = numberOfItems
        pageLabel.text = "\(pageIndex + 1)/\(numberOfItems)"
    }
    
    func didChanged(pageIndex: Int) {
        pageLabel.text = "\(pageIndex + 1)/\(total)"
    }
    
}
