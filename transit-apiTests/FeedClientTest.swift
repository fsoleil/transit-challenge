//
//  PatientClientTest.swift
//  dialogue-api
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import Transit

class FeedClientTest: XCTestCase {
    
    var urlTest: URL = URL(string: "www.example.com")!
    internal var transitWebServiceConfiguration: TransitWebServiceConfiguration!
    
    override func setUp() {
        super.setUp()
        
        // webservice configuration
        self.transitWebServiceConfiguration = TransitWebServiceConfiguration(withBaseUrl: URL(string: "www.test.com")!)
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func mockWebServiceClient(
        withResponseStatusCode responseStatusCode: Int,
        responsePath: String? = nil,
        error: NSError? = nil
        ) -> WebServiceClient? {
        
        let response = HTTPURLResponse(url: self.urlTest, statusCode: responseStatusCode, httpVersion: "v1.0", headerFields: [:])
        var urlSession: URLSessionMock
        
        if responsePath != nil {
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: responsePath!)) else {
                XCTFail()
                return nil
            }
            urlSession = URLSessionMock(data: data, response: response, error: error)
        } else {
            urlSession = URLSessionMock(data: nil, response: response, error: error)
        }
        
        let webService = DefaultWebServiceClient(withURLSession: urlSession)
        
        return webService
    }
    
    func testFeedsList() {
        
        let path = Bundle(for: type(of: self)).path(forResource: "feeds-list", ofType: "json")
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 200, responsePath: path)!
        
        let feedClient = DefaultFeedClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.transitWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        
        firstly {
            try feedClient.feedsList()
            
            }.then { ( response: FeedsListResult) -> Void in
                switch response {
                case .success(feedsList:let feedsList):
                    XCTAssertEqual(feedsList.count, 64)
                    break
                default:
                    XCTFail()
                    break
                }
            }.always {
                expect.fulfill()
            }.catch { error in
                print(error.localizedDescription)
                XCTFail()
        }
        
        wait(for: [expect], timeout: 2)
        
    }
    
    func testPatientListFailed() {
        
        let path = Bundle(for: type(of: self)).path(forResource: "errors", ofType: "json")
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 400, responsePath: path)!
        
    
        let feedClient = DefaultFeedClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.transitWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        
        firstly {
             try feedClient.feedsList()
            
            }.then { ( response: FeedsListResult) -> Void in
                switch response {
                case .error(_):
                    break
                default:
                    XCTFail()
                    break
                }
            }.always {
                expect.fulfill()
            }.catch { error in
                print(error.localizedDescription)
                XCTFail()
        }
        
        wait(for: [expect], timeout: 2)
        
    }
}
