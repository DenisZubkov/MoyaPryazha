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
    var matchingItemsDaData:[Suggestion?] = []
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    let searchMethod: SearchMethod = .DaData
    var searchString: String = ""
    var searchController: UISearchController?
    
    enum SearchMethod {
        case Yandex
        case Apple
        case DaData
    }
    
}

extension AddressTableViewController : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        searchString = searchBarText
        if searchBarText != "" {
            switch searchMethod {
            case .Apple:
                viaAppleMap(searchBarText: searchBarText, mapView: mapView)
            case .Yandex:
                viaYandexMap(searchBarText: searchBarText)
            case .DaData:
                viaDaData(searchBarText: searchBarText)
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
            self.matchingItems.insert(MKMapItem(), at: 0)
            self.tableView.reloadData()
        }
        self.tableView.reloadData()
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
    
    
    func viaDaData(searchBarText: String) {
        let baseURL = URL(string: "https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/address")!
        let userData: [String: String] = [
            "query": searchBarText,
            "count": "10"
        ]
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Token eef6e94d5fe621a8186212e446bf3e4cdcaf0976", forHTTPHeaderField: "Authorization")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else { return }
        request.httpBody = httpBody
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let returnData = String(data: data, encoding: .utf8)
                //print("\(returnData ?? "")")
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let result = try JSONDecoder().decode(AddressDaData.self, from: inputJSON!)
                    let results = result.suggestions
                    self.matchingItemsDaData = results
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
        switch searchMethod {
        case .Apple:
            return matchingItems.count
        case .Yandex:
            return matchingItemsYandex.count
        case .DaData:
            return matchingItemsDaData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch searchMethod {
        case .Apple:
            let selectedItem = matchingItems[indexPath.row]
//            let coordinate = selectedItem.placemark.coordinate
//            let geoCoder = CLGeocoder()
//            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
//                var placeMark: CLPlacemark!
//                placeMark = placemarks?[0]
//            }
            cell.textLabel?.text = indexPath.row == 0 ? searchString : parseAddress(selectedItem: selectedItem.placemark)
        case .Yandex:
            let selectedItem = matchingItemsYandex[indexPath.row]
            cell.textLabel?.text = selectedItem?.geoObject?.metaDataProperty?.geocoderMetaData?.text
            cell.detailTextLabel?.text = selectedItem?.geoObject?.metaDataProperty?.geocoderMetaData?.text
        case .DaData:
            let selectedItem = matchingItemsDaData[indexPath.row]
            if var postalCode = selectedItem?.data?.postalCode {
                postalCode = postalCode + ", "
                cell.textLabel?.text = "\(postalCode), \(selectedItem?.value ?? "")"
            } else {
                cell.textLabel?.text = selectedItem?.value
            }
        }
        
        return cell
    }
    
}

extension AddressTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch searchMethod  {
        case .Apple:
            let selectedItem = matchingItems[indexPath.row].placemark
            handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem, addressString: parseAddress(selectedItem: selectedItem))
        default:
            if let address = matchingItemsDaData[indexPath.row]?.value {
                var postalCodeWithZ: String = ""
                if let postalCode = matchingItemsDaData[indexPath.row]?.data?.postalCode {
                    postalCodeWithZ = postalCode + ", "
                }
                searchController?.searchBar.text = postalCodeWithZ + address
                handleMapSearchDelegate?.saveAddress(addressString: postalCodeWithZ + address)
            }
        }
        
        
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
