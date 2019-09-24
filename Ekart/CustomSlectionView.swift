//
//  CustomSlectionView.swift
//  Ekart
//
//  Created by Aniket on 24/09/2019.
//  Copyright © 2019 Heady. All rights reserved.
//

import UIKit
import SnapKit

protocol CustomSlectionViewDelegate: class {
    func didSelect(isForSize: Bool, id: Int?, fromVariants: [Variant])
}

final class CustomSlectionView: UIView {
    fileprivate lazy var collectionView: UICollectionView = self.makeCollectionView()
    fileprivate var variants: [Variant] = []
    fileprivate var isForSize = Bool()
    
    //MARK: - Init with Delegate
    weak var delegate: CustomSlectionViewDelegate?
    convenience init(delegate: CustomSlectionViewDelegate? = nil,
                     forSize: Bool, data: [Variant]) {
        self.init()
        self.delegate = delegate
        self.variants = data
        self.isForSize = forSize
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
        self.backgroundColor = .headyLightGray
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints{ (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}

//MARK: -  Make View Components
extension CustomSlectionView {
    fileprivate func makeCollectionView() -> UICollectionView {
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: self.frame, collectionViewLayout: flowLayout)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        collectionView.register(UINib(nibName: "CustomSelectionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomSelectionCollectionViewCell")
        return collectionView
    }
}

extension CustomSlectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(isForSize: isForSize, id: variants[safe: indexPath.row]?.id, fromVariants: variants)
    }
}

extension CustomSlectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return variants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomSelectionCollectionViewCell", for: indexPath) as! CustomSelectionCollectionViewCell
        if isForSize, let value = variants[safe: indexPath.row]?.size {
            cell.titleLabel.text = "\(value)"
        }
        if !isForSize, let value = variants[safe: indexPath.row]?.color {
            cell.titleLabel.text = "\(value)"
        }
        cell.setView()
        return cell
    }
}

extension CustomSlectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isForSize {
            return  CGSize(width: 60, height: 34)
        }
        return  CGSize(width: 90, height: 34)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

