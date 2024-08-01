import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct HTTPMethodMacro: PeerMacro {

    public static func expansion(of _: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return .init()
    }

    public enum DeclError: CustomStringConvertible, Error {
        case onlyApplicableToEnumCase

        public var description: String {
            switch self {
                case .onlyApplicableToEnumCase: "@HTTPMethod can only be applied to an enum case."
            }
        }
    }

}


public struct RouteAPI: ExtensionMacro, PeerMacro {
    
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
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
            var path: String?

            if caseSynt.attributes.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.last?.label?.text == "path" {
                path = caseSynt.attributes.first?.as(AttributeSyntax.self)?.arguments?.as(LabeledExprListSyntax.self)?.last?.expression.description ?? ""

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
            }

            cases.append(
                CaseMethod(name: caseName, method: methodStr, path: path, parameters: parameters ?? [])
            )
        }

        func transformParameterString(_ input: String) -> String {
            let pattern = "\\.parameter\\(\"(.*?)\"\\)"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(input.startIndex..., in: input)
            let modifiedString = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: ".parameter(String(describing: $1))")
            
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

            cases.forEach { caseMethod in
                switch caseMethod.method {
                    case "post", "patch", "put":
                        if caseMethod.parameters.isEmpty {
                            if let path = caseMethod.path {
                                requestSyntax.append("case .\(caseMethod.name): \(caseMethod.method)(\(transformParameterString(path)))")
                            } else {
                                requestSyntax.append("case .\(caseMethod.name): \(caseMethod.method)()")
                            }
                        } else {
                            requestSyntax.append("case let .\(caseMethod.name)(\(caseMethod.parameters.map { $0.name ?? "req" }.joined(separator: ", "))):")

                            if let path = caseMethod.path {
                                requestSyntax.append("\(caseMethod.method)(\(transformParameterString(path)), body: req)")
                            } else {
                                requestSyntax.append("\(caseMethod.method)(body: req)")
                            }
                        }
                    case "get":
                    if caseMethod.parameters.isEmpty {
                        if let path = caseMethod.path {
                            requestSyntax.append("case .\(caseMethod.name): get(\(transformParameterString(path)))")
                        } else {
                            requestSyntax.append("case .\(caseMethod.name): get()")
                        }
                    } else {
                        requestSyntax.append("case let .\(caseMethod.name)(\(caseMethod.parameters.map { $0.name ?? "req" }.joined(separator: ", "))):")
                        
                        if let path = caseMethod.path {
                            requestSyntax.append("get(\(transformParameterString(path)))")
                        } else {
                            requestSyntax.append("case .\(caseMethod.name): get()")
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
            }
        ]
    }

    public enum DeclError: CustomStringConvertible, Error {
        case onlyApplicableToEnum
        case passParamsNotMatching(String)

        public var description: String {
            switch self {
                case .onlyApplicableToEnum: "@HTTPMethod can only be applied to an enum."
                case let .passParamsNotMatching(caseName): "Path parameters dosnt matches with case \(caseName) parameters"
            }
        }
    }

    struct CaseMethod {
        var name: String
        var method: String
        var path: String?
        var parameters: [Parameter] = []

        struct Parameter {
            var name: String?
            var type: String
        }
    }
}

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

@main
struct MyMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        HTTPMethodMacro.self,
        RouteAPI.self,
        BaseURL.self,
    ]
}
