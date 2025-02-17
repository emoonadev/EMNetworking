//
//  ContentType.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 05/08/2024.
//

import Foundation

public enum ContentType {
    case json
    case formData
    case xml
    case plainText
    case html
    case css
    case javascript
    case png
    case jpeg
    case gif
    case svg
    case webp
    case octetStream
    case pdf
    case zip
    case gzip
    case formURLEncoded(alphabetizeKeyValuePairs: Bool = true,
                        arrayEncoding: URLEncodedFormEncoder.ArrayEncoding = .brackets,
                        boolEncoding: URLEncodedFormEncoder.BoolEncoding = .numeric,
                        dataEncoding: URLEncodedFormEncoder.DataEncoding = .base64,
                        dateEncoding: URLEncodedFormEncoder.DateEncoding = .deferredToDate,
                        keyEncoding: URLEncodedFormEncoder.KeyEncoding = .useDefaultKeys,
                        spaceEncoding: URLEncodedFormEncoder.SpaceEncoding = .percentEscaped,
                        allowedCharacters: CharacterSet = .afURLQueryAllowed)

    var value: String {
        switch self {
            case .json: "application/json"
            case .formURLEncoded: "application/x-www-form-urlencoded"
            case .formData: "multipart/form-data"
            case .xml: "application/xml"
            case .plainText: "text/plain"
            case .html: "text/html"
            case .css: "text/css"
            case .javascript: "application/javascript"
            case .png: "image/png"
            case .jpeg: "image/jpeg"
            case .gif: "image/gif"
            case .svg: "image/svg+xml"
            case .webp: "image/webp"
            case .octetStream: "application/octet-stream"
            case .pdf: "application/pdf"
            case .zip: "application/zip"
            case .gzip: "application/gzip"
        }
    }
}
