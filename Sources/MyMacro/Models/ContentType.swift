//
//  ContentType.swift
//  MyMacro
//
//  Created by Mickael Belhassen on 05/08/2024.
//

public enum ContentType: String {
    case json = "application/json"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case formData = "multipart/form-data"
    case xml = "application/xml"
    case plainText = "text/plain"
    case html = "text/html"
    case css = "text/css"
    case javascript = "application/javascript"
    case png = "image/png"
    case jpeg = "image/jpeg"
    case gif = "image/gif"
    case svg = "image/svg+xml"
    case webp = "image/webp"
    case octetStream = "application/octet-stream"
    case pdf = "application/pdf"
    case zip = "application/zip"
    case gzip = "application/gzip"
}
