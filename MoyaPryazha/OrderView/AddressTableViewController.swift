//
//  AddressTableViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 19/11/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import MapKit

class AddressTableViewController: UITableViewController {

    var handleMapSearchDelegate:HandleMapSearch? = nil
    var matchingItemsYandex:[FeatureMember?] = []
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    let searchMethod = "Apple"
    
    
}

extension AddressTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        if searchBarText != "" {
            if searchMethod == "Apple" {
                viaAppleMap(searchBarText: searchBarText, mapView: mapView)
            } else {
                viaYandexMap(searchBarText: searchBarText)
            }
            
            
        }
        
        
    }
    
    func viaAppleMap(searchBarText: String, mapView: MKMapView) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    func viaYandexMap(searchBarText: String) {
        let baseURL = URL(string: "https://geocode-maps.yandex.ru/1.x/")!
        let query: [String: String] = [
            "apikey": "5bbd34b3-b0fc-4b00-9dae-a6aa176a1876",
            "format": "json",
            "geocode": searchBarText
        ]
        let url = baseURL.withQueries(query)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let returnData = String(data: data, encoding: .utf8)
                print("\(returnData ?? "")")
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let result = try JSONDecoder().decode(AddressYandex.self, from: inputJSON!)
                    let results = result.response?.geoObjectCollection?.featureMember
                    self.matchingItemsYandex = results!
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch let error as NSError {
                    print("Ошибка JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        
        let firstSpace = selectedItem.administrativeArea != nil ? ", " : ""
        let secondSpace = selectedItem.locality != nil ? ", " : ""
        let thirdSpace = selectedItem.thoroughfare != nil ? ", " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // state
            selectedItem.administrativeArea ?? "",
            firstSpace,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            thirdSpace,
            // street number
            selectedItem.subThoroughfare ?? ""
        )
        return addressLine
    }

}

extension AddressTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchMethod == "Apple" {
            return matchingItems.count
        } else {
            return matchingItemsYandex.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if searchMethod == "Apple" {
            let selectedItem = matchingItems[indexPath.row]
//            let coordinate = selectedItem.placemark.coordinate
//            let geoCoder = CLGeocoder()
//            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
//                var placeMark: CLPlacemark!
//                placeMark = placemarks?[0]
//            }
            cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem.placemark)
        } else {
            let selectedItem = matchingItemsYandex[indexPath.row]
            cell.textLabel?.text = selectedItem?.geoObject?.metaDataProperty?.geocoderMetaData?.text
            cell.detailTextLabel?.text = selectedItem?.geoObject?.metaDataProperty?.geocoderMetaData?.text
        }
        return cell
    }
    
}

extension AddressTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem, addressString: parseAddress(selectedItem: selectedItem))
        dismiss(animated: true, completion: nil)
    }
}

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.compactMap { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
    
}
