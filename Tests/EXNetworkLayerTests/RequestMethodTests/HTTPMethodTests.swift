//
//  RequestMethodTests.swift
//  
//
//  Created by Abhijith Pm on 06/11/22.
//

import Foundation
import XCTest
import EXNetworkLayer


class HTTPMethodTests: XCTestCase {

    func testRequestMethodNames() {
        XCTAssertEqual(HTTPMethod.get.value, "GET")
        XCTAssertEqual(HTTPMethod.post.value, "POST")
        XCTAssertEqual(HTTPMethod.delete.value, "DELETE")
        XCTAssertEqual(HTTPMethod.put.value, "PUT")

    }
}
