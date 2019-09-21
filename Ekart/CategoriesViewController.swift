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
//        navigationController?.navigationBar.prefersLargeTitles = true
        
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
    
    /// Show/hide child categories
    private func expandCollaps(_ section: Int) -> Bool {
        let childCount = MasterDataManager.instance.categoriesData[section].childCategories.count
        
        if childCount <= 0 {
            return false
        }
        
        var isOpen = false
        if let unWrappedValue = MasterDataManager.instance.categoriesData[section].isOpen {
            isOpen = unWrappedValue
        }
        
        var indexPaths = [IndexPath]()
        for i in 1...childCount {
            indexPaths.append(IndexPath(row: i, section: section))
        }
        
        MasterDataManager.instance.categoriesData[section].isOpen = !isOpen
        
        if !isOpen {
            tableView.insertRows(at: indexPaths, with: .fade)
        } else {
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as? CategoryCell {
            cell.updateIconState(!isOpen)
        }
        return true
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.backgroundView?.isHidden = (MasterDataManager.instance.categoriesData.count != 0)
        return MasterDataManager.instance.categoriesData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = MasterDataManager.instance.categoriesData[section]
        return (category.isOpen ?? false) ? category.childCategories.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
        let mainCategory = MasterDataManager.instance.categoriesData[indexPath.section]
        if indexPath.row == 0 {
            cell.setupCell(name: mainCategory.name, isOpen: mainCategory.isOpen, hasChild: mainCategory.childCategories.count > 0)
            return cell
        }
        if let childCategories = mainCategory.childCategoriesDetail {
            cell.setupCell(true, name: childCategories[indexPath.row - 1].name, isOpen: false)
            return cell
        }
        cell.setupCell(name: "") // For safe, should never fall here
        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            return
        }
        if !expandCollaps(indexPath.section) {
            
        }
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
