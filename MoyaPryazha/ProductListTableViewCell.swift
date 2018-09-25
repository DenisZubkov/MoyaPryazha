//
//  ProductListTableViewCell.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 09/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {

    let globalConstants = GlobalConstants()
    let rootViewController = AppDelegate.shared.rootViewController
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var siteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func goToSite(_ sender: UIButton) {
        let name = self.nameLabel.text
        if let product = rootViewController.products.filter({$0.name == name}).first {
            let path = getPathForProduct(product: product) ?? ""
            guard let url = URL(string: path) else { return }
            UIApplication.shared.open(url)
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
        path = globalConstants.moyaPryazhaSite + "component/virtuemart/" + path + "-detail.html?Itemid=0"
        return path
    }
    
    
    
}
