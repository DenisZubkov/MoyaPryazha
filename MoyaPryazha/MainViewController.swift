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
    var hitProducts: [Product] = []
    let globalConstants = GlobalConstants()
    
    @IBOutlet weak var hitTableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        
        
            
       
//        let url = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvHits.php"
//        if let hitProductsURL = URL(string: url) {
//            self.dataProvider.downloadHits(url: hitProductsURL) { hitProducts in
//                guard let hitProducts = hitProducts else { return }
//                self.hitProducts = hitProducts.products
//                DispatchQueue.main.async {
//                    self.hitTableView.reloadData()
//                }
//            }
//
//        }

//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        // Do any additional setup after loading the view.
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hitProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hitTableView.dequeueReusableCell(withIdentifier: "HitCell", for: indexPath) as! HitTableViewCell
        cell.siteButton.layer.cornerRadius = 15
//        cell.nameLabel.text = hitProducts[indexPath.row].name
//        if let price = String(hitProducts[indexPath.row].price) {
//            cell.priceLabel.text = price + " руб."
//        }
//        if let url = hitProducts[indexPath.row].thumbnail {
//            if let imageURL = URL(string: "http://moya-pryazha.ru/" + url) {
//                self.dataProvider.downloadImage(url: imageURL) { image in
//                    guard let image = image else { return }
//                    cell.previewImage.image = image
//                }
//
//            }
//        }
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
