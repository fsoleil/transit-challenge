//
// Created by Florian Soleil on 2017-08-16.
// Copyright (c) 2017 True Key. All rights reserved.
//

import Foundation

public final class URLSessionMock: URLSession {

    var url: URL?
    var request: URLRequest?
    private let dataTaskMock: URLSessionDataTaskMock

    public init(data: Data?, response: URLResponse?, error: NSError?) {
        dataTaskMock = URLSessionDataTaskMock()
        dataTaskMock.taskResponse = (data, response, error)
    }

    override public func dataTask(
        with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

        self.request = request
        self.dataTaskMock.completionHandler = completionHandler
        return self.dataTaskMock
    }

    public func dataTaskForRequest(
        request: NSURLRequest,
        completionHandler: @escaping (Data?, URLResponse?, NSError?) -> Void) -> URLSessionDataTask {

        return self.dataTaskMock
    }

    final private class URLSessionDataTaskMock: URLSessionDataTask {

        typealias CompletionHandler = (Data?, URLResponse?, NSError?) -> Void
        var completionHandler: CompletionHandler?
        var taskResponse: (Data?, URLResponse?, NSError?)?

        override func resume() {
            completionHandler?(taskResponse?.0, taskResponse?.1, taskResponse?.2)
        }
    }
}
