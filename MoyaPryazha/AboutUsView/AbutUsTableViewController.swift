//
//  AbutUsTableViewController.swift
//  MoyaPryazha
//
//  Created by Denis Zubkov on 24/10/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import MessageUI
import MapKit

class AbutUsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    let rootViewController = AppDelegate.shared.rootViewController
    let locationManager = CLLocationManager()
    var pointAnnotation: CustomPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    let titleLabel = UILabel()
 
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = rootViewController.globalSettings.moyaPryazhaAddress
        
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
            return
        }
        statusBarView.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
        
        tabBarController?.tabBar.tintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        titleLabel.font = UIFont(name: "AaarghCyrillicBold", size: 17)
        titleLabel.text = "Интернет-Магазин Моя Пряжа"
        titleLabel.textColor = UIColor.white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        let gpsX = rootViewController.globalSettings.gpsX
        let gpsY = rootViewController.globalSettings.gpsY
        let location2D = CLLocationCoordinate2D(latitude: gpsX, longitude: gpsY)
        let center = location2D
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        mapView.setRegion(region, animated: true)
        pointAnnotation = CustomPointAnnotation()
        pointAnnotation.pinCustomImageName = "MPLaunchScreen"
        pointAnnotation.coordinate = location2D
        pointAnnotation.title = "Шоу-рум Моя Пряжа"
        //pointAnnotation.subtitle = "\(rootViewController.globalSettings.moyaPryazhaAddress), \n Тел: \(rootViewController.globalSettings.moyaPryazhaPhone) \n Email: \(rootViewController.globalSettings.moyaPryazhaEmail)"
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        mapView.addAnnotation(pinAnnotationView.annotation!)
    }
    
    func sendMail(mail: String) {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients([mail])
        mailComposeViewController.setSubject("Вопрос о ...")
        mailComposeViewController.setMessageBody("Добый день.", isHTML: false)
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
    }
    
    @IBAction func callSocialContacts(_ sender: UIButton) {
        var urlStr: String = rootViewController.globalSettings.moyaPryazhaSite
        switch sender.accessibilityIdentifier {
        case "InstagramButton":
            urlStr = rootViewController.globalSettings.moyaPryazhaInstagramApp
        case "FacebookButton":
            urlStr = rootViewController.globalSettings.moyaPryazhaFacebookApp
        case "TwitterButton":
            urlStr = rootViewController.globalSettings.moyaPryazhaTwitterApp
        case "PhoneButton":
            urlStr = rootViewController.globalSettings.moyaPryazhaPhone
        case "EmailButton":
            urlStr = rootViewController.globalSettings.moyaPryazhaEmail
            sendMail(mail: urlStr)
            return
        default:
            urlStr = rootViewController.globalSettings.moyaPryazhaSite
        }
        var url = URL(string: urlStr)
        if UIApplication.shared.canOpenURL(url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url!)
            }
        } else {
            switch sender.accessibilityIdentifier {
            case "InstagramButton":
                urlStr = rootViewController.globalSettings.moyaPryazhaInstagramSite
            case "FacebookButton":
                urlStr = rootViewController.globalSettings.moyaPryazhaFacebookSite
            case "TwitterButton":
                urlStr = rootViewController.globalSettings.moyaPryazhaTwitterSite
            default:
                urlStr = rootViewController.globalSettings.moyaPryazhaSite
            }
            url = URL(string: urlStr)
            if UIApplication.shared.canOpenURL(url!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }
        }
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
}
