//
//  HTTPMethod.swift
//  
//
//  Created by Mickael Belhassen on 01/08/2024.
//

import SwiftCompilerPlugin
import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct HTTPMethodMacro: PeerMacro {

    public static func expansion(of _: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return .init()
    }

}
