//
//  ProductListViewController.swift
//  Ekart
//
//  Created by Aniket on 9/22/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import UIKit
import Toast_Swift

final class ProductListViewController: UIViewController {

    @IBOutlet weak var rankingView: UIView!
    @IBOutlet weak var rankingTypeLabel: UILabel!
    @IBOutlet weak var rankingButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
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
    private var pageTitle: String = ""
    private var showRanking = false
    
    convenience init(_ products: [CategoryProduct], _ pageTitle: String, showRanking: Bool) {
        self.init()
        self.products = products
        self.showRanking = showRanking
        self.pageTitle = pageTitle.trimmingCharacters(in: .whitespaces)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        drawUI()
    }
    
    private func drawUI() {
        navigationItem.title = pageTitle
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideProductDetailView))
        productDetailBackgroundView.addGestureRecognizer(tapGesture)
        
        productDetailView.layer.cornerRadius      = 12
        productDetailView.layer.maskedCorners     = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        productDetailBuyButton.layer.cornerRadius = 2
        productDetailPriceView.applyCard()
        
        productDetailView.isHidden = true
        productDetailBackgroundView.isHidden = true
        productDetailPriceTaxLabel.textColor = .headyRed
        
        if showRanking {
            rankingView.isHidden = false
            loadProductWithRankings(type: 0)
        } else {
            rankingView.backgroundColor = .headyGreen
            rankingView.isHidden = true
        }
    }
    
    @IBAction func rankingButton_TouchUpInside(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for (index, ranking) in MasterDataManager.instance.rankingData.enumerated() {
            alert.addAction(UIAlertAction(title:  ranking.ranking, style: .default , handler:{ (UIAlertAction)in
                self.loadProductWithRankings(type: index)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.view.addSubview(UIView())
        
        self.present(alert, animated: false, completion: nil)
    }
    
    @IBAction func sortButton_TouchUpInside(_ sender: Any) {
        if sortButton.currentImage == #imageLiteral(resourceName: "iconSortDsc") {
            sortButton.setImage(#imageLiteral(resourceName: "iconSortAsc"), for: .normal)
        } else {
            sortButton.setImage(#imageLiteral(resourceName: "iconSortDsc"), for: .normal)
        }
        products = products.reversed()
        tableView.reloadData()
    }
    
    private func loadProductWithRankings(type: Int) {
        rankingTypeLabel.text = MasterDataManager.instance.rankingData[safe: type]?.ranking
        sortButton.setImage(#imageLiteral(resourceName: "iconSortDsc"), for: .normal)
        products = MasterDataManager.instance.getProductsWithRankingCount(by: type)
        tableView.reloadData()
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
        cell.isToShowRanking = showRanking
        cell.product = products[safe: indexPath.row]
        return cell
    }
}

// MARK: - Load product detail view
extension ProductListViewController: CustomSlectionViewDelegate {
    /// CustomSlection delegate
    func didSelect(isForSize: Bool, id: Int?, fromVariants: [Variant]) {
        guard let id = id else {
            hideProductDetailView() // No selection, hide view
            return
        }
        
        if isForSize { // Show colors based on size
            productDetailPriceLabel.text = "--"
            if let sizeVariants = fromVariants.first(where: {($0.id == id)}) {
                let variants = fromVariants.filter({$0.size == sizeVariants.size && $0.size != nil})
                showColorVariants(variants: variants)
            }
        } else {
            if let variant = fromVariants.first(where: {($0.id == id)}) {
                productDetailPriceLabel.text = "\(variant.price)"
            }
        }
        updateButtonState()
    }
    
    /// Load product detail
    private func showProductDetailsView(product: CategoryProduct) {
        productDetailTitleLabel.text = product.name
        productDetailPriceLabel.text = "--"
        productDetailPriceTaxLabel.text = "+\(product.tax.value)% tax"
        productDetailPriceTaxLabel.isHidden = true
        updateButtonState()
        
        if product.variants.isEmpty { // Empty Variants. Hide the size and color view
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
            productDetailColorView.isHidden = true
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
    
    /// Enable/Disable of Buy button
    private func updateButtonState() {
        if productDetailPriceLabel.text != "--" {
            productDetailPriceTaxLabel.isHidden = false
            productDetailBuyButton.isUserInteractionEnabled = true
            productDetailBuyButton.layer.opacity = 1
        } else {
            productDetailBuyButton.isUserInteractionEnabled = false
            productDetailBuyButton.layer.opacity = 0.6
            productDetailPriceTaxLabel.isHidden = true
        }
    }
    
    /// Show color selection view
    private func showColorVariants(variants: [Variant]) {
        if productDetailColorView.isHidden {
            productDetailColorView.showHideWithAnimation(show: true)
        }
        productDetailColorSelectionView.subviews.forEach({ $0.removeFromSuperview() })

        let colorSelectionView = CustomSlectionView(delegate: self, forSize: false, data: variants)
        productDetailColorSelectionView.addSubview(colorSelectionView)
        colorSelectionView.snp.makeConstraints{ (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    @IBAction func productDetailCloseButton_TouchUpInside(_ sender: Any) {
        hideProductDetailView()
    }
    
    @IBAction func productDetailBuyButton_TouchUpInside(_ sender: Any) {
        hideProductDetailView()
        var style = ToastStyle()
        style.backgroundColor = .headyGreen
        style.messageColor = .headyText
        view.makeToast("Item added in cart!", duration: 1.2, position: .center, style: style)
    }
    
    @objc private func hideProductDetailView() {
        productDetailBackgroundView.isHidden = true
        productDetailView.showHideWithAnimation(show: false)
    }
}
