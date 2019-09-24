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
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
    
    @objc private func showProductPage(showAllProducts: Bool = true, _ categoryId: Int = 0) {
        if !showAllProducts {
            let category = MasterDataManager.instance.categoriesData.first(where: {($0.id == categoryId)})
            if let category = category {
                let vc = ProductListViewController(category.products, category.name)
                navigationController?.pushViewController(vc, animated: true)
                return
            }
        }
        let products = MasterDataManager.instance.categoriesData.flatMap({$0.products})
        let vc = ProductListViewController(products, "Rankings")
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !expandCollaps(indexPath) {
            if let id = MasterDataManager.instance.displayCategories[safe: indexPath.row]?.id {
                showProductPage(showAllProducts: false, id)
            }
        }
        // Do nothing
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
        //Stop the pullToRefrsh
        tableView.refreshControl?.endRefreshing()
        
        //Reset the empty view status
        emptyView.status = .empty
        
        //Reload TableView
        tableView.reloadData()
    }
    
    @objc func categoriesDidFailToRefresh() {
        //Stop the pullToRefrsh
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
    private func expandCollaps(_ indexPath: IndexPath) -> Bool {
        let category = MasterDataManager.instance.displayCategories[indexPath.row]
        
        if !category.hasChild {
            return false
        }
        
        guard let mainCategory = MasterDataManager.instance.categoriesData.first(where: {$0.id == category.id}) else {
            return false
        }
        
        MasterDataManager.instance.displayCategories[indexPath.row].isOpen = !MasterDataManager.instance.displayCategories[indexPath.row].isOpen
        
        var index = indexPath.row
        var indexPaths = [IndexPath]()
        
        var additionalChildCategories = [CategoryDetail]()
        for id in mainCategory.childCategories {
            if let childCategory = MasterDataManager.instance.categoriesData.first(where: {$0.id == id}) {
                let tempCategory = CategoryDetail(id: childCategory.id, name: childCategory.name,
                                                  hasChild: childCategory.childCategories.count > 0, isOpen: false)
                tempCategory.level = category.level + 1
                additionalChildCategories.append(tempCategory)
                index += 1
                indexPaths.append(IndexPath(row: index, section: indexPath.section))
                if MasterDataManager.instance.displayCategories[indexPath.row].isOpen {
                    MasterDataManager.instance.displayCategories.insert(tempCategory, at: index)
                }
            }
        }
        
        if MasterDataManager.instance.displayCategories[indexPath.row].isOpen {
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            let removedIndexs = MasterDataManager.instance.removeAllChildCategories(id: category.id)
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
