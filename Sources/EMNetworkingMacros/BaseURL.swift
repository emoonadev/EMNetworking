//
//  BaseURL.swift
//
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum BaseURL: DeclarationMacro {

    static func expansion(of node: some FreestandingMacroExpansionSyntax, in _: some MacroExpansionContext) throws -> [DeclSyntax] {
        if let baseURLParameter = node.arguments.first?.expression, let block = node.trailingClosure {
            if let baseURL = baseURLParameter.as(StringLiteralExprSyntax.self)?.representedLiteralValue {
                block.statements.compactMap { $0.item.asProtocol(DeclGroupSyntax.self) }.map { replacingControllerAttribute(of: $0, parameterURL: baseURL) }
            } else if let expression = node.arguments.first?.expression.as(FunctionCallExprSyntax.self), expression.calledExpression.as(DeclReferenceExprSyntax.self)?.baseName.identifier?.name == "BaseURL" {
                block.statements.compactMap { $0.item.asProtocol(DeclGroupSyntax.self) }.map { replacingControllerAttribute(of: $0, parameterURL: "\(node.arguments)") }
            } else {
                []
            }
        } else {
            []
        }
    }

    static func replacingControllerAttribute(of decl: DeclGroupSyntax, parameterURL: String) -> DeclSyntax {
        var newDecl = decl
        for i in newDecl.attributes.indices {
            guard case var .attribute(attr) = newDecl.attributes[i],
                  let attrName = attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text,
                  attrName == "Controller",
                  case let .argumentList(argsList) = attr.arguments,
                  argsList.count == 1
            else {
                continue
            }
            let expr: ExprSyntax = parameterURL.starts(with: "BaseURL") ? .init(stringLiteral: parameterURL) : "BaseURL(\(literal: parameterURL))"
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
