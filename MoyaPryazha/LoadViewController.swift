//
//  LoadViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 15/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import CoreData

class LoadViewController: UIViewController {

    @IBOutlet weak var loadProgressView: UIProgressView!
    
    var lastModifiedDate = Date()
    let globalConstants = GlobalConstants()
    let coreDataStack = CoreDataStack()
    var context: NSManagedObjectContext!
    var error = false
    var categories: [Category] = []
    var products: [Product] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        error = loadData()
    }
    
    func loadData() -> Bool {
        
        if UserDefaults.standard.value(forKey: "LastModified") == nil {
            UserDefaults.standard.set(lastModifiedDate, forKey: "LastModified")
        }
        
        // Date last modify data on server

        loadProgressView.progress = 0
        guard let date = getModifiedDate() else { return true }
        UserDefaults.standard.set(date, forKey: "LastModified")
        self.lastModifiedDate = date
        
        // Categories array
        
        loadProgressView.progress = 0.2
        guard let categories = getCategories() else { return true }
        self.categories = categories
        print(self.categories.count)
        
        // Products array
        
        loadProgressView.progress = 0.4
        guard let products = getProducts() else { return true }
        self.products = products
        print(self.products.count)
        
        return false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if error {
            error = loadData()
        }
        performSegue(withIdentifier: "ToMainSegue", sender: nil)
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
    
    // MARK: CATEGORIES
    
    func getCategories()-> [Category]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnCategories: [Category] = []
        let urlCategories = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvCategories.php"
        if let categoriesURL = URL(string: urlCategories) {
            if let data = getData(url: categoriesURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let categories = try JSONDecoder().decode([CategoryJSON].self, from: inputJSON!)
                    if categories.count != 0 {
                        let deletedCategories = deleteCategoriesFromCoreData(context: self.context)
                        if deletedCategories.count == -1 {
                            showMessage(title: "Ошибка", message: deletedCategories.error)
                            return nil
                        }
                        let addedCategories = addCategoriesToCoreData(categories: categories, context: self.context)
                        if addedCategories.count == -1 {
                            showMessage(title: "Ошибка", message: addedCategories.error)
                            return nil
                        }
                    }
                } catch let jsonError {
                    showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnCategories = results
        } catch let error as NSError {
            showMessage(title: "Ошибка", message: error.localizedDescription)
        }
        return returnCategories
    }
    
    func deleteCategoriesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                self.context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        do {
            try self.context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)}
        return returnResult
    }
    
    func addCategoriesToCoreData(categories: [CategoryJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var categoryCurrent: Category!
        for category in categories {
            categoryCurrent = Category(context: self.context)
            // присваиваем переданные свойства
            categoryCurrent.id = Int32(category.id) ?? 0
            categoryCurrent.name = category.name
            categoryCurrent.picturePath = category.picture
            categoryCurrent.thumbnailPath = category.thumbnail
            categoryCurrent.parentId = Int32(category.parentId) ?? 0
            categoryCurrent.order = Int32(category.order) ?? 0
            returnResult.count += returnResult.count
            
        }
        do {
            try self.context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)}
        return returnResult
    }
    
    // MARK: PRODUCTS
    
    func getProducts()-> [Product]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnProducts: [Product] = []
        let urlProducts = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvProducts.php"
        if let productsURL = URL(string: urlProducts) {
            if let data = getData(url: productsURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let products = try JSONDecoder().decode([ProductJSON].self, from: inputJSON!)
                    if products.count != 0 {
                        let deletedProducts = deleteProductsFromCoreData(context: self.context)
                        if deletedProducts.count == -1 {
                            showMessage(title: "Ошибка", message: deletedProducts.error)
                            return nil
                        }
                        let addedProducts = addProductsToCoreData(products: products, context: self.context)
                        if addedProducts.count == -1 {
                            showMessage(title: "Ошибка", message: addedProducts.error)
                            return nil
                        }
                    }
                } catch let jsonError {
                    showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    print(jsonError)
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnProducts = results
        } catch let error as NSError {
            showMessage(title: "Ошибка", message: error.localizedDescription)
        }
        return returnProducts
    }
    
    func deleteProductsFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                self.context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
}
        do {
            try self.context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    func addProductsToCoreData(products: [ProductJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var productCurrent: Product!
        for product in products {
            productCurrent = Product(context: self.context)
            // присваиваем переданные свойства
            productCurrent.id = Int32(product.id) ?? 0
            productCurrent.name = product.name
            productCurrent.thumbnailPath = product.thumbnail
            //productCurrent.order = Int32(product.order) ?? 0
            let categoryId = Int32(product.categoryId) ?? 0
            productCurrent.category = self.categories.filter({$0.id == categoryId}).first
            returnResult.count += returnResult.count
            
        }
        do {
            try self.context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
}




    

