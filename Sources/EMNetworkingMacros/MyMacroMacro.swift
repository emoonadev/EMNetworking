import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


@main
struct EMNetworkingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        HTTPMethodMacro.self,
        Controller.self,
        BaseURL.self,
        EMCodable.self,
        EMCodingKey.self,
    ]
}
