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
 
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = rootViewController.globalSettings.moyaPryazhaAddress
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        mapView.delegate = self
        mapView.mapType = .hybrid
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        mapView.showsUserLocation = true
        let gpsX = rootViewController.globalSettings.gpsX
        let gpsY = rootViewController.globalSettings.gpsY
        let location2D = CLLocationCoordinate2D(latitude: gpsX, longitude: gpsY)
        let center = location2D
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        mapView.setRegion(region, animated: true)
        pointAnnotation = CustomPointAnnotation()
        pointAnnotation.pinCustomImageName = "tbm"
        pointAnnotation.coordinate = location2D
        pointAnnotation.title = "Шоу-рум Моя Пряжа"
        pointAnnotation.subtitle = "\(rootViewController.globalSettings.moyaPryazhaAddress), Тел: \(rootViewController.globalSettings.moyaPryazhaPhone) Email: \(rootViewController.globalSettings.moyaPryazhaEmail)"
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

}
