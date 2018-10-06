//
//  CatalogTableViewController.swift
//  MoyaPryazha
//
//  Created by Denis Zubkov on 18/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    
    
    
    
    
    let dataProvider = DataProvider()
    let globalConstants = GlobalConstants()
    let rootViewController = AppDelegate.shared.rootViewController
    var categoryLevel: Int32 = 0
    var viewCategories: [Category] = []
    var willGoProducts = false
    let coreDataStack = CoreDataStack()
    var context: NSManagedObjectContext!
    let titleLabel = UILabel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = coreDataStack.persistentContainer.viewContext
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        tabBarController?.tabBar.items?[1].badgeValue = "\(rootViewController.products.count)"
        titleLabel.font = UIFont(name: "AaarghCyrillicBold", size: 20)// Нужный шрифт
        titleLabel.text = "Каталог товаров магазина"
        titleLabel.textColor = UIColor.white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        titleLabel.text = "Каталог"
        backBarButtonItem.isEnabled = false
        backBarButtonItem.image = nil
        viewCategories = rootViewController.categories.filter({$0.parentId == categoryLevel})
        viewCategories = viewCategories.sorted(by: {$0.order < $1.order})
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
        cell.thumbnailImage.layer.cornerRadius = 70
        cell.thumbnailImage.layer.borderWidth = 3
        cell.thumbnailImage.layer.borderColor = #colorLiteral(red: 0.9882352941, green: 0.6470588235, blue: 0.02352941176, alpha: 1)
        cell.thumbnailImage.clipsToBounds = true
        cell.loadActivityIndicator.isHidden = true
        cell.loadActivityIndicator.stopAnimating()
        let category = viewCategories[indexPath.row]
        cell.nameLabel.text = category.name
        if category.thumbnail == nil {
            if let url = category.thumbnailPath {
                if let imageURL = URL(string: "\(globalConstants.moyaPryazhaSite)\(url.replacingOccurrences(of: " ", with: "%20"))") {
                    cell.loadActivityIndicator.isHidden = false
                    cell.loadActivityIndicator.startAnimating()
                    self.dataProvider.downloadImage(url: imageURL) { image in
                        guard let image = image else {
                            cell.loadActivityIndicator.isHidden = true
                            cell.loadActivityIndicator.stopAnimating()
                            return
                        }
                        cell.thumbnailImage.image = image
                        category.thumbnail = image.pngData()
                        do {
                            try self.context.save()
                        } catch let error as NSError {
                            cell.loadActivityIndicator.isHidden = true
                            cell.loadActivityIndicator.stopAnimating()
                            print(error)
                        }
                        cell.loadActivityIndicator.isHidden = true
                        cell.loadActivityIndicator.stopAnimating()
                    }
                    
                } else {
                    cell.thumbnailImage.image = UIImage(named: "NoPhoto")
                }
            }
        } else {
            cell.thumbnailImage.image = UIImage(data: viewCategories[indexPath.row].thumbnail!)
        }
        
        // Configure the cell...
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentViewCategories = viewCategories
        categoryLevel =  viewCategories[indexPath.row].id
        backBarButtonItem.isEnabled = categoryLevel != 0
        backBarButtonItem.image = categoryLevel != 0 ? UIImage(named: "left") : nil
        viewCategories.removeAll()
        viewCategories = rootViewController.categories.filter({$0.parentId == categoryLevel})
        viewCategories = viewCategories.sorted(by: {$0.order < $1.order})
        if viewCategories.count != 0 {
            let title = currentViewCategories[indexPath.row].name
            titleLabel.text = title
            tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
            willGoProducts = false
        } else {
            if let currentCategory = currentViewCategories.first?.parentId {
                viewCategories = currentViewCategories
                categoryLevel =  currentCategory
            }
            willGoProducts = true
            performSegue(withIdentifier: "CategoryProductSegue", sender: nil)
            willGoProducts = false
        }
        
    }
    
    
    
    @IBAction func pressedBackBarButtonItem(_ sender: UIBarButtonItem) {
        willGoProducts = false
        let parentCategory = rootViewController.categories.filter({$0.id == categoryLevel})
        if let backLevel = parentCategory.first?.parentId {
            viewCategories = rootViewController.categories.filter({$0.parentId == backLevel})
            viewCategories = viewCategories.sorted(by: {$0.order < $1.order})
            categoryLevel = backLevel
            if backLevel != 0 {
                let title = rootViewController.categories.filter({$0.id == backLevel}).first?.name
                titleLabel.text = title
            } else {
                titleLabel.text = "Каталог"
            }
            backBarButtonItem.isEnabled = categoryLevel != 0
            backBarButtonItem.image = categoryLevel != 0 ? UIImage(named: "left") : nil
            tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.middle, animated: true)
        }
        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "CategoryProductSegue" {
            if willGoProducts {
                return true
            }
        }
        return false
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryProductSegue" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let currentCategory = viewCategories[indexPath.row]
                let dvc = segue.destination as! ProductListViewController
                dvc.currentCategory = currentCategory

            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
