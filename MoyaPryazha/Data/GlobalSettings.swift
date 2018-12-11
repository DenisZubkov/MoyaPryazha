//
//  GlobalConstants.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 14/09/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
// 

import Foundation
import UIKit

class GlobalSettings {
    let moyaPryazhaSite = "https://moya-pryazha.ru/"
    let moyaPryazhaServicesPath = "services/"
    let moyaPryazhaInstagramApp = "instagram://moya-pryazha"
    let moyaPryazhaFacebookApp = "fb://moyapryazha.ru"
    let moyaPryazhaTwitterApp = "twitter://MPryazha"
    let moyaPryazhaInstagramSite = "https://www.instagram.com/moya_pryazha"
    let moyaPryazhaFacebookSite = "https://www.facebook.com/moyapryazha.ru/"
    let moyaPryazhaTwitterSite = "https://twitter.com/MPryazha"
    let moyaPryazhaPhone = "tel://+7(985)466-28-82"
    let moyaPryazhaAddress = "141207, Московская область, г.Пушкино, Московский проспект, д.17, 3 этаж"
    let moyaPryazhaEmail = "info@moya-pryazha.ru"
    let gpsX: Double = 56.009824
    let gpsY: Double = 37.850811
    let modelSources: [DataType : String ] =
        [.lastModified : "srvLastModified.php",
         .category : "srvCategories.php",
         .product : "srvProducts.php",
         .currency : "srvCurrencies.php",
         .price : "srvPrices.php",
         .parameter : "srvParameters.php",
         .productParameter : "srvProductParameters.php",
         .productPicture: "srvProductPictures.php",
         .hit : "srvHits.php" ]
}
