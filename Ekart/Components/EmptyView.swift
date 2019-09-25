//
//  EmptyView.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

protocol EmptyViewDelegate: class {
    func emptyViewButtonTapped()
}

enum EmptyViewStatus {
    case loading
    case disconnected
    case empty
}

/// Class EmptyView to show
class EmptyView: UIView {
    private var currentView: UIStackView?
    
    //MARK: - Init with Delegate
    weak var delegate: EmptyViewDelegate?
    convenience init(delegate: EmptyViewDelegate?) {
        self.init()
        self.delegate = delegate
    }
    
    // Redraw content when status changed
    var status: EmptyViewStatus = .loading {
        didSet {
            if status != oldValue {
                redrawContents()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        drawUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Draw UI
    private func drawUI() {
        backgroundColor = UIColor(white: 0.97, alpha: 1.0)
        redrawContents()
    }
    
    func redrawContents() {
        currentView?.removeFromSuperview()
        currentView = nil
        switch status {
        case .loading:
            showLoadingView()
        case .empty:
            showMessage(message: "No products available", buttonTitle: "Refresh")
        case .disconnected:
            showMessage(message: "Please check your internet connection", buttonTitle: "Retry")
        }
    }
    
    /// Message description label
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel(font: .systemFont(ofSize: 17), textColor: .headyText)
        label.textAlignment = .center
        return label
    }()
    
    /// Button
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.gray, for: .normal)
        button.layer.borderColor = UIColor.headyGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }()
    
    /// Show Message
    ///
    /// - Parameters:
    ///   - message: Pass message text
    ///   - buttonTitle: Pass button title text
    func showMessage(message: String, buttonTitle: String) {
        descriptionLabel.text = message
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        currentView = UIStackView(arrangedSubviews: [descriptionLabel, button])
        if let currentView = currentView {
            currentView.spacing = 16
            currentView.distribution = .equalSpacing
            currentView.alignment = .center
            currentView.axis = .vertical
            
            button.snp.makeConstraints { (make) in
                make.width.equalTo(150)
                make.height.equalTo(40)
            }
            currentView.autoresizesSubviews = false
            addSubview(currentView)
            currentView.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(0.8)
            }
        }
    }
    
    /// Button tap to call delegate
    @objc func buttonTapped() {
        delegate?.emptyViewButtonTapped()
    }
    
    private func showLoadingView() {
        let label = UILabel(font: .systemFont(ofSize: 15), textColor: .headyGray)
        label.text = "Loading..."
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        
        currentView = UIStackView(arrangedSubviews: [label, activityIndicator])
        if let currentView = currentView {
            currentView.axis = .horizontal
            currentView.distribution = .equalSpacing
            currentView.spacing = 4
            currentView.alignment = .center
            addSubview(currentView)
            currentView.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            layoutIfNeeded()
        }
    }
}
