//
//  MainViewController.swift
//  Ekart
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import UIKit
import SnapKit
import Toast_Swift

final class CategoriesViewController: UIViewController {
    // View Components
    lazy var tableView: UITableView = self.makeTableView()
    fileprivate lazy var emptyView: EmptyView = EmptyView(delegate: self)
    private let refreshControl = UIRefreshControl()
    
    //MARK: -  ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        drawUI()
        tableView.reloadData()
        emptyView.redrawContents()
        
        // Listen to data change
        NotificationCenter.default.addObserver(self, selector: #selector(categoriesStartRefresh), name: .categoriesStartRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(categoriesDidUpdate), name: .categoriesDidUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(categoriesDidFailToRefresh), name: .categoriesDidFailToRefresh, object: nil)
        
        // Fetch data
        MasterDataManager.instance.fetch()
    }
    
    //MARK: - Draw UI
    private func drawUI() {
        navigationItem.title = "Categories"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ranking", style: .done, target: self, action: #selector(showProductPage))
        view.backgroundColor = .headyWhite
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.top.equalToSuperview()
        }
        tableView.backgroundView = emptyView
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }
    
    @objc private func pullToRefresh() {
        MasterDataManager.instance.fetch()
    }
    
    @objc private func showProductPage(showCategoryProducts: Bool = false, _ categoryId: Int = 0) {
        if showCategoryProducts {
            let category = MasterDataManager.instance.categoriesData.first(where: {($0.id == categoryId)})
            if let category = category {
                let vc = ProductListViewController(category.products, category.name, showRanking: false)
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
        
        if MasterDataManager.instance.rankingData.isEmpty {
            view.makeToast("Experiencing network issue...", duration: 1.0, position: .bottom)
            return
        }
        
        let vc =  ProductListViewController([], "Ranking", showRanking: true)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !expandCollapseCategories(indexPath) {
            if let id = MasterDataManager.instance.displayCategories[safe: indexPath.row]?.id {
                showProductPage(showCategoryProducts: true, id)
            }
        }
        // Do nothing, Just expand the cell
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = (MasterDataManager.instance.displayCategories.count != 0)
        return MasterDataManager.instance.displayCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
        cell.category = MasterDataManager.instance.displayCategories[safe: indexPath.row]
        return cell
    }
}

//MARK: -  Make View Components
extension CategoriesViewController {
    fileprivate func makeTableView() -> UITableView {
        let tableView = UITableView()
        tableView.backgroundColor = .headyWhite
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        return tableView
    }
}

//MARK: -  Listen to data change
extension CategoriesViewController {
    @objc func categoriesStartRefresh() {
        emptyView.status = .loading
    }
    
    @objc func categoriesDidUpdate() {
        //Stop the pullToRefresh
        tableView.refreshControl?.endRefreshing()
        
        //Reset the empty view status
        emptyView.status = .empty
        
        //Reload TableView
        tableView.reloadData()
    }
    
    @objc func categoriesDidFailToRefresh() {
        //Stop the pullToRefresh
        tableView.refreshControl?.endRefreshing()
        
        //Update the empty view status
        emptyView.status = .disconnected
        
        //Reload TableView
        tableView.reloadData()
        
        // If already have data, show a toast about the network issue.
        if MasterDataManager.instance.categoriesData.count > 0 {
            view.makeToast("Experiencing network issue...", duration: 1.0, position: .bottom)
        }
    }
}

//MARK: -  EmptyView Delegate
extension CategoriesViewController: EmptyViewDelegate {
    func emptyViewButtonTapped() {
        MasterDataManager.instance.fetch()
    }
}

extension CategoriesViewController {
    /// Show/hide child categories
    private func expandCollapseCategories(_ indexPath: IndexPath) -> Bool {
        let category = MasterDataManager.instance.displayCategories[indexPath.row]
        
        if !category.hasChild { // No child categories found
            return false
        }
        
        guard let mainCategory = MasterDataManager.instance.categoriesData.first(where: {$0.id == category.id}) else {
            return false
        }
        
        /// Change the category OPEN state
        MasterDataManager.instance.displayCategories[indexPath.row].isOpen = !MasterDataManager.instance.displayCategories[indexPath.row].isOpen
        
        var index = indexPath.row
        var indexPaths = [IndexPath]()
        var additionalChildCategories = [CategoryDetail]()
        
        let isOpen = MasterDataManager.instance.displayCategories[indexPath.row].isOpen
        
        if isOpen {
            for id in mainCategory.childCategories {
                if let childCategory = MasterDataManager.instance.categoriesData.first(where: {$0.id == id}) {
                    let tempCategory = CategoryDetail(id: childCategory.id, name: childCategory.name,
                                                      hasChild: childCategory.childCategories.count > 0, isOpen: false)
                    tempCategory.level = category.level + 1
                    additionalChildCategories.append(tempCategory)
                    index += 1
                    indexPaths.append(IndexPath(row: index, section: indexPath.section))
                    MasterDataManager.instance.displayCategories.insert(tempCategory, at: index) // Insert child categories to expand cells
                }
            }
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            let removedIndexs = MasterDataManager.instance.removeAllChildCategoriesFromDisplayCategories(id: category.id)  // Remove child categories to collapse cells
            indexPaths.removeAll()
            for rmi in removedIndexs {
                indexPaths.append(IndexPath(row: rmi, section: indexPath.section))
            }
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
            cell.updateIconState(MasterDataManager.instance.displayCategories[indexPath.row].isOpen)
        }
        return true
    }
}
