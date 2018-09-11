//
//  HomeAwayCodingChallengeTests.swift
//  HomeAwayCodingChallengeTests
//
//  Created by Andrew Whitehead on 9/11/18.
//  Copyright © 2018 Andrew Whitehead. All rights reserved.
//

import XCTest

@testable import HomeAwayCodingChallenge

class HomeAwayCodingChallengeTests: XCTestCase {
    
    var vcUnderTest: MasterViewController!

    var fakeEvent: Event!
    
    override func setUp() {
        super.setUp()
        
        fakeEvent = Event(id: -1)
        
        vcUnderTest = MasterViewController()
    }
    
    override func tearDown() {
        try? FavoritesHelper.shared.remove(fakeEvent)
        fakeEvent = nil
        
        vcUnderTest = nil
        
        super.tearDown()
    }
    
    func testPerformQueryGetsHTTPStatusCode200() {
        let promise = expectation(description: "Status code: 200")
        
        vcUnderTest.performQuery(for: "Texas Rangers") { (events, response, error) in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFavoritesAdd() {
        do {
            try FavoritesHelper.shared.add(fakeEvent)
        } catch let error {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        XCTAssert(FavoritesHelper.shared.isFavorite(fakeEvent), "Event was not added to favorites")
    }
    
    func testFavoritesRemove() {
        do {
            try FavoritesHelper.shared.remove(fakeEvent)
        } catch let error {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        XCTAssert(!FavoritesHelper.shared.isFavorite(fakeEvent), "Event was not removed from favorites")
    }
    
}
