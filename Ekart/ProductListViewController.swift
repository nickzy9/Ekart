//
//  ProductListViewController.swift
//  Ekart
//
//  Created by Aniket on 9/22/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import UIKit

final class ProductListViewController: UIViewController {

    @IBOutlet weak var rankingView: UIView!
    @IBOutlet weak var rankingButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // Product detail UI elements
    @IBOutlet weak var productDetailBackgroundView: UIView!
    @IBOutlet weak var productDetailView: UIView!
    @IBOutlet weak var productDetailCloseButton: UIButton!
    @IBOutlet weak var productDetailTitleLabel: UILabel!
    
    @IBOutlet weak var productDetailSizeView: UIView!
    @IBOutlet weak var productDetailSizeLabel: UILabel!
    @IBOutlet weak var productDetailSizeSelectionView: UIView!
    
    @IBOutlet weak var productDetailColorView: UIView!
    @IBOutlet weak var productDetailColorLabel: UILabel!
    @IBOutlet weak var productDetailColorSelectionView: UIView!
    
    @IBOutlet weak var productDetailPriceView: UIView!
    @IBOutlet weak var productDetailPriceLabel: UILabel!
    @IBOutlet weak var productDetailPriceTaxLabel: UILabel!
    @IBOutlet weak var productDetailBuyButton: UIButton!
    
    private var products: [CategoryProduct] = []
    private var name: String = ""
    private var currentRankingType = RankType.none
    var rankings: [(String, Int)] = []
    
    convenience init(_ products: [CategoryProduct], _ name: String) {
        self.init()
        self.products = products
        self.name = name.trimmingCharacters(in: .whitespaces)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        
        navigationItem.title = name
        //        navigationController?.navigationBar.prefersLargeTitles = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideView))
        productDetailBackgroundView.addGestureRecognizer(tapGesture)
        
        productDetailView.layer.cornerRadius = 12
        productDetailView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        productDetailPriceView.applyCard()
        
        productDetailView.isHidden = true
        productDetailBackgroundView.isHidden = true
    }
    
    @IBAction func rankingButton_TouchUpInside(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for ranking in rankings {
            alert.addAction(UIAlertAction(title:  ranking.0, style: .default , handler:{ (UIAlertAction)in
                print(ranking.1)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.view.addSubview(UIView())
        
        self.present(alert, animated: false, completion: nil)
    }
    
    private func reloadProductWithRankings(type: Int) {
        guard let rankType = RankType(rawValue: type) else {
            return
        }
    }
}

extension ProductListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showProductDetailsView(product: products[indexPath.row])
    }
}

extension ProductListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductCell
        cell.product = products[safe: indexPath.row]
        return cell
    }
}

extension ProductListViewController: CustomSlectionViewDelegate {
    
    func showProductDetailsView(product: CategoryProduct) {
        productDetailTitleLabel.text = product.name
        if product.variants.isEmpty {
            productDetailSizeView.isHidden = true
            productDetailColorView.isHidden = true
            return
        }
        productDetailSizeSelectionView.subviews.forEach({ $0.removeFromSuperview() })
        
        var isToShowSize = false
        
        for variant in product.variants {
            if let _ = variant.size {
                isToShowSize = true
            }
        }
        
        if isToShowSize {
            productDetailSizeView.isHidden = false
            let sizeSelectionView = CustomSlectionView(delegate: self, forSize: true, data: product.variants)
            productDetailSizeSelectionView.addSubview(sizeSelectionView)
            sizeSelectionView.snp.makeConstraints{ (make) in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        } else {
            productDetailSizeView.isHidden = true
            showColorVariants(variants: product.variants)
        }
        
        productDetailBackgroundView.isHidden = false
        productDetailView.showHideWithAnimation(show: true)
    }
    
    func didSelect(isForSize: Bool, id: Int?, fromVariants: [Variant]) {
        guard let id = id else {
            hideView() // No id, Hide the view
            return
        }
        
        if isForSize {
            if let sizeVariants = fromVariants.first(where: {($0.id == id)}) {
                let variants = fromVariants.filter({$0.size == sizeVariants.size && $0.size != nil})
                showColorVariants(variants: variants)
            }
        } else {
            if let variant = fromVariants.first(where: {($0.id == id)}) {
                productDetailPriceLabel.text = "\(variant.price)"
            }
        }
    }
    
    func showColorVariants(variants: [Variant]) {
        productDetailColorView.isHidden = false
        productDetailColorSelectionView.subviews.forEach({ $0.removeFromSuperview() })
        
        let colorSelectionView = CustomSlectionView(delegate: self, forSize: false, data: variants)
        productDetailColorSelectionView.addSubview(colorSelectionView)
        colorSelectionView.snp.makeConstraints{ (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    @IBAction func productDetailCloseButton_TouchUpInside(_ sender: Any) {
        hideView()
    }
    
    @objc func hideView() {
        productDetailBackgroundView.isHidden = true
        productDetailView.showHideWithAnimation(show: false)
    }
}
