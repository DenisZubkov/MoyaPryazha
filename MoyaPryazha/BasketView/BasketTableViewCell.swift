//
//  BasketTableViewCell.swift
//  MoyaPryazha
//
//  Created by Denis Zubkov on 06/11/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import CoreData

class BasketTableViewCell: UITableViewCell {
    
    var price: Int = 0
    var quantity: Int = 0
    var product: Product?
    var tabBar: UITabBarController?
    let rootViewController = AppDelegate.shared.rootViewController
    let globalSettings = GlobalSettings()
    var parentViewController: BasketViewController?
    

    @IBOutlet weak var nameProductLabel: UILabel!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyPriceLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var currencySumLabel: UILabel!
    @IBOutlet weak var loadImageActivityView: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func quantityChangedByStepper(_ sender: UIStepper) {
        let quantity = Int(quantityStepper.value)
        if quantity == 0 {
            quantityTextField.text = ""
            sumLabel.text = ""
            currencySumLabel.text = ""
            quantityTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            quantityTextField.textColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
            if let indexPath = parentViewController?.basketsTableView.indexPath(for: self) {
                parentViewController?.viewBaskets.remove(at: indexPath.row)
                parentViewController?.basketsTableView.deleteRows(at: [indexPath], with: .fade)
                //parentViewController?.basketsTableView.reloadData()
            }
            
        } else {
            quantityTextField.text = String(quantity)
            sumLabel.text = String(quantity * price)
            currencySumLabel.text = "руб"
            quantityTextField.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
            quantityTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
        }
        let result = rootViewController.putProductToBasket(product: product, quantity: quantity)
        if result.count != -1 {
            let sumBasket = rootViewController.sumBasket()
            if sumBasket == 0  {
                parentViewController?.orderButton.isEnabled = false
                parentViewController?.sumTotalTextField.text = ""
                parentViewController?.sumTotalTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                parentViewController?.sumTotalTextField.textColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
                tabBar?.tabBar.items?[2].badgeValue = nil
            } else {
                parentViewController?.orderButton.isEnabled = true
                parentViewController?.sumTotalTextField.text = "\(sumBasket)"
                parentViewController?.sumTotalTextField.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
                parentViewController?.sumTotalTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                tabBar?.tabBar.items?[2].badgeValue = "\(sumBasket)"
            }
        } else {
            print(result.error)
        }
    }
    
}
