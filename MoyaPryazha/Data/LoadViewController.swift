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

    @IBOutlet weak var loadActivity: UIActivityIndicatorView!
    
    var lastModifiedDate = Date()
    let globalSettings = GlobalSettings()
    let coreDataStack = CoreDataStack()
    var context: NSManagedObjectContext!
    var error = true
    var categories: [Category] = []
    var products: [Product] = []
    var currencies: [Currency] = []
    var priceTypes: [PriceType] = []
    var prices: [Price] = []
    var baskets: [ProductBasket] = []
    var parameters: [Parameter] = []
    var user: User?
    var userAddresses: [UserAddress] = []
    var productParameters: [ProductParameter] = []
    var hits: [Hit] = []
    var productPictures: [ProductPicture] = []
    var resultsCoreData: [ReturnResult] = []
    var resultsServer: [ReturnData] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadActivity.isHidden = false
        loadActivity.startAnimating()
        let lastModifiedDateFromMemory = UserDefaults.standard.value(forKey: "LastModified") as? Date
        context = coreDataStack.persistentContainer.viewContext
        let _ = loadBasketsFromCoreData(context: context)
        if lastModifiedDateFromMemory == nil {
            parceFile()
        }
        resultsServer = loadDataFromServer()
            var lastModifiedDateFromServer: Date?
            let dataLastModifiedDate = resultsServer.filter{$0.dataType == .lastModified}
            if let data = dataLastModifiedDate.first?.data {
                lastModifiedDateFromServer = parceLastModifiedDate(data: data)
            }
            if lastModifiedDateFromMemory == nil {
                parceJSON()
                UserDefaults.standard.set(lastModifiedDateFromServer, forKey: "LastModified")
            } else {
                if let lastModifiedDateFromServer = lastModifiedDateFromServer {
                    if lastModifiedDateFromMemory! < lastModifiedDateFromServer {
                        parceJSON()
                        UserDefaults.standard.set(lastModifiedDateFromServer, forKey: "LastModified")
                    } else {
                        resultsCoreData = loadDataFromCoreData()
                    }
                } else {
                    resultsCoreData = loadDataFromCoreData()
                }
            }
            //        for result in resultsCoreData {
            //            print("ResultCoreData: \(result.count) \(result.error)")
            //        }
            //        for result in resultsServer {
            //            print("ResultServer: \(result.dataType) \(result.errorType.rawValue) \(result.description) \(result.data?.count ?? -1)")
            //        }
            loadActivity.isHidden = true
            loadActivity.stopAnimating()
        
        performSegue(withIdentifier: "ToMainSegue", sender: nil)
    }
    
    // MARG: FIRSTLOAD
    
    func loadFromFile(fileName: String, fileExtenition: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: fileExtenition) {
            let fileManager = FileManager()
            let exists = fileManager.fileExists(atPath: path)
            if(exists){
                let content = fileManager.contents(atPath: path)
                return content
            }
        }
        return nil
    }
    
    func parceFile() {
        context = coreDataStack.persistentContainer.viewContext
        if let data = loadFromFile(fileName: "Categories", fileExtenition: "json") {
            let _ = parceCategories(from: data, to: context)
        }
        let _ = loadCategoriesFromCoreData(context: context)
        //print("Category File: \(loadResult.count) \(loadResult.error)")
        
        if let data = loadFromFile(fileName: "Products", fileExtenition: "json") {
            let _ = parceProducts(from: data, to: context)
            
        }
        let _ = loadProductsFromCoreData(context: context)
        //print("Product File: \(loadResult.count) \(loadResult.error)")
        
       if let data = loadFromFile(fileName: "Currencies", fileExtenition: "json") {
            let _ = parceCurrencies(from: data, to: context)
        }
        let _ = loadCurrenciesFromCoreData(context: context)
        //print("Currency File: \(loadResult.count) \(loadResult.error)")
        
        let _ = parcePriceType(to: context)
        let _ = loadPriceTypesFromCoreData(context: context)
        //print("PriceType File: \(loadResult.count) \(loadResult.error)")
        
        if let data = loadFromFile(fileName: "Prices", fileExtenition: "json") {
            let _ = parcePrices(from: data, to: context)
        }
        let _ = loadPricesFromCoreData(context: context)
        //print("Prices File: \(loadResult.count) \(loadResult.error)")
        
        if let data = loadFromFile(fileName: "Parameters", fileExtenition: "json") {
            let _ = parceParameters(from: data, to: context)
        }
        let _ = loadParametersFromCoreData(context: context)
        //print("Parameters File: \(loadResult.count) \(loadResult.error)")
        
        if let data = loadFromFile(fileName: "ProductParameters", fileExtenition: "json") {
            let _ = parceProductParameters(from: data, to: context)
        }
        let _ = loadProductParametersFromCoreData(context: context)
        //print("Product Parameters File: \(loadResult.count) \(loadResult.error)")
        
        if let data = loadFromFile(fileName: "Hits", fileExtenition: "json") {
            let _ = parceHits(from: data, to: context)
        }
        let _ = loadHitsFromCoreData(context: context)
        //print("Hits File: \(loadResult.count) \(loadResult.error)")
        
        if let data = loadFromFile(fileName: "ProductPictures", fileExtenition: "json") {
            let _ = parceProductPictures(from: data, to: context)
        }
        let _ = loadProductPicturesFromCoreData(context: context)
        //print("Product Pictures File: \(loadResult.count) \(loadResult.error)")
        
        if let data = loadFromFile(fileName: "LastModified", fileExtenition: "json") {
            let date = parceLastModifiedDate( data: data)
            UserDefaults.standard.set(date, forKey: "LastModified")
        }
        let _ = loadProductsFromCoreData(context: context)
        //UserDefaults.standard.set(loadResult, forKey: "LoadResult")
        let _ = loadUserFromCoreData(context: context)
        let _ = loadUserAddressFromCoreData(context: context)

    }
    
    // MARK: LOADMODEL
    
    func loadDataFromCoreData() -> [ReturnResult] {
        var results: [ReturnResult] = []
        context = coreDataStack.persistentContainer.viewContext
        results.append(loadCategoriesFromCoreData(context: context))
        results.append(loadProductsFromCoreData(context: context))
        results.append(loadCurrenciesFromCoreData(context: context))
        results.append(loadPriceTypesFromCoreData(context: context))
        results.append(loadPricesFromCoreData(context: context))
        results.append(loadParametersFromCoreData(context: context))
        results.append(loadProductParametersFromCoreData(context: context))
        results.append(loadHitsFromCoreData(context: context))
        results.append(loadProductPicturesFromCoreData(context: context))
        return results
    }
    
    func loadDataFromServer() -> [ReturnData] {
        var results: [ReturnData] = []
        for source in globalSettings.modelSources {
            var result = ReturnData.init(dataType: source.key, errorType: .network, description: "Некорректный URL-адрес", data: nil)
            let urlSource = globalSettings.moyaPryazhaSite + globalSettings.moyaPryazhaServicesPath + source.value
            if let url = URL(string: urlSource) {
                result = getData(url: url, dataType: source.key)
            }
            results.append(result)
        }
        var resultServer = results.filter{($0.data?.count ?? 0 == 0 || $0.errorType != .none)}
        if resultServer.count > 0 {
            loadActivity.isHidden = true
            loadActivity.stopAnimating()
            let alertData = UIAlertController(title: resultServer.first?.errorType.rawValue, message: "\(resultServer.first?.description ?? "") \n Попробуйте позже", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Повторить", style: .default)
            {
                (action: UIAlertAction) -> Void in
                self.loadActivity.isHidden = false
                self.loadActivity.startAnimating()
                results = self.loadDataFromServer()
                resultServer = results.filter{($0.data?.count ?? 0 == 0 || $0.errorType != .none)}
                if resultServer.count == 0 {
                    self.performSegue(withIdentifier: "ToMainSegue", sender: nil)
                }
            }
            alertData.addAction(cancelAction)
            self.present(alertData, animated: true, completion: nil)
        }

        return results
    }
    
    
    func parceJSON() {
        context = coreDataStack.persistentContainer.viewContext
        
        var result = resultsServer.filter{$0.dataType == .category}
        if let data = result.first?.data {
            let _ = parceCategories(from: data, to: context)
        }
        let _ = loadCategoriesFromCoreData(context: context)
        //print("Category CoreData: \(loadResult.count) \(loadResult.error)")
        
        result = resultsServer.filter{$0.dataType == .product}
        if let data = result.first?.data {
            let _ = parceProducts(from: data, to: context)
            
        }
        let _ = loadProductsFromCoreData(context: context)
        //print("Product CoreData: \(loadResult.count) \(loadResult.error)")
        
        result = resultsServer.filter{$0.dataType == .currency}
        if let data = result.first?.data {
            let _ = parceCurrencies(from: data, to: context)
        }
        let _ = loadCurrenciesFromCoreData(context: context)
        //print("Currency CoreData: \(loadResult.count) \(loadResult.error)")
        
        let _ = parcePriceType(to: context)
        let _ = loadPriceTypesFromCoreData(context: context)
        //print("PriceType CoreData: \(loadResult.count) \(loadResult.error)")
        
        result = resultsServer.filter{$0.dataType == .price}
        if let data = result.first?.data {
            let _ = parcePrices(from: data, to: context)
        }
        let _ = loadPricesFromCoreData(context: context)
        //print("Prices CoreData: \(loadResult.count) \(loadResult.error)")
        
        result = resultsServer.filter{$0.dataType == .parameter}
        if let data = result.first?.data {
            let _ = parceParameters(from: data, to: context)
        }
        let _ = loadParametersFromCoreData(context: context)
        //print("Parameters CoreData: \(loadResult.count) \(loadResult.error)")
        
        result = resultsServer.filter{$0.dataType == .productParameter}
        if let data = result.first?.data {
            let _ = parceProductParameters(from: data, to: context)
        }
        let _ = loadProductParametersFromCoreData(context: context)
        //print("Product Parameters CoreData: \(loadResult.count) \(loadResult.error)")
        
        result = resultsServer.filter{$0.dataType == .hit}
        if let data = result.first?.data {
            let _ = parceHits(from: data, to: context)
        }
        let _ = loadHitsFromCoreData(context: context)
        //print("Hits CoreData: \(loadResult.count) \(loadResult.error)")
        
        result = resultsServer.filter{$0.dataType == .productPicture}
        if let data = result.first?.data {
            let _ = parceProductPictures(from: data, to: context)
        }
        let _ = loadProductPicturesFromCoreData(context: context)
        //print("Product Pictures CoreData: \(loadResult.count) \(loadResult.error)")
        
    }
    
    func getData(url: URL, dataType: DataType) -> ReturnData {
        var returnData = ReturnData.init(dataType: dataType, errorType: .none, description: "", data: nil)
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 15)
        var isLoad = false
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                returnData.description = error?.localizedDescription ?? "Ошибка сервера"
                returnData.errorType = .network
            } else if data == nil {
                returnData.description = "Не удалось получить данные"
                returnData.errorType = .empty
            } else if (data?.isEmpty)! {
                returnData.description = "Данные отсутствуют"
                returnData.errorType = .empty
            } else if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    returnData.description = "\(response.statusCode)  \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode)) "
                    returnData.errorType = .network
                }
            } else {
                returnData.description = "Нет ответа от сервера"
                returnData.errorType = .network
            }
            returnData.data = data
            isLoad = true
        }
        dataTask.resume()
        while dataTask.state != .completed {
        }
        while isLoad != true {
        }
        return returnData
    }
    
    
    func showMessage(title: String, message: String) {
        let alertData = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertData.addAction(cancelAction)
        present(alertData, animated: true, completion: nil)
    }
    
    func repeatMessage(title: String, message: String) {
        let alertData = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Повторить", style: .default, handler: nil)
        alertData.addAction(cancelAction)
        present(alertData, animated: true, completion: nil)
    }
    
    // MARK: MODIFIEDDATE
    
    func parceLastModifiedDate( data: Data) -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        do {
            let lastModifieds = try JSONDecoder().decode([LastModified].self, from: data)
            if let date = lastModifieds.first?.modifyDate {
                let currentDate = dateformatter.date(from: date)
                return currentDate
            }
        } catch {
        }
        return nil
        
    }
    
    
    
    
    // MARK: CATEGORIES
    
    func parceCategories(from data: Data, to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let returnData = String(data: data, encoding: .utf8)
        let inputJSON = returnData?.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let categories = try JSONDecoder().decode([CategoryJSON].self, from: inputJSON!)
            if categories.count != 0 {
                returnResult = addCategoriesToCoreData(categories: categories, context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка JSON категорий: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func loadCategoriesFromCoreData(context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "noShow == FALSE")
        // извлекаем из контекста
        do {
            categories = try context.fetch(fetchRequest)
            returnResult.count = categories.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения категорий: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func addCategoriesToCoreData(categories: [CategoryJSON], context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var categoryCurrent: Category!
        
        // Извлекаем существующие Категории из CoreData
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        var categoriesCoreData: [Category] = []
        do {
            let results = try context.fetch(fetchRequest)
            // все сущестующие категории делаем невидимыми
            for result in results {
                result.noShow = false
            }
            categoriesCoreData = results
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения категорий: \(error.localizedDescription)"
            returnResult.count = -1
        }
        
        // добавление новых категорий, изменение существующих
        for category in categories {
            // проверяем наличие категории из JSON
            if let categoryId = Int32(category.id),
                let isCoreData = categoriesCoreData.filter({$0.id == categoryId}).first {
                //если есть категория то меняем ее
                categoryCurrent = isCoreData
            } else {
                // если нет категории создаем новую
                categoryCurrent = Category(context: context)
            }
            
            // присваиваем переданные свойства
            categoryCurrent.id = Int32(category.id) ?? 0
            var categoryName: String? = category.name
            categoryName = categoryName?.components(separatedBy: " ВЫБЕРИТЕ ПОДКАТЕГОРИЮ").first
            categoryCurrent.name = categoryName ?? category.name
            categoryCurrent.picturePath = category.picture
            categoryCurrent.thumbnailPath = category.thumbnail
            categoryCurrent.parentId = Int32(category.parentId) ?? 0
            categoryCurrent.order = Int32(category.order) ?? 0
            categoryCurrent.slug = category.slug
            categoryCurrent.noShow = category.noShow == "1" ? false : true
            returnResult.count += returnResult.count
            
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения категорий: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)}
        return returnResult
    }
    
    // MARK: PRODUCTS
    
    func parceProducts(from data: Data, to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let returnData = String(data: data, encoding: .utf8)
        let inputJSON = returnData?.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let products = try JSONDecoder().decode([ProductJSON].self, from: inputJSON!)
            if products.count != 0 {
                returnResult = addProductsToCoreData(products: products, context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка JSON товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func loadProductsFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "noShow == FALSE")
        // извлекаем из контекста
        do {
            products = try context.fetch(fetchRequest)
            returnResult.count = products.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func deleteProductsFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
}
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    func addProductsToCoreData(products: [ProductJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var productCurrent: Product!
        
        // Извлекаем существующие Категории из CoreData
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        var productsCoreData: [Product] = []
        do {
            
            let results = try context.fetch(fetchRequest)
            // все сущестующие категории делаем невидимыми
            for result in results {
                result.noShow = true
            }
            productsCoreData = results
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        
        // добавление новых категорий, изменение существующих
        for product in products {
            // проверяем наличие категории из JSON
            if let productId = Int32(product.id),
                let isCoreData = productsCoreData.filter({$0.id == productId}).first {
                //если есть категория то меняем ее
                productCurrent = isCoreData
            } else {
                // если нет категории создаем новую
                productCurrent = Product(context: context)
            }
            
            // присваиваем переданные свойства
            productCurrent.id = Int32(product.id) ?? 0
            productCurrent.slug = product.slug
            productCurrent.name = product.name
            productCurrent.thumbnailPath = product.thumbnail
            productCurrent.order = Int32(product.ordered) ?? 0
            let categoryId = Int32(product.categoryId) ?? 0
            productCurrent.category = self.categories.filter({$0.id == categoryId}).first
            productCurrent.noShow = product.noShow == "1" ? false : true
            returnResult.count += returnResult.count
            
            
            
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    
    // MARK: CURRENCY
    
    func parceCurrencies(from data: Data, to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let returnData = String(data: data, encoding: .utf8)
        let inputJSON = returnData?.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let currencies = try JSONDecoder().decode([CurrencyJSON].self, from: inputJSON!)
            if currencies.count != 0 {
                returnResult = deleteCurrenciesFromCoreData(context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
                returnResult = addCurrenciesToCoreData(currencies: currencies, context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка JSON товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }

    
    func loadCurrenciesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
        // извлекаем из контекста
        do {
            currencies = try context.fetch(fetchRequest)
            returnResult.count = currencies.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения валют: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func deleteCurrenciesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Currency> = Currency.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления валют: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления валют: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    func addCurrenciesToCoreData(currencies: [CurrencyJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var currencyCurrent: Currency!
        for currency in currencies {
            currencyCurrent = Currency(context: context)
            // присваиваем переданные свойства
            currencyCurrent.id = Int32(currency.id) ?? 0
            currencyCurrent.name = currency.name
            currencyCurrent.code = currency.code
            currencyCurrent.numericCode = Int32(currency.numericCode) ?? 0
            returnResult.count += returnResult.count
            
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения валют: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    // MARK: PRICETYPE
    
    func parcePriceType(to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<PriceType> = PriceType.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            priceTypes = results
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения типа цены: \(error.localizedDescription)"
            returnResult.count = -1
        }
        if priceTypes.count == 0 {
            priceTypes.append(PriceType(context: context))
            priceTypes.first?.id = Int32("1") ?? 1
            priceTypes.first?.name = "Основной"
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения типа цены: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func loadPriceTypesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<PriceType> = PriceType.fetchRequest()
        // извлекаем из контекста
        do {
            priceTypes = try context.fetch(fetchRequest)
            returnResult.count = priceTypes.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения типа цен: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
   
    // MARK: PRICE

    
    func parcePrices(from data: Data, to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let returnData = String(data: data, encoding: .utf8)
        let inputJSON = returnData?.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let prices = try JSONDecoder().decode([PriceJSON].self, from: inputJSON!)
            if prices.count != 0 {
                returnResult = deletePricesFromCoreData(context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
                returnResult = addPricesToCoreData(prices: prices, context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка JSON цен: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    
    func loadPricesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Price> = Price.fetchRequest()
        // извлекаем из контекста
        do {
            prices = try context.fetch(fetchRequest)
            returnResult.count = prices.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения цен: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func deletePricesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Price> = Price.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления цен: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления цен: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }

    func addPricesToCoreData(prices: [PriceJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var priceCurrent: Price!
        for price in prices {
            priceCurrent = Price(context: context)
            // присваиваем переданные свойства
            priceCurrent.id = Int32(price.id) ?? 0
            priceCurrent.price = Float(price.price) ?? 0
            let productId = Int32(price.productId) ?? 0
            priceCurrent.product = self.products.filter({$0.id == productId}).first
            priceCurrent.priceType = self.priceTypes.filter({$0.id == 1}).first
            returnResult.count += returnResult.count

        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения цен: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    // MARK: PARAMETER

    func parceParameters(from data: Data, to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let returnData = String(data: data, encoding: .utf8)
        let inputJSON = returnData?.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let parameters = try JSONDecoder().decode([ParameterJSON].self, from: inputJSON!)
            if parameters.count != 0 {
                returnResult = deleteParametersFromCoreData(context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
                returnResult = addParametersToCoreData(parameters: parameters, context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка JSON параметров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }

    func loadParametersFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Parameter> = Parameter.fetchRequest()
        // извлекаем из контекста
        do {
            parameters = try context.fetch(fetchRequest)
            returnResult.count = parameters.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    
    func deleteParametersFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Parameter> = Parameter.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        do {
            try context.save()
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
            parameterCurrent = Parameter(context: context)
            // присваиваем переданные свойства
            parameterCurrent.id = Int32(parameter.id) ?? 0
            parameterCurrent.name = parameter.title
            parameterCurrent.order = Int32(parameter.id) ?? 0
            parameterCurrent.tip = parameter.tip
            returnResult.count += returnResult.count

        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    // MARK: PRODUCTPARAMETER

    func parceProductParameters(from data: Data, to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let returnData = String(data: data, encoding: .utf8)
        let inputJSON = returnData?.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let productParameters = try JSONDecoder().decode([ProductParameterJSON].self, from: inputJSON!)
            if productParameters.count != 0 {
                returnResult = deleteProductParametersFromCoreData(context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
                returnResult = addProductParametersToCoreData(productParameters: productParameters, context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка JSON параметров товвров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func loadProductParametersFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<ProductParameter> = ProductParameter.fetchRequest()
        // извлекаем из контекста
        do {
            productParameters = try context.fetch(fetchRequest)
            returnResult.count = productParameters.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения параметров товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }

    func deleteProductParametersFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<ProductParameter> = ProductParameter.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления параметров товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления параметров товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }

    func addProductParametersToCoreData(productParameters: [ProductParameterJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var productParameterCurrent: ProductParameter!
        for productParameter in productParameters {
            productParameterCurrent = ProductParameter(context: context)
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
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения параметров товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    // MARK: HIT

    func parceHits(from data: Data, to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let returnData = String(data: data, encoding: .utf8)
        let inputJSON = returnData?.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let hits = try JSONDecoder().decode([HitJSON].self, from: inputJSON!)
            if hits.count != 0 {
                returnResult = deleteHitsFromCoreData(context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
                returnResult = addHitsToCoreData(hits: hits, context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка JSON хитов товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func loadHitsFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Hit> = Hit.fetchRequest()
        // извлекаем из контекста
        do {
            hits = try context.fetch(fetchRequest)
            returnResult.count = hits.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения хитов товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    
    func deleteHitsFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<Hit> = Hit.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления хитов товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления хитов товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }

    func addHitsToCoreData(hits: [HitJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var hitCurrent: Hit!
        for hit in hits {
            hitCurrent = Hit(context: context)
            // присваиваем переданные свойства
            hitCurrent.order = Int32(hit.ordered) ?? 0
            let productId = Int32(hit.productId) ?? 0
            hitCurrent.product = self.products.filter({$0.id == productId}).first

            returnResult.count += returnResult.count

        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    // MARK: PRODUCTPICTURE

    func parceProductPictures(from data: Data, to context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let returnData = String(data: data, encoding: .utf8)
        let inputJSON = returnData?.data(using: .utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let productPictures = try JSONDecoder().decode([ProductPictureJSON].self, from: inputJSON!)
            if productPictures.count != 0 {
                returnResult = deleteProductPicturesFromCoreData(context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
                returnResult = addProductPicturesToCoreData(productPictures: productPictures, context: context)
                if returnResult.count == -1 {
                    return returnResult
                }
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка JSON картинок товвров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func loadProductPicturesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<ProductPicture> = ProductPicture.fetchRequest()
        // извлекаем из контекста
        do {
            productPictures = try context.fetch(fetchRequest)
            returnResult.count = productPictures.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения картинок товаров: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }

    func deleteProductPicturesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<ProductPicture> = ProductPicture.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления картинок товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления картинок товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }

    func addProductPicturesToCoreData(productPictures: [ProductPictureJSON], context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        var productPictureCurrent: ProductPicture!
        for productPicture in productPictures {
            productPictureCurrent = ProductPicture(context: context)
            // присваиваем переданные свойства
            productPictureCurrent.id = Int32(productPicture.id) ?? 0
            productPictureCurrent.order = Int32(productPicture.ordered) ?? 0
            productPictureCurrent.path = productPicture.path
            let productId = Int32(productPicture.productId) ?? 0
            productPictureCurrent.product = self.products.filter({$0.id == productId}).first
            returnResult.count += returnResult.count

        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения категорий товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    //MARK: Basket
    
    func loadBasketsFromCoreData(context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<ProductBasket> = ProductBasket.fetchRequest()
        // извлекаем из контекста
        do {
            baskets = try context.fetch(fetchRequest)
            returnResult.count = baskets.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения корзины: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    
    func sumBasket() -> Int {
        let sum = baskets.reduce(0) { (total, basket) -> Int in
            guard let price = prices.filter({$0.product == basket.product && $0.priceType?.id ?? 1 == 1}).first?.price else { return 0 }
            return total + Int(basket.quantity) * Int(price)
        }
        return sum
    }
    
    
    func appendToBasket(product: Product, quantity: Int, context: NSManagedObjectContext) {
        guard let entity =  NSEntityDescription.entity(forEntityName: "ProductBasket", in: context) else { return }
        let basketNew = NSManagedObject(entity: entity, insertInto: context)
        basketNew.setValue(Int32(baskets.count), forKey: "order")
        basketNew.setValue(product, forKey: "product")
        basketNew.setValue(Int32(quantity), forKey: "quantity")
        baskets.append(basketNew as! ProductBasket)
    }
    
    func putProductToBasket(product: Product?, quantity: Int) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        if let product = product {
            if let basket = baskets.filter({$0.product == product}).first {
                basket.quantity = Int32(quantity)
                if basket.quantity == 0 {
                    for i in 0..<baskets.count {
                        if baskets[i].product == product {
                            baskets.remove(at: i)
                            break
                        }
                    }
                    context.delete(basket)
                }
            } else {
                appendToBasket(product: product, quantity: quantity, context: context)
            }
            do {
                try context.save()
                return returnResult
            } catch let error as NSError {
                returnResult.error = "Ошибка сохранения товара в корзину: \(error.localizedDescription)"
                returnResult.count = -1
                print(returnResult.error)
                return returnResult
                
            }
        } else {
            return returnResult
        }
    }
    
    //MARK: User
    
    func loadUserFromCoreData(context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        // извлекаем из контекста
        do {
            let users = try context.fetch(fetchRequest)
            if users.count == 0 {
                user = createUser()
            } else {
                user = users.first
            }
            returnResult.count = users.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения пользователя: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func createUser() -> User? {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        guard let entity =  NSEntityDescription.entity(forEntityName: "User", in: context) else { return nil }
        let userNew = NSManagedObject(entity: entity, insertInto: context)
        userNew.setValue(Int32(1), forKey: "id")
        userNew.setValue("", forKey: "name")
        userNew.setValue("", forKey: "phone")
        userNew.setValue("", forKey: "email")
        userNew.setValue(Int32(0), forKey: "delivery")
        userNew.setValue(Int32(0), forKey: "payment")
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения изменения пользователя: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        returnResult = appendToUserAddresses(user: userNew as? User, address: "")
        return userNew as? User
    }
    
    func updateUser(name: String, phone: String, email: String, delivery: Int, payment: Int) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        // извлекаем из контекста
        do {
            let users = try context.fetch(fetchRequest)
            if users.count == 0 {
                user = createUser()
            } else {
                user = users.first
            }
            returnResult.count = users.count
            user?.name = name
            user?.email = email
            user?.phone = phone
            user?.delivery = Int32(delivery)
            user?.payment = Int32(payment)
            
        } catch let error as NSError {
            returnResult.error = "Ошибка изменения пользователя: \(error.localizedDescription)"
            returnResult.count = -1
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения изменения пользователя: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    func deleteUsersFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления картинок товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления картинок товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }
    
    //MARK: UserAddress
    
    func loadUserAddressFromCoreData(context: NSManagedObjectContext) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<UserAddress> = UserAddress.fetchRequest()
        // извлекаем из контекста
        do {
            userAddresses = try context.fetch(fetchRequest)
            returnResult.count = userAddresses.count
        } catch let error as NSError {
            returnResult.error = "Ошибка извлечения пользователя: \(error.localizedDescription)"
            returnResult.count = -1
        }
        return returnResult
    }
    
    func appendToUserAddresses(user: User?, address: String) -> ReturnResult {
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let _ = deleteUserAddresssesFromCoreData(context: context)
        guard let entity =  NSEntityDescription.entity(forEntityName: "UserAddress", in: context) else { return returnResult}
        let userAddressNew = NSManagedObject(entity: entity, insertInto: context)
        userAddressNew.setValue(Int32(userAddresses.count), forKey: "id")
        userAddressNew.setValue(address, forKey: "address")
        userAddressNew.setValue(user, forKey: "user")
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения изменения пользователя: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        userAddresses.removeAll()
        userAddresses.append(userAddressNew as! UserAddress)
        return returnResult
    }
    
    func deleteUserAddresssesFromCoreData(context: NSManagedObjectContext) -> ReturnResult{
        var returnResult: ReturnResult = ReturnResult.init(count: 0, error: "Ok")
        let fetchRequest: NSFetchRequest<UserAddress> = UserAddress.fetchRequest()
        // извлекаем из контекста
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                returnResult.count += 1
                context.delete(result)
            }
        } catch let error as NSError {
            returnResult.error = "Ошибка удаления картинок товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        do {
            try context.save()
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения удаления картинок товаров: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
        }
        return returnResult
    }

    
}




    

