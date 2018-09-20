//
//  MainViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 08/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let dataProvider = DataProvider()
    let globalConstants = GlobalConstants()
    let rootViewController = AppDelegate.shared.rootViewController
    
    
    @IBOutlet weak var hitTableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rootViewController.hits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hitTableView.dequeueReusableCell(withIdentifier: "HitCell", for: indexPath) as! HitTableViewCell
        cell.siteButton.layer.cornerRadius = 15
        let hit = rootViewController.hits[indexPath.row]
        cell.nameLabel.text = hit.product?.name
        if let price = rootViewController.prices.filter({$0.product == hit.product && $0.priceType?.id ?? 1 == 1}).first?.price {
            cell.priceLabel.text = "\(price) руб."
        }
        if let url = hit.product?.thumbnailPath {
            if let imageURL = URL(string: "http://moya-pryazha.ru/\(url)") {
                self.dataProvider.downloadImage(url: imageURL) { image in
                    guard let image = image else { return }
                    cell.previewImage.image = image
                }

            }
        }
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

}
