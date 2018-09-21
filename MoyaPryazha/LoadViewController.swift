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
    var error = true
    var categories: [Category] = []
    var products: [Product] = []
    var currencies: [Currency] = []
    var priceTypes: [PriceType] = []
    var prices: [Price] = []
    var parameters: [Parameter] = []
    var productParameters: [ProductParameter] = []
    var hits: [Hit] = []
    var productPictures: [ProductPicture] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //error = loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if error {
            error = loadData()
        }
        performSegue(withIdentifier: "ToMainSegue", sender: nil)
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
        
        loadProgressView.progress = 0.125
        guard let categories = getCategories() else { return true }
        self.categories = categories
        print(self.categories.count)
        
        // Products array
        
        loadProgressView.progress = 0.25
        guard let products = getProducts() else { return true }
        self.products = products
        print(self.products.count)
        
        // Currencies array
        
        loadProgressView.progress = 0.375
        guard let currencies = getCurrencies() else { return true }
        self.currencies = currencies
        print(self.currencies.count)
        
        // Prices array
        
        loadProgressView.progress = 0.5
        guard let priceTypes = getPriceTypes() else { return true }
        self.priceTypes = priceTypes
        print(self.priceTypes.count)
        guard let prices = getPrices() else { return true }
        self.prices = prices
        print(self.prices.count)
        
        
        // Parameters array
        
        
        loadProgressView.progress = 0.625
        guard let parameters = getParameters() else { return true }
        self.parameters = parameters
        print(self.parameters.count)
        
        // Product parameters array
        
        loadProgressView.progress = 0.750
        guard let productParameters = getProductParameters() else { return true }
        self.productParameters = productParameters
        print(self.productParameters.count)

        // Hits array
        
        loadProgressView.progress = 0.875
        guard let hits = getHits() else { return true }
        self.hits = hits
        print(self.hits.count)

        // Product pictures array
        
        loadProgressView.progress = 1
        guard let productPictures = getProductPictures() else { return true }
        self.productPictures = productPictures
        print(self.productPictures.count)
        return false
        
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
                let alertData = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertData.addAction(cancelAction)
                self.present(alertData, animated: true, completion: nil)
//                DispatchQueue.main.async {
//                    self.showMessage(title: title, message: message)
//                }
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
        present(alertData, animated: true, completion: nil)
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
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: deletedCategories.error)
                            }
                            return nil
                        }
                        let addedCategories = addCategoriesToCoreData(categories: categories, context: self.context)
                        if addedCategories.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: addedCategories.error)
                            }
                            return nil
                        }
                    }
                } catch let jsonError {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    }
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnCategories = results
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
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
            var categoryName: String? = category.name
            categoryName = categoryName?.components(separatedBy: "ВЫБЕРИТЕ ПОДКАТЕГОРИЮ").first
            categoryCurrent.name = categoryName ?? category.name
            categoryCurrent.picturePath = category.picture
            categoryCurrent.thumbnailPath = category.thumbnail
            categoryCurrent.parentId = Int32(category.parentId) ?? 0
            categoryCurrent.order = Int32(category.order) ?? 0
            categoryCurrent.slug = category.slug
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
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: deletedProducts.error)
                            }
                            return nil
                        }
                        let addedProducts = addProductsToCoreData(products: products, context: self.context)
                        if addedProducts.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: addedProducts.error)
                            }
                            return nil
                        }
                    }
                } catch let jsonError {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    }
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
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
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
            productCurrent.slug = product.slug
            productCurrent.name = product.name
            productCurrent.thumbnailPath = product.thumbnail
            productCurrent.order = Int32(product.ordered) ?? 0
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
    
    
    // MARK: CURRENCY
    
    func getCurrencies()-> [Currency]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnCurrencies: [Currency] = []
        let urlCurrencies = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvCurrencies.php"
        if let currenciesURL = URL(string: urlCurrencies) {
            if let data = getData(url: currenciesURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let currencies = try JSONDecoder().decode([CurrencyJSON].self, from: inputJSON!)
                    if currencies.count != 0 {
                        let deletedCurrencies = deleteCurrenciesFromCoreData(context: self.context)
                        if deletedCurrencies.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: deletedCurrencies.error)
                            }
                            return nil
                        }
                        let addedCurrencies = addCurrenciesToCoreData(currencies: currencies, context: self.context)
                        if addedCurrencies.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: addedCurrencies.error)
                            }
                            return nil
                        }
                    }
                } catch let jsonError {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    }
                    print(jsonError)
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnCurrencies = results
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
        }
        return returnCurrencies
    }
    
    func deleteCurrenciesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
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
    
    func addCurrenciesToCoreData(currencies: [CurrencyJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var currencyCurrent: Currency!
        for currency in currencies {
            currencyCurrent = Currency(context: self.context)
            // присваиваем переданные свойства
            currencyCurrent.id = Int32(currency.id) ?? 0
            currencyCurrent.name = currency.name
            currencyCurrent.code = currency.code
            currencyCurrent.numericCode = Int32(currency.numericCode) ?? 0
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
    
    // MARK: PRICETYPE
    
    func getPriceTypes()-> [PriceType]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnPriceTypes: [PriceType] = []
        let fetchRequest: NSFetchRequest<PriceType> = PriceType.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnPriceTypes = results
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
        }
        if returnPriceTypes.count == 0 {
            returnPriceTypes.append(PriceType(context: self.context))
            returnPriceTypes.first?.id = Int32("1") ?? 1
            returnPriceTypes.first?.name = "Основной"
        }
        do {
            try self.context.save()
        } catch let error as NSError {
            print(error.description)
        }
        return returnPriceTypes
    }
    
   
    // MARK: PRICE

    func getPrices()-> [Price]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnPrices: [Price] = []
        let urlPrices = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvPrices.php"
        if let pricesURL = URL(string: urlPrices) {
            if let data = getData(url: pricesURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let prices = try JSONDecoder().decode([PriceJSON].self, from: inputJSON!)
                    if prices.count != 0 {
                        let deletedPrices = deletePricesFromCoreData(context: self.context)
                        if deletedPrices.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: deletedPrices.error)
                            }
                            return nil
                        }
                        let addedPrices = addPricesToCoreData(prices: prices, context: self.context)
                        if addedPrices.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: addedPrices.error)
                            }
                            return nil
                        }
                    }
                } catch let jsonError {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    }
                    print(jsonError)
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<Price> = Price.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnPrices = results
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
        }
        return returnPrices
    }

    func deletePricesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Price> = Price.fetchRequest()
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

    func addPricesToCoreData(prices: [PriceJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var priceCurrent: Price!
        for price in prices {
            priceCurrent = Price(context: self.context)
            // присваиваем переданные свойства
            priceCurrent.id = Int32(price.id) ?? 0
            priceCurrent.price = Float(price.price) ?? 0
            let productId = Int32(price.productId) ?? 0
            priceCurrent.product = self.products.filter({$0.id == productId}).first
            priceCurrent.priceType = self.priceTypes.filter({$0.id == 1}).first
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
    
    // MARK: PARAMETER

    func getParameters()-> [Parameter]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnParameters: [Parameter] = []
        let urlParameters = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvParameters.php"
        if let parametersURL = URL(string: urlParameters) {
            if let data = getData(url: parametersURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let parameters = try JSONDecoder().decode([ParameterJSON].self, from: inputJSON!)
                    if parameters.count != 0 {
                        let deletedParameters = deleteParametersFromCoreData(context: self.context)
                        if deletedParameters.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: deletedParameters.error)
                            }
                            return nil
                        }
                        let addedParameters = addParametersToCoreData(parameters: parameters, context: self.context)
                        if addedParameters.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: addedParameters.error)
                            }
                            return nil
                        }
                    }
                } catch let jsonError {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    }
                    print(jsonError)
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<Parameter> = Parameter.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnParameters = results
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
        }
        return returnParameters
    }

    func deleteParametersFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Parameter> = Parameter.fetchRequest()
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

    func addParametersToCoreData(parameters: [ParameterJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var parameterCurrent: Parameter!
        for parameter in parameters {
            parameterCurrent = Parameter(context: self.context)
            // присваиваем переданные свойства
            parameterCurrent.id = Int32(parameter.id) ?? 0
            parameterCurrent.name = parameter.title
            parameterCurrent.order = Int32(parameter.id) ?? 0
            parameterCurrent.tip = parameter.tip
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
    
    // MARK: PRODUCTPARAMETER

    func getProductParameters()-> [ProductParameter]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnProductParameters: [ProductParameter] = []
        let urlProductParameters = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvProductParameters.php"
        if let productParametersURL = URL(string: urlProductParameters) {
            if let data = getData(url: productParametersURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let productParameters = try JSONDecoder().decode([ProductParameterJSON].self, from: inputJSON!)
                    if productParameters.count != 0 {
                        let deletedProductParameters = deleteProductParametersFromCoreData(context: self.context)
                        if deletedProductParameters.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: deletedProductParameters.error)
                            }
                            return nil
                        }
                        let addedProductParameters = addProductParametersToCoreData(productParameters: productParameters, context: self.context)
                        if addedProductParameters.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: addedProductParameters.error)
                            }
                            return nil
                        }
                    }
                } catch let jsonError {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    }
                    print(jsonError)
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<ProductParameter> = ProductParameter.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnProductParameters = results
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
        }
        return returnProductParameters
    }

    func deleteProductParametersFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<ProductParameter> = ProductParameter.fetchRequest()
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

    func addProductParametersToCoreData(productParameters: [ProductParameterJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var productParameterCurrent: ProductParameter!
        for productParameter in productParameters {
            productParameterCurrent = ProductParameter(context: self.context)
            // присваиваем переданные свойства
            productParameterCurrent.id = Int32(productParameter.id) ?? 0
            productParameterCurrent.value = productParameter.value
            let productId = Int32(productParameter.productId) ?? 0
            productParameterCurrent.product = self.products.filter({$0.id == productId}).first
            let parameterId = Int32(productParameter.parameterId) ?? 0
            productParameterCurrent.parameter = self.parameters.filter({$0.id == parameterId}).first
            
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
    
    // MARK: HIT

    func getHits()-> [Hit]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnHits: [Hit] = []
        let urlHits = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvHits.php"
        if let hitsURL = URL(string: urlHits) {
            if let data = getData(url: hitsURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let hits = try JSONDecoder().decode([HitJSON].self, from: inputJSON!)
                    if hits.count != 0 {
                        let deletedHits = deleteHitsFromCoreData(context: self.context)
                        if deletedHits.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: deletedHits.error)
                            }
                            return nil
                        }
                        let addedHits = addHitsToCoreData(hits: hits, context: self.context)
                        if addedHits.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: addedHits.error)
                            }
                            return nil
                        }
                    }
                } catch let jsonError {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    }
                    print(jsonError)
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<Hit> = Hit.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnHits = results
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
        }
        return returnHits
    }

    func deleteHitsFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Hit> = Hit.fetchRequest()
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

    func addHitsToCoreData(hits: [HitJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var hitCurrent: Hit!
        for hit in hits {
            hitCurrent = Hit(context: self.context)
            // присваиваем переданные свойства
            hitCurrent.order = Int32(hit.ordered) ?? 0
            let productId = Int32(hit.productId) ?? 0
            hitCurrent.product = self.products.filter({$0.id == productId}).first

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
    
    // MARK: PRODUCTPICTURE

    func getProductPictures()-> [ProductPicture]? {
        context = coreDataStack.persistentContainer.viewContext
        var returnProductPictures: [ProductPicture] = []
        let urlProductPictures = globalConstants.moyaPryazhaSite + globalConstants.moyaPryazhaServicesPath + "srvProductPictures.php"
        if let productPicturesURL = URL(string: urlProductPictures) {
            if let data = getData(url: productPicturesURL) {
                let returnData = String(data: data, encoding: .utf8)
                let inputJSON = returnData?.data(using: .utf8)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                do {
                    let productPictures = try JSONDecoder().decode([ProductPictureJSON].self, from: inputJSON!)
                    if productPictures.count != 0 {
                        let deletedProductPictures = deleteProductPicturesFromCoreData(context: self.context)
                        if deletedProductPictures.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: deletedProductPictures.error)
                            }
                            return nil
                        }
                        let addedProductPictures = addProductPicturesToCoreData(productPictures: productPictures, context: self.context)
                        if addedProductPictures.count == -1 {
                            DispatchQueue.main.async {
                                self.showMessage(title: "Ошибка", message: addedProductPictures.error)
                            }
                            return nil
                        }
                    }
                } catch let jsonError {
                    DispatchQueue.main.async {
                        self.showMessage(title: "Ошибка", message: jsonError.localizedDescription)
                    }
                    print(jsonError)
                    return nil
                }
            }
        }
        let fetchRequest: NSFetchRequest<ProductPicture> = ProductPicture.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            returnProductPictures = results
        } catch let error as NSError {
            DispatchQueue.main.async {
                self.showMessage(title: "Ошибка", message: error.localizedDescription)
            }
        }
        return returnProductPictures
    }

    func deleteProductPicturesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<ProductPicture> = ProductPicture.fetchRequest()
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

    func addProductPicturesToCoreData(productPictures: [ProductPictureJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var productPictureCurrent: ProductPicture!
        for productPicture in productPictures {
            productPictureCurrent = ProductPicture(context: self.context)
            // присваиваем переданные свойства
            productPictureCurrent.id = Int32(productPicture.id) ?? 0
            productPictureCurrent.order = Int32(productPicture.ordered) ?? 0
            productPictureCurrent.path = productPicture.path
            let productId = Int32(productPicture.productId) ?? 0
            productPictureCurrent.product = self.products.filter({$0.id == productId}).first
            
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




    

