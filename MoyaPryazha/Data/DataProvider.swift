//
//  DataProvider.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 09/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit

class DataProvider {
    var imageCache = NSCache<NSString, UIImage>()
    var hitProductsCash = NSCache<NSString, HitProducts>()
    var dateLastModified: String?
    
    
    func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10)
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard error == nil,
                data != nil,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let _ = self else {
                    return
            }
            
            guard let image = UIImage(data: data!) else { return }
            DispatchQueue.main.async {
                completion(image)
            }
        }
        dataTask.resume()
        
    }
    
    
    func downloadHits(url:URL, completion: @escaping (HitProducts?) -> Void) {
        if UserDefaults.standard.value(forKey: "LastModified") == nil {
            hitProductsCash.removeAllObjects()
            UserDefaults.standard.set(Date(), forKey: "LastModified")
        }
        if let cachedHitProducts = hitProductsCash.object(forKey: url.absoluteString as NSString) {
            completion(cachedHitProducts)
        } else {
            let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10)
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                
                guard error == nil,
                    data != nil,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    let _ = self else {
                        return
                }
                guard let data = data else { return }
                let hitProducts = HitProducts()
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let products = try JSONDecoder().decode([ProductJSON].self, from: inputJSON!)
                    for product in products {
                        print(product.name)
                        //hitProducts.products.append(product)
                    }
                } catch let jsonError {
                    print("Error", jsonError)
                }
                DispatchQueue.main.async {
                    completion(hitProducts)
                }
            }
            dataTask.resume()
        }
    }
    
    func getModifiedDate() -> Bool {
        let globalConstants = GlobalConstants()
        let dataProvider = DataProvider()
        let urlLastModified = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvLastModufied.php"
        if let lastModifiedURL = URL(string: urlLastModified) {
            dataProvider.downloadModifiedDate(url: lastModifiedURL) { lastModified in
                guard let lastModified = lastModified else { return }
                if let date = lastModified.modifyDate {
                    self.dateLastModified = date
                }
            }
        }
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let dateLastModified = dateLastModified {
            if let date = dateformatter.date(from: dateLastModified) {
                if date.timeIntervalSinceNow > -90000 {
                    return false
                }
            }
        }
        return true
    }
    
    func downloadModifiedDate(url:URL, completion: @escaping (LastModified?) -> Void) {
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 10)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {return}
            guard data != nil  else {return}
            guard let response = response as? HTTPURLResponse else {return}
            guard response.statusCode == 200  else {return}
            guard let data = data else { return }
            var lastModified = LastModified()
            let returnData = String(data: data, encoding: .utf8)
            let inputJSON = returnData?.data(using: .utf8)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let lastModifieds = try JSONDecoder().decode([LastModified].self, from: inputJSON!)
                dump(lastModifieds)
                lastModified.modifyDate = lastModifieds.first?.modifyDate
            } catch let jsonError {
                print("Error", jsonError)
            }
            DispatchQueue.main.async {
                completion(lastModified)
            }
        }
        dataTask.resume()
        
    }
    
    
}

