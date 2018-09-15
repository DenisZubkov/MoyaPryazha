//
//  LoadViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 15/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit

class LoadViewController: UIViewController {

    @IBOutlet weak var loadProgressView: UIProgressView!
    
    var lastModifiedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadProgressView.progress = 0
        if UserDefaults.standard.value(forKey: "LastModified") == nil {
            UserDefaults.standard.set(lastModifiedDate, forKey: "LastModified")
        }
        if let date = getModifiedDate() {
            UserDefaults.standard.set(date, forKey: "LastModified")
            lastModifiedDate = date
        }
        loadProgressView.progress = 0.2
    }
    
    func getData(url: URL) -> Data? {
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 10)
        var dataLoad: Data?
        var isLoad = false
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            var message: String?
            var title: String?
            if error != nil {
                message = error?.localizedDescription
                title = "Ошибка"
            }
            if data == nil {
                message = "Не удалось получить данные :("
                title = "Ошибка данных"
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    message = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                    title = "Ошибка сервера данных"
                }
            } else {
                message = "Нет ответа от сервера"
                title = "Ошибка сервера данных"
            }
            if let message = message,
                let title = title {
                DispatchQueue.main.async {
                    self.showMessage(title: title, message: message)
                }
                isLoad = true
                return
            }
            dataLoad = data
            isLoad = true
        }
        dataTask.resume()
        while dataTask.state != .completed {
        }
        while isLoad != true {
        }
        return dataLoad
    }
    
    
    func showMessage(title: String, message: String) {
        let alertData = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertData.addAction(cancelAction)
        self.present(alertData, animated: true, completion: nil)
    }
    
    func getModifiedDate() -> Date? {
        let globalConstants = GlobalConstants()
        var currentDate: Date?
        let urlLastModified = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvLastModified.php"
        if let lastModifiedURL = URL(string: urlLastModified) {
            if let data = getData(url: lastModifiedURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let lastModifieds = try JSONDecoder().decode([LastModified].self, from: inputJSON!)
                    dump(lastModifieds)
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    if let date = lastModifieds.first?.modifyDate {
                        currentDate = dateformatter.date(from: date)
                    }
                } catch let jsonError {
                    print("Error", jsonError)
                }
            }
        }
        return currentDate
    }
}




    

