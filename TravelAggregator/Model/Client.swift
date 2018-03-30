//
//  Client.swift
//  TravelAggregator
//
//  Created by doc on 30/03/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation
/*
 The responsibilities of the following class are:
 - Building the endpoint request/url and ensuring their validity
 - Managing all the error related to the connection
 - Fetching data from the remote endpoint
 */

// This closure will be used as a callback for Json data and pictures
typealias CompletionClosure<T> = ((T?, ErrorData?) -> ())

struct RequestData {
    let scheme: String
    let baseUrl: String
    let path: String?
    let httpMethod: String
    let httpBody: Data?
    let queryItems: [URLQueryItem]?
}


enum DataHandler {
    case jsonHandler(DataHandlerClosure)
    case sessionHandler
    case imageHandler
}

class Client {
    
    // Build the body
    private func makeBody<T: Codable>(bodyStructure: T) -> Data? {
        let jsonEncoder = JSONEncoder()
        let jsonPOSTData: Data?
        do {
            jsonPOSTData = try jsonEncoder.encode(bodyStructure)
        }catch{
            return nil
        }
        return jsonPOSTData
    }
    
    // Construct a valid URLRequest
    private func buildRequest(urlStruct: RequestData) -> URLRequest?{
        var urlComponents = URLComponents()
        urlComponents.scheme = urlStruct.scheme
        urlComponents.host = urlStruct.baseUrl
        
        if let path = urlStruct.path {
            urlComponents.path = path
        }
        if let queryItems = urlStruct.queryItems {
            urlComponents.queryItems = [URLQueryItem]()
            urlComponents.queryItems = queryItems
        }
        
        if let url = urlComponents.url {
            var request = URLRequest(url: url)
            if urlStruct.httpMethod == "POST" {
                request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.httpBody = urlStruct.httpBody
                request.httpMethod = urlStruct.httpMethod
            }
            
            return request
        }
        
        return nil
    }
    
    func fetchRemoteData(request: Any, dataHandler: DataHandler, completion: @escaping CompletionClosure<Any>){
        
        let urlRemoteRequest: URLRequest
        
        if let request = request as? RequestData {
            guard let urlRequest = buildRequest(urlStruct: request) else {
                let errorData = ErrorData(errorTitle: Constants.Errors.urlRequestErrorTitle, errorMsg: Constants.Errors.urlRequestErrorTitle)
                completion(nil, errorData)
                return
            }
            
            urlRemoteRequest = urlRequest
        }else {
            urlRemoteRequest = URLRequest(url: request as! URL)
        }
        
        // make the request
        URLSession.shared.dataTask(with: urlRemoteRequest, completionHandler: {(data, response, error) in
            
            // error checking
            guard (error == nil) else {
                let errorData = ErrorData(errorTitle: Constants.Errors.clientErrorTitle, errorMsg: (error?.localizedDescription) ?? "Error")
                completion(nil, errorData)
                return
                
            }
            // response checking
            let httpURLResponse = response as? HTTPURLResponse
            if let statusCode = httpURLResponse?.statusCode{
                guard (self.checkResponseCode(code: statusCode) == true) else {
                    let errorData = ErrorData(errorTitle: Constants.Errors.networkErrorTitle, errorMsg: "Status code: \(self.translateErrorResponseCode(code: statusCode))")
                    completion(nil, errorData)
                    return
                }
            }else {
                let errorData = ErrorData(errorTitle: Constants.Errors.networkErrorTitle, errorMsg: Constants.Errors.statusCodeUnknownMsg)
                completion(nil, errorData)
                return
            }
            // data checking
            guard let data = data else {
                let errorData = ErrorData(errorTitle: Constants.Errors.errorDataTitle, errorMsg: Constants.Errors.errorReceivingData)
                completion(nil, errorData)
                return
            }
            
            // send data to correct destination
            
            switch dataHandler {
            case .jsonHandler(let jsonFunctionHandler):
                let parsingResult = jsonFunctionHandler(data)
                completion(parsingResult.0, parsingResult.1)
            case .imageHandler:
                completion(data, nil)
            case .sessionHandler:
                if let sessionUrl = httpURLResponse?.allHeaderFields["Location"] as? String{
                    completion(sessionUrl, nil)
                }else{
                    let errorData = ErrorData(errorTitle: Constants.Errors.sessionErrorTitle, errorMsg: Constants.Errors.sessionErrorMsg)
                    completion(nil, errorData)
                    return
                }
            }
            
        }).resume()
        
    }
    
    private func checkResponseCode(code: Int) -> Bool {
        let successCode = [200, 201, 202, 203, 204, 304]
        return successCode.contains(code)
    }
    
    private func translateErrorResponseCode (code: Int) -> String {
        switch code {
        case 400:
            return Constants.Errors.HttpError.http400
        case 403:
            return Constants.Errors.HttpError.http403
        case 404:
            return Constants.Errors.HttpError.http404
        case 408:
            return Constants.Errors.HttpError.http408
        case 410:
            return Constants.Errors.HttpError.http410
        case 429:
            return Constants.Errors.HttpError.http429
        case 500:
            return Constants.Errors.HttpError.http500
        case 502:
            return Constants.Errors.HttpError.http502
        case 503:
            return Constants.Errors.HttpError.http503
        case 504:
            return Constants.Errors.HttpError.http504
        default:
            return " \(code) \(Constants.Errors.HttpError.generic)"
        }
    }
    
}
