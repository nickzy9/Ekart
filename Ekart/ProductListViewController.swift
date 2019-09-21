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
    @IBOutlet weak var tableView: UITableView!
    
    var products: [CategoryProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension ProductListViewController: UITableViewDelegate {
    
}

extension ProductListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}
