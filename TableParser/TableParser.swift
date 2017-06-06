//
//  TableParser.swift
//  TableParser
//
//  Created by Bob on 23/05/2017.
//  Copyright © 2017 Zimmerapps. All rights reserved.
//

import UIKit
import Foundation

public class TableParser: Sequence, IteratorProtocol {
    enum TableParseState {
        case startRecord // beginning of row
        case inField // in any arbitrary point of an unquoted field
        case startField // just parsed a delimiter or getting into first field in a line
        case escapedChar // just parsed an escape character
        case ignoreNewline // at the end of a record and not adding newline or anything else to record
        case inQuotedField // inside a field which began with quoteChar
        case quoteInQuotedField // got a quoteChar indicating the end of a field or the beginning of an excel double quote.
        case escapeInQuotedField // got an escape prefix in quoted field (potentially an escaped quote follows)
    }
    
    var _data: Array<UnicodeScalar>
    public var dialect: TableDialect { return TableDialect() }
    
    var _parseState: TableParseState = .startRecord
    var _lineNumber: Int = 0
    var _field = [UnicodeScalar]()
    var _row = [String]()
    var pos = 0
    
    public func makeIterator() -> TableParser {
        return self
    }
    
    
    public func next() -> Array<String>? {
        _row = [String]()
        while pos < _data.count  {
            _lineNumber += 1
            repeat {
                pos = _parseChar(pos: pos)
            } while _parseState != .ignoreNewline && pos < _data.count
            _parseEol()
            if _parseState == .startRecord {
                break
            }
        }
        //          TODO error check if we're in still a field (_field not nil)
        if _row.count > 0 || pos < _data.count {
            return _row
        } else {
            return nil
        }
    }
    
    private func _parseChar(pos _pos: Int) -> Int {
        var pos = _pos
        let c = _data[pos]
        let appendField = { [unowned self] (pos: Int, end: Int) in
            if end > pos { self._field += self._data[pos..<end] }
        }
        switch _parseState {
        case .inField:
            var end = pos
            repeat {
                let tokenType = dialect.getTokenType(for: _data[end])
                switch tokenType {
                case .delimiter, .lineTerminator:
                    appendField(pos,end)
                    _saveField()
                    pos = end
                    _parseState = tokenType == .delimiter ? .startField : .ignoreNewline
                case .escapeChar:
                    end -= 1
                    _parseState = .escapedChar
                case .quoteChar, .otherChar:
                    end += 1
                }
            } while(_parseState == .inField  && end < _data.count)
            appendField(pos,end)
            pos = end
            
        case .startRecord:
            if dialect.getTokenType(for: c) == .lineTerminator {
                _parseState = .ignoreNewline
                _saveField()
            } else {
                _parseState = .startField
                return pos // implicitly restart
            }
            
        case .startField:
            switch dialect.getTokenType(for: c) {
            case .lineTerminator:
                _saveField()
                _parseState = .ignoreNewline
            case .quoteChar:
                _parseState = .inQuotedField // begin quoted field only at the start of the field
            case .escapeChar:
                _parseState = .escapedChar // expect an escaped character next
            case .delimiter:
                _saveField() // empty field, save, still at the start of the next field
            case .otherChar:
                // TODO, with a quoteNonnumeric option in the dialect, could default to
                // integer/float types when parsing unquoted fields
                _field = [c]
                _parseState = .inField
            }
            
        case .escapedChar:
            _field.append(c)
            _parseState = .inField
            
        case .inQuotedField:
            switch dialect.getTokenType(for: c) {
            case .escapeChar:
                _parseState = .escapeInQuotedField
            case .quoteChar:
                if dialect.doubleQuote {
                    _parseState = .quoteInQuotedField
                } else {
                    _parseState = .inField // a quoted part of a field has ended; expect delimiter or continuation
                }
            default:
                _field.append(c)
            }
            
        case .escapeInQuotedField:
            _field.append(c)
            _parseState = .inQuotedField
            
        case .quoteInQuotedField:
            switch dialect.getTokenType(for: c) {
            case .quoteChar:
                _field.append(c) // save "" as "
                _parseState = .inQuotedField
            case .delimiter:
                _saveField()
                _parseState = .startField
            case .lineTerminator:
                _saveField()
                _parseState = .ignoreNewline
            default:
                _field.append(c)
            }
            
        case .ignoreNewline:
            // error checking might not be necessary here
            switch dialect.getTokenType(for: c) {
            case .lineTerminator:
                break
            default:
                print("ERROR--newline in unquoted field")
                
            }
        }
        return pos + 1
    }
    
    private func _parseEol() {
        switch _parseState {
        case .ignoreNewline: _parseState = .startRecord
        case .startField, .inField, .quoteInQuotedField:
            _saveField()
            _parseState = .startRecord
        case .escapedChar:
            self._field.append("\n")
            _parseState = .inField
        default: break
        }
    }
    
    private func _saveField() {
        _row.append(self._field.flatMap({u in String(u)}).joined())
        self._field = [UnicodeScalar]()
    }
    
    public init(with string: String, dialect: TableDialect = Dialects.excelCSV) {
        self._data = Array(string.unicodeScalars)
    }
    //    public convenience init(withFileNamed file:String) throws {
    //        try self.init(withString: String(contentsOfFile: file))
    //    }
    //    public convenience init(withURL url: URL) throws {
    //        try self.init(withString: String(contentsOf: url))
    //    }
}
