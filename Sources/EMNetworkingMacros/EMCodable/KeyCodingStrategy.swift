//
//  KeyCodingStrategy.swift
//  EMNetworking
//
//  Created by Mickael Belhassen on 29/08/2024.
//

import Foundation

struct KeyCodingStrategy {

    enum Case: String {
        case snakeCase
        case camelCase
        case pascalCase
        case kebabCase
        case unknown
    }
    
    func detectCase(from input: String) -> Case {
        if input.contains("_") {
            return .snakeCase
        } else if input.contains("-") {
            return .kebabCase
        } else if input.prefix(1).uppercased() == input.prefix(1) && input.contains(where: { $0.isUppercase }) {
            return .pascalCase
        } else if input.contains(where: { $0.isUppercase }) {
            return .camelCase
        } else {
            return .unknown
        }
    }

    func convert(_ input: String, to targetCase: Case) -> String {
        let baseCase = detectCase(from: input)
        let words = splitIntoWords(input, baseCase: baseCase)
        return formatWords(words, to: targetCase)
    }
    
    private func splitIntoWords(_ input: String, baseCase: Case) -> [String] {
        switch baseCase {
        case .snakeCase:
            return input.split(separator: "_").map { String($0) }
        case .kebabCase:
            return input.split(separator: "-").map { String($0) }
        case .camelCase, .pascalCase:
            return splitCamelOrPascal(input)
        default:
            return [input]
        }
    }
    
    private func splitCamelOrPascal(_ input: String) -> [String] {
        var words: [String] = []
        var currentWord = ""
        
        for (index, char) in input.enumerated() {
            if char.isUppercase {
                if let last = currentWord.last, last.isUppercase {
                    currentWord.append(char)
                } else {
                    if !currentWord.isEmpty {
                        words.append(currentWord)
                    }
                    currentWord = String(char)
                }
            } else {
                currentWord.append(char)
            }
            
            if index == input.count - 1 {
                words.append(currentWord)
            }
        }
        
        return combineAcronyms(words)
    }
    
    private func combineAcronyms(_ words: [String]) -> [String] {
        var result: [String] = []
        var buffer = ""
        
        for word in words {
            if word.allSatisfy({ $0.isUppercase }) && word.count == 1 {
                buffer.append(word)
            } else {
                if !buffer.isEmpty {
                    result.append(buffer)
                    buffer = ""
                }
                result.append(word)
            }
        }
        
        if !buffer.isEmpty {
            result.append(buffer)
        }
        
        return result.map { $0.lowercased() }
    }
    
    private func formatWords(_ words: [String], to targetCase: Case) -> String {
        switch targetCase {
        case .snakeCase:
            return words.joined(separator: "_").lowercased()
        case .kebabCase:
            return words.joined(separator: "-").lowercased()
        case .camelCase:
            return words.enumerated().map { index, word in
                index == 0 ? word.lowercased() : word.capitalized
            }.joined()
        case .pascalCase:
            return words.map { $0.capitalized }.joined()
        default:
            return words.joined(separator: " ")
        }
    }

}
