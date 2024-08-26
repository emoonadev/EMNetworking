//
//  EMCodingKey.swift
//  MyMacro
//
//  Created by Mickael Belhassen on 22/08/2024.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EMCodingKey: PeerMacro {
    
    public static func expansion(of _: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in _: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        return .init()
    }
    
}
