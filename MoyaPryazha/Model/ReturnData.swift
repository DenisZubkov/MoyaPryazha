//
//  ReturnError.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 29/10/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct ReturnData {
    
    var dataType: DataType
    var errorType: ErrorType
    var description: String
    var data: Data?
}

enum DataType: String{
    case lastModified = "Дата изменения"
    case category = "Категории товаров"
    case product = "Товары"
    case currency = "Валюта цены"
    case price = "Цена товара"
    case parameter = "Параметры"
    case productParameter = "Параметры товаров"
    case productPicture = "Изображения товаров"
    case hit = "Хит продаж"
}

enum ErrorType: String {
    case network = "Ошибка сети"
    case json = "Ошибка данных"
    case empty = "Нет данных"
    case none = "Ок"
    case timeout = "Сервер не отвечает..."
}
