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
    let globalConstants = GlobalConstants()
    let rootViewController = AppDelegate.shared.rootViewController
    var currentProduct: Product?
    var viewProductPictures: [ProductPicture] = []
    var viewProductParameters: [ProductParameter] = []
    let coreDataStack = CoreDataStack()
    var tableParameters: [TableParameter] = []
    var context: NSManagedObjectContext!
    
    @IBOutlet weak var productImageButton: UIButton!
    
    @IBOutlet weak var loadImageActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var productImageCollectionView: UICollectionView!
    @IBOutlet weak var productDetailTableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = coreDataStack.persistentContainer.viewContext
        viewProductPictures = rootViewController.productPictures.filter({$0.product == currentProduct})
        viewProductPictures = viewProductPictures.sorted(by: {$0.order < $1.order})
        viewProductParameters = rootViewController.productParameters.filter({$0.product == currentProduct})
        viewProductParameters = viewProductParameters.sorted(by: {$0.parameter?.order ?? 0 < $1.parameter?.order ?? 0})
        var priceValue = "Под заказ"
        if let price = rootViewController.prices.filter({$0.product == currentProduct && $0.priceType?.id ?? 1 == 1}).first?.price {
            if price != 0 {
                priceValue = "\(price) руб."
            }
        }
        tableParameters.append(TableParameter(key: "Цена", value: priceValue))
        for productParameter in viewProductParameters {
            tableParameters.append(TableParameter(key: productParameter.parameter?.name ?? "", value: productParameter.value ?? ""))
        }
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
        productImageButton.imageView?.contentMode = .scaleAspectFit
        let productPicture = viewProductPictures[0]
        if productPicture.image == nil {
            loadImageActivityIndicatorView.isHidden = false
            loadImageActivityIndicatorView.startAnimating()
            if let url = productPicture.path, let imageURL = URL(string: "\(globalConstants.moyaPryazhaSite)\(url.replacingOccurrences(of: " ", with: "%20"))") {
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewProductPictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductImageCollectionViewCell
        cell.productPreviewActivityIndicatorView.isHidden = false
        cell.productPreviewActivityIndicatorView.startAnimating()
        let productPicture = viewProductPictures[indexPath.row]
        if productPicture.image == nil {
            if let url = productPicture.path, let imageURL = URL(string: "\(globalConstants.moyaPryazhaSite)\(url.replacingOccurrences(of: " ", with: "%20"))") {
                self.dataProvider.downloadImage(url: imageURL) { image in
                    guard let image = image else {
                        cell.productPreviewActivityIndicatorView.isHidden = true
                        cell.productPreviewActivityIndicatorView.startAnimating()
                        return
                    }
                    cell.productPreviewImageView.image = image
                    productPicture.image = image.pngData()
                    cell.productPreviewActivityIndicatorView.isHidden = true
                    cell.productPreviewActivityIndicatorView.startAnimating()
                    do {
                        try self.context.save()
                    } catch let error as NSError {
                        print(error)
                    }
                }
            } else {
                cell.productPreviewImageView.image = UIImage(named: "NoPhoto")
                cell.productPreviewActivityIndicatorView.isHidden = true
                cell.productPreviewActivityIndicatorView.startAnimating()
            }
        } else {
            cell.productPreviewImageView.image = UIImage(data: productPicture.image!)
            cell.productPreviewActivityIndicatorView.isHidden = true
            cell.productPreviewActivityIndicatorView.startAnimating()
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

}
