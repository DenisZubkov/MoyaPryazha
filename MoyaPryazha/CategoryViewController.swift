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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        backBarButtonItem.isEnabled = false
        backBarButtonItem.image = nil
        viewCategories = rootViewController.categories.filter({$0.parentId == categoryLevel})
        viewCategories = viewCategories.sorted(by: {$0.order < $1.order})
        categoryNameLabel.text = ""
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
        
        let currentViewCateoguries = viewCategories
        categoryLevel =  viewCategories[indexPath.row].id
        backBarButtonItem.isEnabled = categoryLevel != 0
        backBarButtonItem.image = categoryLevel != 0 ? UIImage(named: "left") : nil

        viewCategories = rootViewController.categories.filter({$0.parentId == categoryLevel})
        viewCategories = viewCategories.sorted(by: {$0.order < $1.order})
        if viewCategories.count != 0 {
            categoryNameLabel.text = currentViewCateoguries[indexPath.row].name
            tableView.reloadData()
        } else {
            if let currentCategory = currentViewCateoguries.first?.parentId {
                viewCategories = currentViewCateoguries
                categoryLevel =  currentCategory
            }
        }
    }
    
    
    
    @IBAction func pressedBackBarButtonItem(_ sender: UIBarButtonItem) {
        
        let parentCategory = rootViewController.categories.filter({$0.id == categoryLevel})
        if let backLevel = parentCategory.first?.parentId {
            viewCategories = rootViewController.categories.filter({$0.parentId == backLevel})
            viewCategories = viewCategories.sorted(by: {$0.order < $1.order})
            categoryLevel = backLevel
            if backLevel != 0 {
                categoryNameLabel.text = rootViewController.categories.filter({$0.id == backLevel}).first?.name
            } else {
                categoryNameLabel.text = ""
            }
            backBarButtonItem.isEnabled = categoryLevel != 0
            backBarButtonItem.image = categoryLevel != 0 ? UIImage(named: "left") : nil
            tableView.reloadData()
        }
        
        
    }
    
    
    // MARK: - Table view data source
   

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
