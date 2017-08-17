//
//  PatientClientTest.swift
//  dialogue-api
//
//  Created by Florian Soleil on 2017-08-06.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//


import XCTest
import SwiftyJSON
import PromiseKit
@testable import dialogue_api

class PatientClientTest: XCTestCase {
    
    var urlTest: URL = URL(string: "www.example.com")!
    internal var dialogueWebServiceConfiguration: DialogueWebServiceConfiguration!
    internal var patient:Patient!
    
    override func setUp() {
        super.setUp()
        
        // webservice configuration
        self.dialogueWebServiceConfiguration = DialogueWebServiceConfiguration(withBaseUrl: URL(string: "www.test.com")!)
        self.patient = try! Patient(withEmail: "bob@test.com",
                                   firstName: "bob",
                                   lastName: "smith",
                                   birthdate: "1999-09-13",
                                   sex: "m")
        
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
    
    func testpatientFound() {
        
        let path = Bundle(for: type(of: self)).path(forResource: "patient-found", ofType: "json")
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 200, responsePath: path)!
        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        firstly {
            try patientClient.patientProfile( withPatientId : "1")
            
            }.then { ( response: PatientResult) -> Void in
                switch response {
                case .found(let patient):
                    
                    // format date
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let date = dateFormatter.date(from: "1980-09-03")
                    
                    XCTAssertEqual(patient.email, "test@test.com")
                    XCTAssertEqual(patient.firstName,"jhon")
                    XCTAssertEqual(patient.lastName,"legend")
                    XCTAssertEqual(patient.birthdate,date)
                    XCTAssertEqual(patient.sex,"m")
                    
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
    
    func testpatientNotFound() {
        
        let path = Bundle(for: type(of: self)).path(forResource: "errors", ofType: "json")
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 404, responsePath: path)!
        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        firstly {
            try patientClient.patientProfile( withPatientId : "1")
            
            }.then { ( response: PatientResult) -> Void in
                switch response {
                case .notFound:
                    break
                default:
                    XCTFail()
                    break
                }
            }.always {
                expect.fulfill()
            }.catch { _ in
                XCTFail()
        }
        
        wait(for: [expect], timeout: 2)
        
    }
    
    func testpatientFailed() {
        
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 500)!
        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        firstly {
            try patientClient.patientProfile( withPatientId : "1")
            
            }.then { ( _: PatientResult) -> Void in
                
                XCTFail()
                
            }.always {
                expect.fulfill()
            }.catch { error in
                switch error {
                case WebServiceClientError.unknownError: break
                default: XCTFail()
                }
        }
        
        wait(for: [expect], timeout: 2)
        
    }
    
    func testCreatePatient() {
        
        let path = Bundle(for: type(of: self)).path(forResource: "patient-created", ofType: "json")
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 200, responsePath: path)!
        
        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        
        firstly {
            try patientClient.createPatient( withPatientList:[self.patient])
            
            }.then { ( response: CreatePatientResult) -> Void in
                switch response {
                case .success:
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
    
    func testCreatePatientAlreadyExists() {
        
        let path = Bundle(for: type(of: self)).path(forResource: "errors", ofType: "json")
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 409, responsePath: path)!

        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        firstly {
            try patientClient.createPatient( withPatientList : [self.patient])
            
            }.then { ( response: CreatePatientResult) -> Void in
                switch response {
                case .patientExist:
                    break
                default:
                    XCTFail()
                    break
                }
            }.always {
                expect.fulfill()
            }.catch { _ in
                XCTFail()
        }
        
        wait(for: [expect], timeout: 2)
        
    }
    
    func testCreatePatientRequestError() {
        
        let path = Bundle(for: type(of: self)).path(forResource: "errors", ofType: "json")
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 400, responsePath: path)!
        
        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        firstly {
            try patientClient.createPatient( withPatientList : [self.patient])
            
            }.then { ( response: CreatePatientResult) -> Void in
                switch response {
                case .requestError:
                    break
                default:
                    XCTFail()
                    break
                }
            }.always {
                expect.fulfill()
            }.catch { _ in
                XCTFail()
        }
        
        wait(for: [expect], timeout: 2)
        
    }
    
    func testCreatePatientError() {
        
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 500)!
        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        firstly {
            try patientClient.createPatient( withPatientList : [self.patient])
            
            }.then { ( _: CreatePatientResult) -> Void in
                
                XCTFail()
                
            }.always {
                expect.fulfill()
            }.catch { error in
                switch error {
                case WebServiceClientError.unknownError: break
                default: XCTFail()
                }
        }
        
        wait(for: [expect], timeout: 2)
        
    }
    
    
    func testPatientList() {
        
        let path = Bundle(for: type(of: self)).path(forResource: "patient-list", ofType: "json")
        let webServiceClient = self.mockWebServiceClient(withResponseStatusCode: 200, responsePath: path)!
        
        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        
        firstly {
            try patientClient.patientList()
            
            }.then { ( response: PatientListResult) -> Void in
                switch response {
                case .success(patientList: let patientList, currentLink: let currentLint, nextLink: let nextLink):
                    XCTAssertEqual(patientList.count, 1)
                    XCTAssertEqual(currentLint!.description, "http://www.self.com")
                    XCTAssertEqual(nextLink!.description, "http://www.next.com")
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
        
        let patientClient = DefaultPatientClient(
            withWebServiceClient: webServiceClient,
            webServiceConfiguration: self.dialogueWebServiceConfiguration
        )
        
        let expect = expectation(description: "...")
        
        firstly {
            try patientClient.patientList()
            
            }.then { ( response: PatientListResult) -> Void in
                switch response {
                case .failed(_):
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
