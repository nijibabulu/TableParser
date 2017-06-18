//
//  NamedColumnTableParser.swift
//  TableParser
//
//  Created by Bob on 13/06/2017.
//  Copyright © 2017 Zimmerapps. All rights reserved.
//

import UIKit
/*
public class NamedColumnTableParser: Sequence, IteratorProtocol {

    var _headers: [String]?
    var _tableParser: TableParser
    
    public func next() -> [String:String]? {
        if _tableParser._lineNumber == 0 {
            let headers = _tableParser.next()
            if _headers == nil {
                _headers = headers
            }
        }
        if let rowData = _tableParser.next() as [String]?, let headers = _headers as [String]? {
            guard rowData.count == headers.count else {
                fatalError("Line \(_tableParser._lineNumber) contains a different number of columns (\(rowData.count)) than the header (\(headers.count))")
            }
            var row = [String:String]()
            for (name,value) in zip(headers,rowData) {
                row[name] = value
            }
            return row
        } else {
            return nil
        }
    }
    public init(with string: String, dialect: TableDialect = Dialects.excelCSV, withColumnNames columnNames: [String]? = nil) {
        _tableParser = TableParser(with: string, dialect: dialect)
        _headers = columnNames
    }
    
}
*/
