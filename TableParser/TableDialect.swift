//
//  TableDialect.swift
//  TableParser
//
//  Created by Bob on 23/05/2017.
//  Copyright © 2017 Zimmerapps. All rights reserved.
//

import UIKit

public class TableDialect  {
    enum TokenType {
        case delimiter
        case quoteChar
        case escapeChar
        case lineTerminator
        case otherChar
    }
    let tokenDefinition: Dictionary<CharacterSet,TokenType>
    let doubleQuote: Bool // excel quotes inside quoted fields are expressed as ""
    
    public init(withDelimiter delimiter: CharacterSet, withQuoteChar quoteChar: CharacterSet, withEscapeChar escapeChar: CharacterSet, withLineTerminator lineTerminator: CharacterSet, withDoubleQuote doubleQuote: Bool) {
        self.tokenDefinition = [
            delimiter: .delimiter,
            quoteChar: .quoteChar,
            escapeChar: .escapeChar,
            lineTerminator: .lineTerminator
        ]
        self.doubleQuote = doubleQuote
    }
    convenience public init(withDelimiter delimiter: String = ",", withQuoteChar quoteChar: String = "\"", withEscapeChar escapeChar: String = "\\", withDoubleQuote doubleQuote: Bool = true) {
        self.init(withDelimiter: CharacterSet(charactersIn:delimiter),
                  withQuoteChar: CharacterSet(charactersIn:quoteChar),
                  withEscapeChar: CharacterSet(charactersIn:escapeChar),
                  withLineTerminator: CharacterSet.newlines,
                  withDoubleQuote: doubleQuote)
    }
    convenience public init() {
        self.init(withDelimiter:",",withQuoteChar:"\"", withEscapeChar:"\\")
    }
    
    func getTokenType(for c: UnicodeScalar) -> TokenType {
        for (tokenSet,tokenType) in tokenDefinition {
            if tokenSet.contains(c) {
                return tokenType
            }
        }
        return .otherChar
    }
}

public struct Dialects {
    static let excelCSV = TableDialect(withDelimiter: ",", withQuoteChar: "\"", withEscapeChar: "", withDoubleQuote: true)
    static let excelTab = TableDialect(withDelimiter: "\t", withQuoteChar: "\"", withEscapeChar: "", withDoubleQuote: true)
}
