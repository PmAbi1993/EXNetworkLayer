//
//  File.swift
//  
//
//  Created by Abhijith Pm on 06/11/22.
//

import Foundation
import XCTest
import EXNetworkLayer

final class HeaderTests: XCTestCase {
    
    class MockHeaders: RequestHeaders {
        var method: HTTPMethod { .post }
        
        var headers: HTTPHeader { .jsonContent }
    }
    
    func testHeaderCount() {
        XCTAssertTrue(MockHeaders().headers.count == 1)
    }
    
    func testHeaderData() {
        let headers = MockHeaders().headers
        XCTAssertNotNil(headers["Content-Type"])
        XCTAssertTrue(
            (headers["Content-Type"] as? String)?
                .elementsEqual("application/json; charset=utf-8") ?? false)
    }
    
}
