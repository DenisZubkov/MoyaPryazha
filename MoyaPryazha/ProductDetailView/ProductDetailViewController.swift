//
//  ProductDetailViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 23/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import CoreData


class ProductDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    struct TableParameter {
        var key: String
        var value: String
    }
    
    let dataProvider = DataProvider()
    let globalSettings = GlobalSettings()
    let rootViewController = AppDelegate.shared.rootViewController
    var currentProduct: Product?
    var viewProductPictures: [ProductPicture] = []
    var viewProductParameters: [ProductParameter] = []
    let coreDataStack = CoreDataStack()
    var tableParameters: [TableParameter] = []
    var context: NSManagedObjectContext!
    var price: Int = 0
    var quantityInBasket = 0
    
    @IBOutlet weak var productImageButton: UIButton!
    
    @IBOutlet weak var loadImageActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var productImageCollectionView: UICollectionView!
    @IBOutlet weak var productDetailTableView: UITableView!
    
    @IBOutlet weak var orderButton: UIButton!
    
    
    @IBOutlet weak var inBasketView: UIView!
    @IBOutlet weak var inBasketLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var currencySumLabel: UILabel!
    @IBOutlet weak var basketStackView: UIStackView!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        context = coreDataStack.persistentContainer.viewContext
        guard let product = currentProduct else { return }
        setProductData(for: product)
        loadMainImage()
        
        inBasketView.layer.borderColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
        inBasketView.layer.borderWidth = 1
        
        orderButton.layer.cornerRadius = 15
        
        
        quantityTextField.isEnabled = false
        quantityInBasket = Int(rootViewController.baskets.filter({$0.product == product}).first?.quantity ?? 0)
        if quantityInBasket == 0 {
            inBasketLabel.text = "В корзину"
            quantityTextField.text = ""
            quantityTextField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            quantityTextField.textColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
        } else {
            inBasketLabel.text = "В корзине"
            quantityTextField.text = "\(quantityInBasket)"
            quantityTextField.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
            quantityTextField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        quantityStepper.value = Double(quantityInBasket)
        
        price = Int(rootViewController.prices.filter({$0.product == product && $0.priceType?.id ?? 1 == 1}).first?.price ?? 0)
        if price == 0 {
            orderButton.isHidden = false
            basketStackView.isHidden = true
            orderButton.layer.cornerRadius = 5
        } else{
            orderButton.isHidden = true
            basketStackView.isHidden = false
            currencySumLabel.text = "руб"
            sumLabel.text = "\(price * quantityInBasket)"
        }
        
    }
    
    
    @IBAction func quantityChangedByStepper(_ sender: UIStepper) {
        
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
        let result = rootViewController.putProductToBasket(product: currentProduct, quantity: quantity)
        if result.count != -1 {
            quantityInBasket = quantity
            tabBarController?.tabBar.items?[2].badgeValue = "\(rootViewController.sumBasket())"
        } else {
            print(result.error)
        }
    }
    
    // MARK: SET VIEW FUNCTIONS
    
    func setNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        let titleLabel = UILabel()
        titleLabel.text = currentProduct?.name
        titleLabel.font = UIFont(name: "AaarghCyrillicBold", size: 17) // Нужный шрифт
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
    }
    
    
    func setProductData(for product: Product) {
        viewProductPictures = rootViewController.productPictures.filter({$0.product == product})
        viewProductPictures = viewProductPictures.sorted(by: {$0.order < $1.order})
        viewProductParameters = rootViewController.productParameters.filter({$0.product == product})
        viewProductParameters = viewProductParameters.sorted(by: {$0.parameter?.order ?? 0 < $1.parameter?.order ?? 0})
        
        var priceValue = "Под заказ"
        if let price = rootViewController.prices.filter({$0.product == product && $0.priceType?.id ?? 1 == 1}).first?.price {
            if price != 0 {
                priceValue = "\(price) руб."
            }
        }
        tableParameters.append(TableParameter(key: "Цена", value: priceValue))
        
        let key = "Категория"
        guard var parentCategory = product.category?.parentId else { return }
        guard var value = product.category?.name else { return }
        while parentCategory != 0 {
            guard let category = rootViewController.categories.filter({$0.id == parentCategory}).first else { return }
            guard let name = category.name else { return }
            value = "\(name) / \(value)"
            parentCategory = category.parentId
        }
        tableParameters.append(TableParameter(key: key, value: value))
        
        for productParameter in viewProductParameters {
            tableParameters.append(TableParameter(key: productParameter.parameter?.name ?? "", value: productParameter.value ?? ""))
        }
    }
    
    func loadMainImage() {
        productImageButton.imageView?.contentMode = .scaleAspectFit
        let productPicture = viewProductPictures[0]
        if productPicture.image == nil {
            loadImageActivityIndicatorView.isHidden = false
            loadImageActivityIndicatorView.startAnimating()
            if let url = productPicture.path, let imageURL = URL(string: "\(globalSettings.moyaPryazhaSite)\(url.replacingOccurrences(of: " ", with: "%20"))") {
                self.dataProvider.downloadImage(url: imageURL) { image in
                    guard let image = image else {
                        self.loadImageActivityIndicatorView.isHidden = true
                        self.loadImageActivityIndicatorView.stopAnimating()
                        return }
                    self.setButtonImage(image: image)
                    productPicture.image = image.pngData()
                    do {
                        try self.context.save()
                    } catch let error as NSError {
                        print(error)
                    }
                    self.loadImageActivityIndicatorView.isHidden = true
                    self.loadImageActivityIndicatorView.stopAnimating()
                }
            } else {
                self.setButtonImage(image: UIImage(named: "NoPhoto")!)
            }
        } else {
            self.setButtonImage(image: UIImage(data: productPicture.image!)!)
        }
    }
    
    // MARK: COLLECTION VIEW
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewProductPictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductImageCollectionViewCell
        cell.productPreviewActivityIndicatorView.isHidden = false
        cell.productPreviewActivityIndicatorView.startAnimating()
        let productPicture = viewProductPictures[indexPath.row]
        if productPicture.image == nil {
            if let url = productPicture.path, let imageURL = URL(string: "\(globalSettings.moyaPryazhaSite)\(url.replacingOccurrences(of: " ", with: "%20"))") {
                self.dataProvider.downloadImage(url: imageURL) { image in
                    guard let image = image else {
                        cell.productPreviewActivityIndicatorView.isHidden = true
                        cell.productPreviewActivityIndicatorView.stopAnimating()
                        return
                    }
                    cell.productPreviewImageView.image = image
                    productPicture.image = image.pngData()
                    cell.productPreviewActivityIndicatorView.isHidden = true
                    cell.productPreviewActivityIndicatorView.stopAnimating()
                    do {
                        try self.context.save()
                    } catch let error as NSError {
                        print(error)
                    }
                }
            } else {
                cell.productPreviewImageView.image = UIImage(named: "NoPhoto")
                cell.productPreviewActivityIndicatorView.isHidden = true
                cell.productPreviewActivityIndicatorView.stopAnimating()
            }
        } else {
            cell.productPreviewImageView.image = UIImage(data: productPicture.image!)
            cell.productPreviewActivityIndicatorView.isHidden = true
            cell.productPreviewActivityIndicatorView.stopAnimating()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let data = viewProductPictures[indexPath.row].image {
            setButtonImage(image: UIImage(data: data) ?? UIImage(named: "NoPhoto")!)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableParameters.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableParameters[indexPath.row].key == "Категория" {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPatameterCell", for: indexPath) as! ProductDetailTableViewCell
        cell.keyLabel.text = tableParameters[indexPath.row].key + ": "
        cell.valueLabel.text = tableParameters[indexPath.row].value
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductImageSegue" {
            if let currentImage = self.productImageButton.imageView?.image {
                let dvc = segue.destination as! ProductImageViewController
                dvc.image = currentImage
                if let titleImage = currentProduct?.name {
                    dvc.titleImage = titleImage
                }
            }
        }
    }
    
    func setButtonImage(image: UIImage) {
        self.productImageButton.setImage(image, for: .normal)
        self.productImageButton.setImage(image, for: .highlighted)
        self.productImageButton.setImage(image, for: .selected)
        self.productImageButton.setImage(image, for: .focused)
    }

    @IBAction func goToSiteButton(_ sender: UIButton) {
        if let name = currentProduct?.name {
            if let product = rootViewController.products.filter({$0.name == name}).first {
                let path = getPathForProduct(product: product) ?? ""
                guard let url = URL(string: path) else { return }
                UIApplication.shared.open(url)
            }
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
