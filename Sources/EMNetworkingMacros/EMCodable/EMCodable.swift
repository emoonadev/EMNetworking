//
//  Codable.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 22/08/2024.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EMCodable: ExtensionMacro {
    
    public static func expansion(of _: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo _: [SwiftSyntax.TypeSyntax], in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {

        let filteredArray = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
//            .filter {
//                $0.attributes.first?.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "HTTP"
//            }

        var properties = [Property]()
        var syntax = ""

        let keyCodingStrategy = KeyCodingStrategy()
        let keyCodingCaseStr = declaration.attributes.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.first { $0.label?.identifier?.name == "codingKeyStrategy" }?.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text ?? ".camelCase"
        let keyCodingCase = KeyCodingStrategy.Case(rawValue: keyCodingCaseStr) ?? .camelCase
        
        properties = filteredArray.map { item in
            let property = item.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text ?? ""
            let codingKey = item.attributes.filter { $0.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "EMCodingKey" }.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.first?.expression.as(StringLiteralExprSyntax.self)?.segments.first?.as(StringSegmentSyntax.self)?.content.text
            let type = item.bindings.first?.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name.text ?? item.bindings.first?.typeAnnotation?.type.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text.appending("?") ?? ""
            return Property(propertyName: property, codingKey: codingKey ?? keyCodingStrategy.convert(property, to: keyCodingCase), type: type)
        }

        var codingKeysEnum = ""
        codingKeysEnum.append("enum CodingKeys: String, CodingKey {")
        codingKeysEnum.append("case \(properties.map { $0.propertyName == $0.codingKey ? $0.propertyName : "\($0.propertyName) = \"\($0.codingKey)\"" }.joined(separator: ","))")
        codingKeysEnum.append("}")
        
        var encodeMethod = ""
        encodeMethod.append("func encode(to encoder: Encoder) throws {")
        encodeMethod.append("var container = encoder.container(keyedBy: CodingKeys.self)")
        encodeMethod.append(properties.map { "try container.\($0.isOptional ? "encodeIfPresent" : "encode")(\($0.propertyName), forKey: .\($0.propertyName))" }.joined(separator: "\n"))
        encodeMethod.append("}")
        
        var initMethod = ""
        initMethod.append("init(from decoder: Decoder) throws {")
        initMethod.append("let container = try decoder.container(keyedBy: CodingKeys.self)")
        initMethod.append(properties.map { "\($0.propertyName) = try container.\($0.isOptional ? "decodeIfPresent" : "decode")(\($0.type.replacingOccurrences(of: "?", with: "")).self, forKey: .\($0.propertyName))" }.joined(separator: "\n"))
        initMethod.append("}")
        
        syntax.append(codingKeysEnum)
        syntax.append(initMethod)
        syntax.append(encodeMethod)

        return [
            try ExtensionDeclSyntax("extension \(type.trimmed): Codable") {
                "\n\(raw: syntax)"
            },
        ]
    }

    struct Property {
        var propertyName: String
        var codingKey: String
        var type: String
        
        var isOptional: Bool {
            type.contains("?")
        }
    }

}
