//
//  MainViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 08/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dataProvider = DataProvider()
    let globalConstants = GlobalConstants()
    let rootViewController = AppDelegate.shared.rootViewController
    var currentCategory: Category?
    var viewProducts: [Product] = []
    
    @IBOutlet weak var ProductListTableView: UITableView!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        //tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        //title = currentCategory?.name
        let titleLabel = UILabel()
        titleLabel.text = currentCategory?.name
        titleLabel.font = UIFont(name: "Aaargh", size: 17) // Нужный шрифт
        titleLabel.textColor = UIColor.white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        viewProducts = rootViewController.products.filter({$0.category == currentCategory})
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ProductListTableView.dequeueReusableCell(withIdentifier: "HitCell", for: indexPath) as! ProductListTableViewCell
        cell.siteButton.layer.cornerRadius = 15
        let product = viewProducts[indexPath.row]
        cell.nameLabel.text = product.name
        if let price = rootViewController.prices.filter({$0.product == product && $0.priceType?.id ?? 1 == 1}).first?.price {
            cell.priceLabel.text = "\(price) руб."
        }
        if let url = product.thumbnailPath {
            if let imageURL = URL(string: "http://moya-pryazha.ru/\(url)") {
                self.dataProvider.downloadImage(url: imageURL) { image in
                    guard let image = image else { return }
                    cell.previewImage.image = image
                }

            }
        }
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getPathForProduct(product:Product) -> String? {
        var path: String = ""
        if let slug = product.slug {
            path = slug
        }
        var category = product.category
        if let slug = category?.slug {
            path = "\(slug)/\(path)"
        }
        repeat {
            if let slug = category?.slug {
                category = rootViewController.categories.filter({$0.id == category?.parentId}).first
                path = "\(slug)/\(path)"
            }
        } while category?.parentId != 0
        path = globalConstants.moyaPryazhaSite + "component/virtuemart/" + path
        return path
    }
    
}
