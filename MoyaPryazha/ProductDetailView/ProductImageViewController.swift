//
//  ProductImageViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 23/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit


class ProductImageViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var productImageScrollView: UIScrollView!
    
    @IBOutlet weak var productImageImageView: UIImageView!
    
    var image = UIImage(named: "NoPhoto")
    var titleImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tabBarController?.tabBar.tintColor = .white
        let titleLabel = UILabel()
        titleLabel.text = titleImage
        titleLabel.font = UIFont(name: "AaarghCyrillicBold", size: 17) // Нужный шрифт
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        self.navigationItem.backBarButtonItem?.title = ""
        productImageImageView.image = image
        productImageScrollView.maximumZoomScale = 10
        productImageScrollView.minimumZoomScale = 1
        productImageScrollView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return productImageImageView
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
