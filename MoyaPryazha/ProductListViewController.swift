//
//  MainViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 08/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import CoreData

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dataProvider = DataProvider()
    let globalConstants = GlobalConstants()
    let rootViewController = AppDelegate.shared.rootViewController
    var currentCategory: Category?
    var viewProducts: [Product] = []
    let coreDataStack = CoreDataStack()
    var context: NSManagedObjectContext!
    var searchController: UISearchController!
    var filteredResultArray: [Product] = []
    
    @IBOutlet weak var productListTableView: UITableView!
    
    
    func filterContentFor(searchText text: String) {
        filteredResultArray = viewProducts.filter { (product) -> Bool in
            if (product.name?.lowercased().contains(text.lowercased()))! ||
                (product.category?.name!.lowercased().contains(text.lowercased()))!
            {
                return true
            }
            return false
            
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        context = coreDataStack.persistentContainer.viewContext
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.setValue("Отмена", forKey: "_cancelButtonText")
        searchController.searchBar.placeholder = "Искать..."
        productListTableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchBar.barTintColor = #colorLiteral(red: 0.9882352941, green: 0.6470588235, blue: 0.02352941176, alpha: 1)
        searchController.searchBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        //tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        //title = currentCategory?.name
        
        let titleLabel = UILabel()
        titleLabel.text = currentCategory == nil ? "Все товары" : currentCategory?.name
        titleLabel.font = UIFont(name: "AaarghCyrillicBold", size: 17) // Нужный шрифт
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        if currentCategory == nil {
            viewProducts = rootViewController.products
           
        } else {
            viewProducts = rootViewController.products.filter({$0.category == currentCategory})
        }
        viewProducts = viewProducts.sorted(by: {$0.order < $1.order})
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != nil {
            return filteredResultArray.count
        }
        return viewProducts.count
    }
    
    
    func productsToDisplayAt(indexPath: IndexPath) -> Product {
        let productToDisplay: Product
        if searchController.isActive && searchController.searchBar.text != nil {
            productToDisplay = filteredResultArray[indexPath.row]
        } else {
            productToDisplay =  viewProducts[indexPath.row]
        }
        return productToDisplay
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productListTableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductListTableViewCell
        cell.siteButton.layer.cornerRadius = 15
        let product = productsToDisplayAt(indexPath: indexPath)
        cell.nameLabel.text = product.name
        if let price = rootViewController.prices.filter({$0.product == product && $0.priceType?.id ?? 1 == 1}).first?.price {
            if price == 0 {
                cell.priceLabel.text = "Под заказ"
            } else{
                cell.priceLabel.text = "\(price) руб."
            }
        }
        cell.previewImage.image = nil
        if let thumbnail = product.thumbnail {
            cell.previewImage.image = UIImage(data: thumbnail)
        } else {
            if product.thumbnailPath != nil {
                if let url = product.thumbnailPath, let imageURL = URL(string: "\(globalConstants.moyaPryazhaSite)\(url.replacingOccurrences(of: " ", with: "%20"))") {
                    cell.loadImageActivityView.isHidden = false
                    cell.loadImageActivityView.startAnimating()
                    self.dataProvider.downloadImage(url: imageURL) { image in
                        guard let image = image else {
                            cell.loadImageActivityView.isHidden = true
                            cell.loadImageActivityView.stopAnimating()
                            return
                        }
                        cell.previewImage.image = image
                        product.thumbnail = image.pngData()
                        do {
                            try self.context.save()
                        } catch let error as NSError {
                            print(error)
                            cell.loadImageActivityView.isHidden = true
                            cell.loadImageActivityView.stopAnimating()
                        }
                    cell.loadImageActivityView.isHidden = true
                    cell.loadImageActivityView.stopAnimating()
                    }
                } else {
                    cell.previewImage.image = UIImage(named: "NoPhoto")
                }
            } else {
                cell.previewImage.image = UIImage(named: "NoPhoto")
            }
        }
        
 

        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         performSegue(withIdentifier: "ProductDetailSegue", sender: nil)
//    }
    
    func addProductThumbnailToCoreData(thumbnail: Data?, id: Int32) {
        context = coreDataStack.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", String(id))
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            results.first?.thumbnail = thumbnail
            
        } catch let error as NSError {
            print(error)
        }
        do {
            try self.context.save()
        } catch let error as NSError {
            print(error)
        }
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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductDetailSegue" {
            if let indexPath = productListTableView.indexPathForSelectedRow {
                let currentProduct = productsToDisplayAt(indexPath: indexPath)
                let dvc = segue.destination as! ProductDetailViewController
                dvc.currentProduct = currentProduct
            }
        }
    }
    
}

extension ProductListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentFor(searchText: searchController.searchBar.text!)
        productListTableView.reloadData()
    }
    
    
}
