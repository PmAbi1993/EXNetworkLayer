//
//  HTTPSchemeTests.swift
//  
//
//  Created by Abhijith Pm on 01/11/22.
//

import XCTest
@testable import EXNetworkLayer

final class HTTPSchemeTests: XCTestCase {

    func testSchemesAreOfProperValue() {
        XCTAssertTrue(HTTPScheme.http.value.elementsEqual("HTTP"))
        XCTAssertTrue(HTTPScheme.https.value.elementsEqual("HTTPS"))
    }
}
