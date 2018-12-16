//
//  AddressDaData.swift
//  MoyaPryazha
//
//  Created by Denis Zubkov on 14/12/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import Foundation

struct AddressDaData: Codable {
    let suggestions: [Suggestion?]
}

struct Suggestion: Codable {
    let value, unrestrictedValue: String?
    let data: DataClass?
    
    enum CodingKeys: String, CodingKey {
        case value
        case unrestrictedValue = "unrestricted_value"
        case data
    }
}

struct DataClass: Codable {
    let postalCode: String?
//    let country, regionFiasID, regionKladrID, regionWithType: String?
//    let regionType, regionTypeFull, region: String?
//    let areaFiasID, areaKladrID, areaWithType, areaType: String?
//    let areaTypeFull, area: String?
//    let cityFiasID, cityKladrID, cityWithType, cityType: String?
//    let cityTypeFull, city: String?
//    let cityArea, cityDistrictFiasID, cityDistrictKladrID, cityDistrictWithType: String?
//    let cityDistrictType, cityDistrictTypeFull, cityDistrict, settlementFiasID: String?
//    let settlementKladrID, settlementWithType, settlementType, settlementTypeFull: String?
//    let settlement: String?
//    let streetFiasID, streetKladrID, streetWithType, streetType: String?
//    let streetTypeFull, street: String?
//    let houseFiasID, houseKladrID, houseType, houseTypeFull: String?
//    let house, blockType, blockTypeFull, block: String?
//    let flatType, flatTypeFull, flat, flatArea: String?
//    let squareMeterPrice, flatPrice, postalBox: String?
//    let fiasID: String?
//    let fiasCode: String?
//    let fiasLevel: String?
//    let fiasActualityState: String?
//    let kladrID: String?
//    let geonameID: String?
//    let capitalMarker, okato, oktmo, taxOffice: String?
//    let taxOfficeLegal: String?
//    let timezone, geoLat, geoLon, beltwayHit: String?
//    let beltwayDistance, metro, qcGeo, qcComplete: String?
//    let qcHouse: String?
//    let historyValues: [String?]
//    let unparsedParts, source, qc: String?
    
    enum CodingKeys: String, CodingKey {
        case postalCode = "postal_code"
//        case country
//        case regionFiasID = "region_fias_id"
//        case regionKladrID = "region_kladr_id"
//        case regionWithType = "region_with_type"
//        case regionType = "region_type"
//        case regionTypeFull = "region_type_full"
//        case region
//        case areaFiasID = "area_fias_id"
//        case areaKladrID = "area_kladr_id"
//        case areaWithType = "area_with_type"
//        case areaType = "area_type"
//        case areaTypeFull = "area_type_full"
//        case area
//        case cityFiasID = "city_fias_id"
//        case cityKladrID = "city_kladr_id"
//        case cityWithType = "city_with_type"
//        case cityType = "city_type"
//        case cityTypeFull = "city_type_full"
//        case city
//        case cityArea = "city_area"
//        case cityDistrictFiasID = "city_district_fias_id"
//        case cityDistrictKladrID = "city_district_kladr_id"
//        case cityDistrictWithType = "city_district_with_type"
//        case cityDistrictType = "city_district_type"
//        case cityDistrictTypeFull = "city_district_type_full"
//        case cityDistrict = "city_district"
//        case settlementFiasID = "settlement_fias_id"
//        case settlementKladrID = "settlement_kladr_id"
//        case settlementWithType = "settlement_with_type"
//        case settlementType = "settlement_type"
//        case settlementTypeFull = "settlement_type_full"
//        case settlement
//        case streetFiasID = "street_fias_id"
//        case streetKladrID = "street_kladr_id"
//        case streetWithType = "street_with_type"
//        case streetType = "street_type"
//        case streetTypeFull = "street_type_full"
//        case street
//        case houseFiasID = "house_fias_id"
//        case houseKladrID = "house_kladr_id"
//        case houseType = "house_type"
//        case houseTypeFull = "house_type_full"
//        case house
//        case blockType = "block_type"
//        case blockTypeFull = "block_type_full"
//        case block
//        case flatType = "flat_type"
//        case flatTypeFull = "flat_type_full"
//        case flat
//        case flatArea = "flat_area"
//        case squareMeterPrice = "square_meter_price"
//        case flatPrice = "flat_price"
//        case postalBox = "postal_box"
//        case fiasID = "fias_id"
//        case fiasCode = "fias_code"
//        case fiasLevel = "fias_level"
//        case fiasActualityState = "fias_actuality_state"
//        case kladrID = "kladr_id"
//        case geonameID = "geoname_id"
//        case capitalMarker = "capital_marker"
//        case okato, oktmo
//        case taxOffice = "tax_office"
//        case taxOfficeLegal = "tax_office_legal"
//        case timezone
//        case geoLat = "geo_lat"
//        case geoLon = "geo_lon"
//        case beltwayHit = "beltway_hit"
//        case beltwayDistance = "beltway_distance"
//        case metro
//        case qcGeo = "qc_geo"
//        case qcComplete = "qc_complete"
//        case qcHouse = "qc_house"
//        case historyValues = "history_values"
//        case unparsedParts = "unparsed_parts"
//        case source, qc
    }
}
