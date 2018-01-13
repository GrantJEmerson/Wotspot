//
//  BookmarkCollectionViewCell.swift
//  Web Connect
//
//  Created by Grant Emerson on 12/9/17.
//  Copyright © 2017 Grant Emerson. All rights reserved.
//

import UIKit

public protocol BookMarkCellDelegate: class {
    func deleteCell(_ cell: UICollectionViewCell)
}

class BookmarkCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    public weak var delegate: BookMarkCellDelegate?
    
    public var editing = false {
        didSet {
            deleteView.isHidden = !editing
            editing ? startAnimating() : stopAnimating()
        }
    }
    
    public var bookmark: Bookmark? {
        didSet {
            guard let bookmark = bookmark else { return }
            screenshotImageView.image = bookmark.screenshot as? UIImage
            titleLabel.text = bookmark.title
        }
    }
    
    private lazy var informationView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var screenshotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: AdaptiveLabel = {
        let label = AdaptiveLabel()
        label.font = UIFont(name: "Futura", size: 13)
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var deleteView: DeletionView = {
        let deleteView = DeletionView()
        deleteView.delegate = self
        deleteView.isHidden = true
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        return deleteView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        //clipsToBounds = true
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.6
        layer.shadowColor = UserDefaults.standard.bool(forKey: "prefersDark") ? UIColor.white.cgColor : UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - 40)).cgPath
        layer.masksToBounds = false
        
        NotificationCenter.default.addObserver(forName: .startEditing, object: nil, queue: .main) { (_) in
            self.editing = true
        }
        
        NotificationCenter.default.addObserver(forName: .endEditing, object: nil, queue: .main) { (_) in
            self.editing = false
        }
        
        NotificationCenter.default.addObserver(forName: .lightenLabels, object: nil, queue: .main) { (_) in
            UIView.animate(withDuration: 0.8) {
                self.layer.shadowColor = UIColor.white.cgColor
            }
        }
        
        NotificationCenter.default.addObserver(forName: .darkenLabels, object: nil, queue: .main) { (_) in
            UIView.animate(withDuration: 0.8) {
                self.layer.shadowColor = UIColor.black.cgColor
            }
        }
        
        setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private Functions
    
    private func setUpSubviews() {
        addSubview(informationView)
        informationView.add(screenshotImageView, titleLabel)
        addSubview(deleteView)
        
        informationView.constrainToParent()
        deleteView.constrainToParent()
        
        NSLayoutConstraint.activate([
            screenshotImageView.topAnchor.constraint(equalTo: informationView.topAnchor),
            screenshotImageView.leadingAnchor.constraint(equalTo: informationView.leadingAnchor),
            screenshotImageView.trailingAnchor.constraint(equalTo: informationView.trailingAnchor),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.topAnchor.constraint(equalTo: screenshotImageView.bottomAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: informationView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: informationView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: informationView.trailingAnchor)
        ])
    }
    
    private func startAnimating() {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.toValue = bounds.width / 2
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        informationView.layer.add(animation, forKey: "pulsing")
    }
    
    private func stopAnimating() {
        informationView.layer.removeAllAnimations()
    }
}

extension BookmarkCollectionViewCell: DeleteViewDelegate {
    func deleteButtonTapped() {
        delegate?.deleteCell(self)
    }
}
