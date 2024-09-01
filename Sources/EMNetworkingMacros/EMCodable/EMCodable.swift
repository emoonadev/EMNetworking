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

        var typealiases = [TypeAlias]()
        var properties = [Property]()
        var syntax = ""

        let keyCodingStrategy = KeyCodingStrategy()
        let keyCodingCaseStr = declaration.attributes.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.first { $0.label?.identifier?.name == "codingKeyStrategy" }?.expression.as(MemberAccessExprSyntax.self)?.declName.baseName.text ?? ".camelCase"
        let keyCodingCase = KeyCodingStrategy.Case(rawValue: keyCodingCaseStr) ?? .camelCase

        properties.append(contentsOf: filteredArray.map { item in
            let keyProperties = item.bindings.map {
                $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text ?? ""
            }
            
            let codingKey = item.attributes
                .compactMap { $0.as(AttributeSyntax.self) }
                .filter { $0.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "EMCodingKey" }
                .first?
                .arguments?.as(LabeledExprListSyntax.self)?
                .first?
                .expression.as(StringLiteralExprSyntax.self)?
                .segments.first?
                .as(StringSegmentSyntax.self)?
                .content.text
            
            let type: String = {
                if let lastType = item.bindings.last?.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name.text {
                    return lastType
                } else if let optionalType = item.bindings.first?.typeAnnotation?.type.as(OptionalTypeSyntax.self)?.wrappedType.as(IdentifierTypeSyntax.self)?.name.text {
                    return "\(optionalType)?"
                } else if let arrayType = item.bindings.last?.typeAnnotation?.type.as(ArrayTypeSyntax.self)?.element.as(IdentifierTypeSyntax.self)?.name.text {
                    return "[\(arrayType)]"
                } else if let memberSynt = item.bindings.last?.typeAnnotation?.type.as(MemberTypeSyntax.self), let baseType = memberSynt.baseType.as(IdentifierTypeSyntax.self)?.name.text {
                    let typeAliaseName = baseType+memberSynt.name.text
                    typealiases.append(.init(name: typeAliaseName, value: "\(baseType).\(memberSynt.name.text)"))
                    return typeAliaseName
                } else {
                    return ""
                }
            }()
            
            let property = keyProperties.first ?? ""
            let remainProperties = keyProperties.dropFirst()
            
            remainProperties.forEach {
                properties.append(
                    Property(
                        propertyName: $0,
                        codingKey: codingKey ?? keyCodingStrategy.convert($0, to: keyCodingCase),
                        type: type
                    )
                )
            }

            return Property(
                propertyName: property,
                codingKey: codingKey ?? keyCodingStrategy.convert(property, to: keyCodingCase),
                type: type
            )
        })
        
        var typeAliasesSyn = ""
        typeAliasesSyn.append(typealiases.map { "typealias \($0.name) = \($0.value)" }.joined(separator: "\n"))
        typeAliasesSyn.append("\n")

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

        syntax.append(typeAliasesSyn)
        syntax.append(codingKeysEnum)
        syntax.append(initMethod)
        syntax.append(encodeMethod)

        return [
            try ExtensionDeclSyntax("extension \(type.trimmed): Codable") {
                "\n\(raw: syntax)"
//                "\n\(raw: filteredArray)"
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
    
    struct TypeAlias {
        var name: String
        var value: String
    }

}
