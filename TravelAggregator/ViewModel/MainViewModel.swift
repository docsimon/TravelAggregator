//
//  MainViewModel.swift
//  TravelAggregator
//
//  Created by doc on 30/03/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation

protocol TravelModel: class {
    func updateUIWithFlightData(flights: TripData)
    func displayError(errorData: ErrorData)
    
}

enum WeekDays: Int {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

class MainViewModel {
    weak var delegate: TravelModel? = nil
    var tripData: TripData? {
        didSet {
            if let tripData = tripData {
                DispatchQueue.main.async {
                    self.delegate?.updateUIWithFlightData(flights: tripData)
                }
            }
        }
    }
    
    // this function calculates the outbound and inbound days
    // as per task requirements
    func tripDates(bookingDate: Date, outboundDay: WeekDays, inboundDay: WeekDays) -> (String, String){
        
        let calendar = Calendar(identifier: .gregorian)
        let currentDay = calendar.component(.weekday, from: bookingDate)
        
        let outboundDistance = outboundDay.rawValue - currentDay
        let outboundOffset = outboundDistance <= 0 ? outboundDistance + 7 : outboundDistance
        
        let inboundDistance = inboundDay.rawValue - outboundDay.rawValue
        let inboundOffset = inboundDistance <= 0 ? (inboundDistance + 7) + outboundOffset : inboundDistance + outboundOffset
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.DateFormat.yearMonthDay
        if let outboundDate = Calendar.current.date(byAdding: .day, value: outboundOffset, to: bookingDate),
            let inboundDate = Calendar.current.date(byAdding: .day, value: inboundOffset, to: bookingDate){
            
            let outboundDateString = formatter.string(from: outboundDate)
            let inboundDateString = formatter.string(from: inboundDate)
            
            return (outboundDateString, inboundDateString)
        }
        
        return ("","")
    }
    
    func fetchData(with bodyArray: [String]?){
        if let _ = delegate {
            let client = Client()
            let bodyArr = bodyArray?.joined(separator: "&")
            let body = bodyArr?.data(using: String.Encoding.utf8)
            let requestSessionData = RequestData(scheme: Constants.Client.scheme, baseUrl: Constants.Client.baseUrl, path: Constants.Client.sessionPath, httpMethod: "POST", httpBody: body, queryItems: nil)
            
            client.fetchRemoteData(request: requestSessionData, dataHandler: .sessionHandler, completion: { sessionUrl, errorData  in
                
                if let error = errorData {
                    self.delegate?.displayError(errorData: error)
                    return
                }
                // Call the Poll session (nested asyncronous call)
                let pollSessionUrl = URL(string: "\(sessionUrl as! String)?apikey=\(Constants.Apis.travelApi)")
                client.fetchRemoteData(request: pollSessionUrl!, dataHandler: .jsonHandler(DataParser.parseJson), completion: {sessionData, errorData  in
                    
                    if let error = errorData {
                        self.delegate?.displayError(errorData: error)
                        return
                    }
                    
                    let dataCardBuilder = DataCardBuilder(data: sessionData as! Flights)
                    let trips =  dataCardBuilder.buildFlightCards()
                    // Here I trigger the variable observer and inform the UI that data are
                    // available
                    self.tripData = trips
                })
                
            })
            
        }else {
            fatalError("Main view controller not set as delegate !!!")
        }
    }
    
    func fetchImage(with url: String, completionImage: @escaping CompletionClosure<Data>){
        if let _ = delegate {
            let client = Client()
            guard let requestSessionData = URL(string: url) else {
                self.delegate?.displayError(errorData: ErrorData(errorTitle: Constants.Errors.urlPageErrorTitle, errorMsg: Constants.Errors.urlPageErrorMsg))
                return
            }
            client.fetchRemoteData(request: requestSessionData, dataHandler: .imageHandler, completion: { imageData, errorData  in
                
                if let error = errorData {
                    self.delegate?.displayError(errorData: error)
                    return
                }
                completionImage(imageData as? Data, nil)
            })
            
        }else {
            fatalError("Main view controller not set as delegate !!!")
        }
}

}
