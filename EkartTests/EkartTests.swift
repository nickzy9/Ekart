//
//  EkartTests.swift
//  EkartTests
//
//  Created by Aniket on 9/21/19.
//  Copyright © 2019 Heady. All rights reserved.
//

import XCTest
@testable import Ekart

class EkartTests: XCTestCase {

    /// Test request
    func testRequest() {
        Service.shared.apiCall(Global.api.headyProducts, isToGetSavedData: false) { (_, result) in
            if result == .success {
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }
    
    /// Test request execution time
    func testReuqestTime() {
        self.measure {
            testRequest()
        }
    }

}
