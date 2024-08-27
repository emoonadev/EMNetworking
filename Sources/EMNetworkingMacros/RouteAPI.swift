//
//  RouteAPI.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RouteAPI: ExtensionMacro, PeerMacro {

    public static func expansion(of _: SwiftSyntax.AttributeSyntax, providingPeersOf _: some SwiftSyntax.DeclSyntaxProtocol, in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        .init()
    }

    public static func expansion(of attr: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo _: [SwiftSyntax.TypeSyntax], in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else { throw DeclError.onlyApplicableToEnum }

        var cases: [CaseMethod] = []

        let filteredArray = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .filter {
                $0.attributes.first?.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "HTTP"
            }

        let baseURL = attr.arguments?.as(LabeledExprListSyntax.self)?.last?.expression.as(ForceUnwrapExprSyntax.self)?.expression.as(FunctionCallExprSyntax.self)?.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text ?? ""
        let controllerPath = attr.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text ?? ""

        try filteredArray.forEach { caseSynt in
            let caseName = caseSynt.elements.first?.name.text ?? ""
            let methodStr = caseSynt.attributes.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text ?? ""
            let parameters = caseSynt.elements.first?.parameterClause?.parameters.compactMap { CaseMethod.Parameter(name: $0.firstName?.text, type: $0.type.as(IdentifierTypeSyntax.self)?.name.text ?? "") }
            let path = caseSynt.attributes.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.compactMap { $0.expression.description }.dropFirst().joined(separator: ",")

            if caseSynt.attributes.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.last?.expression.as(FunctionCallExprSyntax.self)?.arguments.first?.expression.as(ArrayExprSyntax.self)?.elements.compactMap({ $0.expression.as(FunctionCallExprSyntax.self)?.calledExpression.as(MemberAccessExprSyntax.self)?.declName.baseName.text }).contains("parameter") == true {
                if let pathParameters = (caseSynt.attributes.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.last?.expression.as(FunctionCallExprSyntax.self)?.arguments.first?.expression.as(ArrayExprSyntax.self)?.elements.compactMap { $0.expression.as(FunctionCallExprSyntax.self)?.arguments.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text }), !pathParameters.isEmpty {
                    if let caseParameters = parameters?.compactMap(\.name) {
                        for pathParam in pathParameters {
                            if !caseParameters.contains(pathParam) {
                                throw DeclError.passParamsNotMatching(caseName)
                            }
                        }
                    }
                }
            }

            let queryItems = caseSynt.elements.first?.parameterClause?.parameters.filter { $0.type.as(IdentifierTypeSyntax.self)?.name.text == "QueryItems" }
            let queryItemsParamName = queryItems?.first?.firstName?.text

            if (queryItems?.count ?? 0) > 1 {
                throw DeclError.duplicateQueryItems
            }

            cases.append(
                CaseMethod(name: caseName, method: methodStr, path: path, parameters: parameters ?? [], queryParameterName: queryItemsParamName)
            )
        }

        func transformParameterString(_ input: String, asString: Bool = false) -> String {
            let pattern = "\\.parameter\\(\"(.*?)\"\\)"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(input.startIndex..., in: input)
            let modifiedString = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: asString ? ".parameter(\"$1\")" : ".parameter(String(describing: $1))")

            return modifiedString
        }

        var requestSyntax = ""

        if !cases.isEmpty {
            requestSyntax.append(
                """
                var baseURL: URL { URL(string: \"\(baseURL + controllerPath)\")! }

                var request: Request {
                    switch self {
                """
            )

            try cases.forEach { caseMethod in
                switch caseMethod.method {
                    case "post", "patch", "put":
                        if caseMethod.parameters.isEmpty {
                            throw DeclError.bodyParamMissingForCase(caseMethod.name)
                        } else {
                            let caseParams = caseMethod.parameters.map { $0.name ?? "body" }
                            requestSyntax.append("case let .\(caseMethod.name)(\(caseParams.joined(separator: ", "))):")

                            if !caseParams.contains("body") {
                                throw DeclError.bodyParamMissingForCase(caseMethod.name)
                            }

                            if let paramName = caseMethod.queryParameterName {
                                requestSyntax.append("let urlQueryItems: [URLQueryItem] = \(paramName).compactMap { URLQueryItem(name: $0, value: String(describing: $1)) }")
                            }

                            if let path = caseMethod.path {
                                requestSyntax.append("return \(caseMethod.method)(\(transformParameterString(path)), body: body, queryItems: \(caseMethod.queryParameterName != nil ? "urlQueryItems" : "[]"))")
                            } else {
                                requestSyntax.append("return \(caseMethod.method)(body: body, queryItems: \(caseMethod.queryParameterName != nil ? "urlQueryItems" : "[]"))")
                            }
                        }
                    case "get":
                        if caseMethod.parameters.isEmpty {
                            if let path = caseMethod.path {
                                requestSyntax.append("case .\(caseMethod.name):")

                                if let paramName = caseMethod.queryParameterName {
                                    requestSyntax.append("let urlQueryItems: [URLQueryItem] = \(paramName).compactMap { URLQueryItem(name: $0, value: String(describing: $1)) }")
                                }

                                requestSyntax.append("return get(\(transformParameterString(path, asString: true)), queryItems: \(caseMethod.queryParameterName != nil ? "urlQueryItems" : "[]"))")
                            } else {
                                requestSyntax.append("case .\(caseMethod.name):")

                                if let paramName = caseMethod.queryParameterName {
                                    requestSyntax.append("let urlQueryItems: [URLQueryItem] = \(paramName).compactMap { URLQueryItem(name: $0, value: String(describing: $1)) }")
                                }

                                requestSyntax.append("return get(queryItems: \(caseMethod.queryParameterName != nil ? "urlQueryItems" : "[]"))")
                            }
                        } else {
                            requestSyntax.append("case let .\(caseMethod.name)(\(caseMethod.parameters.compactMap { $0.name }.joined(separator: ", "))):")

                            if let path = caseMethod.path {
                                var isQueryItem: Bool = false
                                
                                if let paramName = caseMethod.queryParameterName {
                                    requestSyntax.append("let urlQueryItems: [URLQueryItem] = \(paramName).compactMap { URLQueryItem(name: $0, value: String(describing: $1)) }")
                                    isQueryItem = true
                                } else if caseMethod.parameters.contains(where: { $0.name == "dto" }) {
                                    requestSyntax.append("let urlQueryItems: [URLQueryItem] = (try? URLQueryItemEncoder(strategies: .default).encode(dto)) ?? []")
                                    isQueryItem = true
                                }

                                requestSyntax.append("return get(\(transformParameterString(path)), queryItems: \(isQueryItem ? "urlQueryItems" : "[]"))")
                            } else {
                                requestSyntax.append("case .\(caseMethod.name):")

                                var isQueryItem: Bool = false

                                if let paramName = caseMethod.queryParameterName {
                                    requestSyntax.append("let urlQueryItems: [URLQueryItem] = \(paramName).compactMap { URLQueryItem(name: $0, value: String(describing: $1)) }")
                                    isQueryItem = true
                                } else if caseMethod.parameters.contains(where: { $0.name == "dto" }) {
                                    requestSyntax.append("let urlQueryItems: [URLQueryItem] = (try? URLQueryItemEncoder(strategies: .default).encode(dto)) ?? []")
                                    isQueryItem = true
                                }

                                requestSyntax.append("return get(queryItems: \(isQueryItem ? "urlQueryItems" : "[]"))")
                            }
                        }
                    default:
                        break
                }
            }

            requestSyntax.append(
                """
                    }
                }
                """
            )
        }

        return [
            try ExtensionDeclSyntax("extension \(type.trimmed): APIRoute") {
                "\n\(raw: requestSyntax)"
            },
//            try ExtensionDeclSyntax("extension \(type.trimmed): APIRoute") {
//                "\n\(raw: filteredArray.first?.elements.first?.parameterClause?.parameters.filter { $0.type.as(IdentifierTypeSyntax.self)?.name.text == "QueryItems" })"
//            },
        ]
    }

    public enum DeclError: CustomStringConvertible, Error {
        case onlyApplicableToEnum
        case bodyParamMissingForCase(String)
        case passParamsNotMatching(String)
        case duplicateQueryItems

        public var description: String {
            switch self {
                case .onlyApplicableToEnum: "@HTTPMethod can only be applied to an enum."
                case .duplicateQueryItems: "QueryItems is used several times in the same case. Should be used once"
                case let .bodyParamMissingForCase(caseName): "Body parameter is missing for case `.\(caseName)`"
                case let .passParamsNotMatching(caseName): "Path parameters dosnt matches with case `.\(caseName)` parameters"
            }
        }
    }

    struct CaseMethod {
        var name: String
        var method: String
        var path: String?
        var parameters: [Parameter] = []
        var queryParameterName: String?

        struct Parameter {
            var name: String?
            var type: String
        }
    }
}
