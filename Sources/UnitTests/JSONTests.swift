//
//  JSONTests.swift
//  JSONC
//
//  Created by Alsey Coleman Miller on 8/12/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import XCTest
import SwiftFoundation
import JSONC

class JSONTests: XCTestCase {
        
    func testJSONEncodable() {
        
        do {
            
            let string = "Hey"
            
            let json: JSON.Value = string.toJSON()
            
            guard let rawValue = json.rawValue as? String
                else { XCTFail("rawValue should be String"); return }
            
            XCTAssert(rawValue == string)
        }
    }

    func testJSONParse() {
        
        func parseJSON(json: Any, _ jsonString: String) {
            
            #if os(OSX) || os(iOS)
                
                // validate JSON string on Darwin
                do {
                    
                    try NSJSONSerialization.JSONObjectWithData(jsonString.toUTF8Data().toFoundation(), options: NSJSONReadingOptions())
                }
                catch { XCTFail("Invalid JSON String"); return }
                
            #endif
            
            guard let jsonValue = JSON.Value(string: jsonString, JSONC.self)
                else { XCTFail("JSON parsing failed"); return }
            
            print("Parsed JSON: \(jsonValue)\n")
        }
        
        parseJSON(["Key": NSNull()], "{ \"Key\" : null }")
        
        parseJSON(["Key": "Value"], "{ \"Key\" : \"Value\" }")
        
        parseJSON(["Key": true], "{ \"Key\" : true }")
        
        parseJSON(["Key": 10], "{ \"Key\" : 10 }")
        
        parseJSON(["Key": 1.01], "{ \"Key\" : 1.01 }")
        
        parseJSON(["Key": ["Key2": "Value"]], "{ \"Key\" : { \"Key2\" : \"Value\" } }")
        
        parseJSON([true, false, 10, 10.10, "string", ["subarrayValue1", "subarrayValue2"], ["subobjectKey", "subobjectValue"]], "[ true, false, 10, 10.10, \"string\", [\"subarrayValue1\", \"subarrayValue2\"], {\"subobjectKey\" : \"subobjectValue\"} ]")
    }
    
    func testJSONWriting() {
        
        func writeJSON(json: JSON.Value, _ expectedJSONString: String) {
            
            guard let jsonString = json.toString([], JSONC.self)
                else { XCTFail("Could not serialize JSON"); return }
            
            #if os(OSX) || os(iOS)
            
                let foundationJSONOutput = try! NSJSONSerialization.dataWithJSONObject(json.toFoundation().rawValue, options: NSJSONWritingOptions())
            
                let foundationJSONOutputString = NSString(data: foundationJSONOutput, encoding: NSUTF8StringEncoding)
                
                XCTAssert(jsonString == foundationJSONOutputString, "Must match Foundation output. \(jsonString) == \(foundationJSONOutputString)")
                
                XCTAssert(jsonString == foundationJSONOutputString, "Expected JSON string must match Foundation output. \(expectedJSONString) == \(foundationJSONOutputString)")
            #endif
            
            XCTAssert(jsonString == expectedJSONString, "Does not match expected output. \(jsonString) == \(expectedJSONString)")
            
            print("JSON Output: \(jsonString)")
        }
        
        writeJSON(.Object([
            "Key": .String("Value")
            ]), "{\"Key\":\"Value\"}")
        
        writeJSON(.Array([
            .String("value1"),
            .String("value2"),
            .Null,
            .Number(.Boolean(true)),
            .Number(.Integer(10)),
            .Number(.Double(10.10)),
            .Object(["Key": .String("Value")])
            ]), "[\"value1\",\"value2\",null,true,10,10.1,{\"Key\":\"Value\"}]")
    }
}
