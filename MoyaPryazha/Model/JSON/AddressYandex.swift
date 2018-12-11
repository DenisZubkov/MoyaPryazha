// To parse the JSON, add this file to your project and do:
//
//   let addressYandex = try? newJSONDecoder().decode(AddressYandex.self, from: jsonData)
//
// To read values from URLs:
//
//   let task = URLSession.shared.addressYandexTask(with: url) { addressYandex, response, error in
//     if let addressYandex = addressYandex {
//       ...
//     }
//   }
//   task.resume()

import Foundation

struct AddressYandex: Codable {
    let response: Response?
}

struct Response: Codable {
    let geoObjectCollection: GeoObjectCollection?
    
    enum CodingKeys: String, CodingKey {
        case geoObjectCollection = "GeoObjectCollection"
    }
}

struct GeoObjectCollection: Codable {
    let metaDataProperty: GeoObjectCollectionMetaDataProperty?
    let featureMember: [FeatureMember?]
}

struct FeatureMember: Codable {
    let geoObject: GeoObject?
    
    enum CodingKeys: String, CodingKey {
        case geoObject = "GeoObject"
    }
}

struct GeoObject: Codable {
    let metaDataProperty: GeoObjectMetaDataProperty?
    let description, name: String?
    let boundedBy: BoundedBy?
    let point: Point?
    
    enum CodingKeys: String, CodingKey {
        case metaDataProperty, description, name, boundedBy
        case point = "Point"
    }
}

struct BoundedBy: Codable {
    let envelope: Envelope?
    
    enum CodingKeys: String, CodingKey {
        case envelope = "Envelope"
    }
}

struct Envelope: Codable {
    let lowerCorner, upperCorner: String?
}

struct GeoObjectMetaDataProperty: Codable {
    let geocoderMetaData: GeocoderMetaData?
    
    enum CodingKeys: String, CodingKey {
        case geocoderMetaData = "GeocoderMetaData"
    }
}

struct GeocoderMetaData: Codable {
    let kind: String?
    let text: String?
    let precision: String?
    let address: Address?
    let addressDetails: AddressDetails?
    
    enum CodingKeys: String, CodingKey {
        case kind, text, precision
        case address = "Address"
        case addressDetails = "AddressDetails"
    }
}

struct Address: Codable {
    let countryCode: String?
    let formatted: String?
    let components: [Component?]
    
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case formatted
        case components = "Components"
    }
}

struct Component: Codable {
    let kind: String?
    let name: String?
}


struct AddressDetails: Codable {
    let country: Country?
    
    enum CodingKeys: String, CodingKey {
        case country = "Country"
    }
}

struct Country: Codable {
    let addressLine: String?
    let countryNameCode: String?
    let countryName: String?
    let administrativeArea: AdministrativeArea?
    
    enum CodingKeys: String, CodingKey {
        case addressLine = "AddressLine"
        case countryNameCode = "CountryNameCode"
        case countryName = "CountryName"
        case administrativeArea = "AdministrativeArea"
    }
}

struct AdministrativeArea: Codable {
    let administrativeAreaName: String?
    let subAdministrativeArea: SubAdministrativeArea?
    let locality: Locality?
    
    enum CodingKeys: String, CodingKey {
        case administrativeAreaName = "AdministrativeAreaName"
        case subAdministrativeArea = "SubAdministrativeArea"
        case locality = "Locality"
    }
}

struct Locality: Codable {
    let localityName: String?
    
    enum CodingKeys: String, CodingKey {
        case localityName = "LocalityName"
    }
}

struct SubAdministrativeArea: Codable {
    let subAdministrativeAreaName: String?
    let locality: Locality?
    
    enum CodingKeys: String, CodingKey {
        case subAdministrativeAreaName = "SubAdministrativeAreaName"
        case locality = "Locality"
    }
}

struct Point: Codable {
    let pos: String?
}

struct GeoObjectCollectionMetaDataProperty: Codable {
    let geocoderResponseMetaData: GeocoderResponseMetaData?
    
    enum CodingKeys: String, CodingKey {
        case geocoderResponseMetaData = "GeocoderResponseMetaData"
    }
}

struct GeocoderResponseMetaData: Codable {
    let request, found, results: String?
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }
    
    func addressYandexTask(with url: URL, completionHandler: @escaping (AddressYandex?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}
