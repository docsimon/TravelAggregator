//
//  Constants.swift
//  TravelAggregator
//
//  Created by doc on 30/03/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation

import UIKit

struct Constants {
    
    struct Urls {
        static let website = "http:///apiservices/"
    }
    
    struct Client {
        static let scheme = "https"
        static let baseUrl = ""
        static let path = "/apiservices"
        static let sessionPath = "/apiservices/pricing/v1.0"
    }
    
    struct Errors {
        
        static let clientErrorTitle = "Client Error"
        static let networkErrorTitle = "Network Error"
        static let errorDataTitle = "Data Error"
        static let errorParsingData = "Error parsing data"
        static let jsonHandlerErrorTitle = "Json handler Error"
        static let jsonHandlerErrorMsg = "The Json handler is nil"
        static let urlRequestErrorTitle = "URLRequest Error"
        static let urlRequestErrorMsg = "URLRequest is empty"
        static let urlPageErrorTitle = "No url"
        static let urlPageErrorMsg = "No web page availble for this event"
        static let sessionErrorTitle =  "Authentication Failed"
        static let sessionErrorMsg = "Impossible fetching session url"
        static let statusCodeUnknownMsg = "Status code unknown"
        static let errorReceivingData = "Error receiving data"
        
        struct HttpError {
            static let http400 = "Bad Request – Input validation failed."
            static let http403 = "Forbidden – The API Key was not supplied, or it was invalid, or it is not authorized to access the service."
            static let http404 = "Code 404: Not Found"
            static let http408 =  "Code 408: Request Timeout"
            static let http410 = "Gone – the session has expired. A new session must be created."
            static let http429 =  "Too Many Requests – There have been too many requests in the last minute."
            static let http500 = "Server Error – An internal server error has occurred which has been logged."
            static let http502 =  "Code 502: Bad Gateway"
            static let http503 = "Code 503: Service Unavailable"
            static let http504 =  "Code 504: Gateway Timeout"
            static let generic =  "Generic network error"
        }
    }
    
    
    struct Apis {
        static let travelApi = ""
    }
    
    struct Descriptions {
        static let noStops = "Direct"
    }
    
    struct DateFormat {
        static let yearMonthDay = "yyyy-MM-dd"
        static let ISO8601DateTime = "yyyy-MM-dd'T'HH:mm:ss"
        static let hoursMinutes = "HH:mm"
        static let monthDayNames = "MMM dd., EEE"
        
    }
    
    struct UIViews {
        struct CollectionViewCellSize{
            static let cellHeight: CGFloat = 194
            static let cellSpace: CGFloat = 5
        }
        struct  ErrorView {
            static let dismissButton = "Dismiss"
            static let reloadButton = "Reload"
        }
    }
    
}
