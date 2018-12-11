//
//  ProductListTableViewCell.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 09/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import CoreData

class ProductListTableViewCell: UITableViewCell {

    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    var product: Product?
    var tabBar: UITabBarController?
    var price = 0
    var quantityInBasket = 0
    var context: NSManagedObjectContext!
    
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var loadImageActivityView: UIActivityIndicatorView!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencySumLabel: UILabel!
    
    @IBOutlet weak var orderButton: UIButton!
    @IBAction func orderTappedButton(_ sender: UIButton) {
        
    }
    @IBOutlet weak var basketStackView: UIStackView!
    
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func quantityChangedByStepper(_ sender: Any) {
        let quantity = Int(quantityStepper.value)
        if quantity == 0 {
            quantityTextField.text = ""
            sumLabel.text = ""
            currencySumLabel.text = ""
            quantityTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            quantityTextField.textColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
        } else {
            quantityTextField.text = String(quantity)
            sumLabel.text = String(quantity * price)
            currencySumLabel.text = "руб"
            quantityTextField.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
            quantityTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
        }
        let result = rootViewController.putProductToBasket(product: product, quantity: quantity)
        if result.count != -1 {
            quantityInBasket = quantity
            tabBar?.tabBar.items?[2].badgeValue = "\(rootViewController.sumBasket())"
            
        } else {
            print(result.error)
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
        path = globalSettings.moyaPryazhaSite + "component/virtuemart/" + path + "-detail.html?Itemid=0"
        return path
    }
    
    
    
}
