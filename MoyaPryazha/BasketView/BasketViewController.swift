//
//  BasketViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 05/11/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import CoreData

class BasketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var basketsTableView: UITableView!
    
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var sumTotalTextField: UITextField!
    
    
    let dataProvider = DataProvider()
    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    var currentCategory: Category?
    var viewBaskets: [ProductBasket] = []
    let coreDataStack = CoreDataStack()
    var context: NSManagedObjectContext!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        basketsTableView.tableFooterView = UIView(frame: CGRect.zero)
        let titleLabel = UILabel()
        titleLabel.text = "Корзина"
        titleLabel.font = UIFont(name: "AaarghCyrillicBold", size: 17) // Нужный шрифт
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        orderButton.layer.cornerRadius = 5
        sumTotalTextField.isEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewBaskets.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        basketsTableView.deselectRow(at: indexPath, animated: true)
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//
//        if editingStyle == .delete {
//            let product = viewBaskets[indexPath.row].product
//            let _ = rootViewController.putProductToBasket(product: product, quantity: 0)
//            viewBaskets.remove(at: indexPath.row)
//            basketsTableView.deleteRows(at: [indexPath], with: .fade)
//            sumLabel.text = "\(rootViewController.sumBasket())"
//            tabBarController?.tabBar.items?[2].badgeValue = "\(rootViewController.sumBasket())"
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
         let delete = UITableViewRowAction(style: .default, title: "Удалить") { (action, indexPath) in
            let product = self.viewBaskets[indexPath.row].product
            let _ = self.rootViewController.putProductToBasket(product: product, quantity: 0)
            self.viewBaskets.remove(at: indexPath.row)
            self.basketsTableView.deleteRows(at: [indexPath], with: .fade)
            let sumBasket = self.rootViewController.sumBasket()
            if sumBasket == 0  {
                self.orderButton.isEnabled = false
                self.sumTotalTextField.text = ""
                self.sumTotalTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.sumTotalTextField.textColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
                self.tabBarController?.tabBar.items?[2].badgeValue = nil
            } else {
                self.orderButton.isEnabled = true
                self.sumTotalTextField.text = "\(sumBasket)"
                self.sumTotalTextField.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
                self.sumTotalTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                self.tabBarController?.tabBar.items?[2].badgeValue = "\(sumBasket)"
            }
        }
        delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = basketsTableView.dequeueReusableCell(withIdentifier: "Cell") as! BasketTableViewCell
        let basket = viewBaskets[indexPath.row]
        let product = basket.product
        cell.product = product
        cell.parentViewController = self
        
        cell.quantity = Int(basket.quantity)
        cell.tabBar = tabBarController // for control icon basket badge in tabBar from cell actions
        cell.quantityStepper.value = Double(cell.quantity)
        
        cell.price = Int(rootViewController.prices.filter({$0.product == basket.product && $0.priceType?.id ?? 1 == 1}).first?.price ?? 0)
        
        cell.nameProductLabel.text = product?.name
        cell.quantityTextField.text = String(basket.quantity)
        cell.priceLabel.text = "\(cell.price)"
        cell.currencyPriceLabel.text = "руб"
        
        //quantity Setup
        cell.quantityTextField.isEnabled = false
        if cell.quantity == 0 {
            cell.quantityTextField.text = ""
            cell.quantityTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            cell.quantityTextField.textColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
        } else {
            cell.quantityTextField.text = "\(cell.quantity)"
            cell.quantityTextField.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
            cell.quantityTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        //sum setup
        if cell.quantity == 0 {
            cell.sumLabel.text = ""
            cell.currencySumLabel.text = ""
            
        } else {
            cell.sumLabel.text = String(cell.price * cell.quantity)
            cell.currencySumLabel.text = "руб"
        }
        
        // image setup
        cell.previewImage.image = UIImage(named: "blank")
        if let thumbnail = product?.thumbnail {
            cell.previewImage.image = UIImage(data: thumbnail)
        } else {
            if product?.thumbnailPath != nil {
                if let url = product?.thumbnailPath, let imageURL = URL(string: "\(globalSettings.moyaPryazhaSite)\(url.replacingOccurrences(of: " ", with: "%20"))") {
                    cell.loadImageActivityView.isHidden = false
                    cell.loadImageActivityView.startAnimating()
                    self.dataProvider.downloadImage(url: imageURL) { image in
                        guard let image = image else {
                            cell.loadImageActivityView.isHidden = true
                            cell.loadImageActivityView.stopAnimating()
                            return
                        }
                        cell.previewImage.image = image
                        product?.thumbnail = image.pngData()
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
    
    override func viewDidAppear(_ animated: Bool) {
        viewBaskets = rootViewController.baskets
        basketsTableView.reloadData()
        let sumBasket = rootViewController.sumBasket()
        if sumBasket == 0  {
            self.orderButton.isEnabled = false
            self.sumTotalTextField.text = ""
            self.sumTotalTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.sumTotalTextField.textColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
        } else {
            self.orderButton.isEnabled = true
            self.sumTotalTextField.text = "\(sumBasket)"
            self.sumTotalTextField.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
            self.sumTotalTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }

    func sumBasket() -> Int {
        let sum = viewBaskets.reduce(0) { (total, basket) -> Int in
            guard let price = rootViewController.prices.filter({$0.product == basket.product && $0.priceType?.id ?? 1 == 1}).first?.price else { return 0 }
                return total + Int(basket.quantity) * Int(price)
        }
        return sum
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BasketDetailSegue" {
            if let indexPath = basketsTableView.indexPathForSelectedRow {
                if let currentProduct = viewBaskets[indexPath.row].product {
                    let dvc = segue.destination as! ProductDetailViewController
                    dvc.currentProduct = currentProduct
                }
            }
        }
        if segue.identifier == "OrderSegue" {
            let dvc = segue.destination as! OrderTableViewController
            dvc.orderSum = sumBasket()
        }
            
    }
    
    @IBAction func orderedBasketButton(_ sender: UIButton) {
        
        
    }
    
    @IBAction func returnToBasket(unwindSegue: UIStoryboardSegue) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
