//
//  CatalogTableViewController.swift
//  MoyaPryazha
//
//  Created by Denis Zubkov on 18/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    
    
    
    
    
    let dataProvider = DataProvider()
    let globalConstants = GlobalConstants()
    let rootViewController = AppDelegate.shared.rootViewController
    var categoryLevel: Int32 = 0
    var viewCategories: [Category] = []
    var willGoProducts = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    
        //tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        title = "Каталог"
        backBarButtonItem.isEnabled = false
        backBarButtonItem.image = nil
        viewCategories = rootViewController.categories.filter({$0.parentId == categoryLevel})
        viewCategories = viewCategories.sorted(by: {$0.order < $1.order})
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
        
        cell.nameLabel.text = viewCategories[indexPath.row].name
        if let url = viewCategories[indexPath.row].thumbnailPath {
            if let imageURL = URL(string: "http://moya-pryazha.ru/\(url)") {
                self.dataProvider.downloadImage(url: imageURL) { image in
                    guard let image = image else { return }
                    cell.thumbnailImage.image = image
                }
                
            }
        }
        
        // Configure the cell...
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentViewCategories = viewCategories
        categoryLevel =  viewCategories[indexPath.row].id
        backBarButtonItem.isEnabled = categoryLevel != 0
        backBarButtonItem.image = categoryLevel != 0 ? UIImage(named: "left") : nil

        viewCategories = rootViewController.categories.filter({$0.parentId == categoryLevel})
        viewCategories = viewCategories.sorted(by: {$0.order < $1.order})
        if viewCategories.count != 0 {
            title = currentViewCategories[indexPath.row].name
            tableView.reloadData()
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
                title = rootViewController.categories.filter({$0.id == backLevel}).first?.name
            } else {
                title = "Каталог"
            }
            backBarButtonItem.isEnabled = categoryLevel != 0
            backBarButtonItem.image = categoryLevel != 0 ? UIImage(named: "left") : nil
            tableView.reloadData()
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
