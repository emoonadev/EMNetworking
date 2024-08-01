//
//  BaseURL.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum BaseURL: DeclarationMacro {
    
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let baseURLParameter = node.arguments.first?.expression,
              let baseURL = baseURLParameter.as(StringLiteralExprSyntax.self)?.representedLiteralValue,
              let block = node.trailingClosure else {
            return []
        }
        let decls = block.statements.compactMap { $0.item.asProtocol(DeclGroupSyntax.self) }
        
        return decls.map { replacingRouteAPIAttribute(of: $0, baseURL: baseURL) }
    }
    
    static func replacingRouteAPIAttribute(of decl: DeclGroupSyntax, baseURL: String) -> DeclSyntax {
        var newDecl = decl
        for i in newDecl.attributes.indices {
            guard case var .attribute(attr) = newDecl.attributes[i],
                  let attrName = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
                  attrName == "RouteAPI" ,
                  case let .argumentList(argsList) = attr.arguments,
                  argsList.count == 1
            else {
                continue
            }
            let expr: ExprSyntax = "URL(string: \(literal: baseURL))!"
            let newArgsList = LabeledExprListSyntax {
                argsList
                LabeledExprSyntax(label: "baseURL", expression: expr)
            }
            attr.arguments = .argumentList(newArgsList)
            newDecl.attributes[i] = .attribute(attr)
        }
        return newDecl.as(DeclSyntax.self)!
    }
}
