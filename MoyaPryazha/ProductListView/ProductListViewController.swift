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
    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    var currentCategory: Category?
    var viewProducts: [Product] = []
    let coreDataStack = CoreDataStack()
    var context: NSManagedObjectContext!
    var searchController: UISearchController!
    var filteredResultArray: [Product] = []
    
    @IBOutlet weak var productListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = rootViewController.context
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        let titleLabel = UILabel()
        titleLabel.text = currentCategory == nil ? "Все товары" : currentCategory?.name
        titleLabel.font = UIFont(name: "AaarghCyrillicBold", size: 17) // Нужный шрифт
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        searchController = UISearchController(searchResultsController: nil)
        if currentCategory == nil {
            viewProducts = rootViewController.products
            setSearchController()
            //navigationItem.titleView = searchController.searchBar
        } else {
            viewProducts = rootViewController.products.filter({$0.category == currentCategory})
        }
        viewProducts = viewProducts.sorted(by: {$0.id < $1.id})
        productListTableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        productListTableView.reloadData()
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
        let product = productsToDisplayAt(indexPath: indexPath)
        cell.tabBar = tabBarController // for control icon basket badge in tabBar from cell actions
        cell.product = product // for send product to ProductListTableViewCell
        cell.nameLabel.text = product.name
        cell.context = context
        //quantity setup
        cell.quantityTextField.isEnabled = false
        let quantityInBasket = Int(rootViewController.baskets.filter({$0.product == product}).first?.quantity ?? 0)
        cell.quantityInBasket = quantityInBasket
        if quantityInBasket == 0 {
            cell.quantityTextField.text = ""
            cell.quantityTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.quantityTextField.textColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
        } else {
            cell.quantityTextField.text = "\(quantityInBasket)"
            cell.quantityTextField.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
            cell.quantityTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        cell.quantityStepper.value = Double(quantityInBasket)
        
        
        
        
        // price setup
        if let price = rootViewController.prices.filter({$0.product == product && $0.priceType?.id ?? 1 == 1}).first?.price {
            cell.price = Int(price)
            
        } else {
           cell.price = -1
            guard let value = globalSettings.modelSources.filter({$0.key == .price}).first?.value else { return cell}
            let urlSource = globalSettings.moyaPryazhaSite + globalSettings.moyaPryazhaServicesPath + value
            if let url = URL(string: urlSource) {
                //result = getData(url: url, dataType: source.key)
                dataProvider.downloadData(url: url) { data in
                    if let data = data {
                        let _ = self.rootViewController.parcePrices(from: data, to: self.context)
                        let _ = self.rootViewController.loadPricesFromCoreData(context: self.context)
                        if let price = self.rootViewController.prices.filter({$0.product == product && $0.priceType?.id ?? 1 == 1}).first?.price {
                            DispatchQueue.main.async {
                                cell.price = Int(price)
                            }
                        }
                    }
                }
            }
           
        }
        if cell.price == 0 {
            cell.basketStackView.isHidden = true
            cell.orderButton.isHidden = false
            cell.orderButton.layer.cornerRadius = 5
        } else{
            cell.basketStackView.isHidden = false
            cell.orderButton.isHidden = true
            cell.currencyLabel.text = "руб"
            cell.priceLabel.text = String(cell.price)
        }
        
        
        //sum setup
        if quantityInBasket == 0 {
            cell.sumLabel.text = ""
            cell.currencySumLabel.text = ""
            
        } else {
            cell.sumLabel.text = String(cell.price * quantityInBasket)
            cell.currencySumLabel.text = "руб"
        }
        
        // image setup
        cell.previewImage.image = UIImage(named: "blank")
        if let thumbnail = product.thumbnail {
            cell.previewImage.image = UIImage(data: thumbnail)
        } else {
            if product.thumbnailPath != nil {
                if let url = product.thumbnailPath, let imageURL = URL(string: "\(globalSettings.moyaPryazhaSite)\(url.replacingOccurrences(of: " ", with: "%20"))") {
                    cell.loadImageActivityView.isHidden = false
                    cell.loadImageActivityView.startAnimating()
                    self.dataProvider.downloadImage(url: imageURL) { image in
                        if let image = image {
                            product.thumbnail = image.pngData()
                            cell.previewImage.image = image
                            do {
                                try self.context.save()
                            } catch let error as NSError {
                                print(error)
                            }
                        } else {
                            cell.previewImage.image = UIImage(named: "NoPhoto")
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
    
    func setSearchController() {
        //searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.setValue("Отмена", forKey: "_cancelButtonText")
        searchController.searchBar.placeholder = "Искать..."
        searchController.hidesNavigationBarDuringPresentation = true
        productListTableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.searchBar.barTintColor = #colorLiteral(red: 0.9882352941, green: 0.6470588235, blue: 0.02352941176, alpha: 1)
        searchController.searchBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    func filterContentFor(searchText text: String) {
        filteredResultArray = viewProducts.filter { (product) -> Bool in
            if let productName = product.name?.lowercased().contains(text.lowercased()),
                let categoryName = product.category?.name!.lowercased().contains(text.lowercased()) {
                if productName || categoryName {
                    return true
                }
            }
            return false
            
        }
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
        path = globalSettings.moyaPryazhaSite + "component/virtuemart/" + path
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
