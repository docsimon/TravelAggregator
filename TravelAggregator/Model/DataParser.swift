//
//  DataParser.swift
//  TravelAggregator
//
//  Created by doc on 30/03/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation
typealias DataHandlerClosure = (Data) -> (Flights?, ErrorData?)


struct Flights: Codable {
    let query: FlightQuery
    let itineraries: [FlightSingleItinerary]
    let legs: [FlightSingleLeg]
    let segments: [FlightSegments]
    let carriers: [FlightSingleCarrier]
    let places: [FlightPlace]
    // used CodingKey protocol to map the Capital letter parameter to lowercase ones (which is more swifty)
    enum CodingKeys: String, CodingKey {
        case query = "Query"
        case itineraries = "Itineraries"
        case legs = "Legs"
        case segments = "Segments"
        case carriers = "Carriers"
        case places = "Places"
    }
}

// Query
struct FlightQuery: Codable {
    let originPlace: String
    let destinationPlace: String
    let outboundDate: String
    let inboundDate: String
    
    enum CodingKeys: String, CodingKey {
        case originPlace = "OriginPlace"
        case destinationPlace = "DestinationPlace"
        case outboundDate = "OutboundDate"
        case inboundDate = "InboundDate"
    }
}

// Itineraries
struct FlightSingleItinerary: Codable {
    let outboundLegId: String
    let inboundLegId: String
    let pricingOptions: [FlightSinglePricingOption]
    
    enum CodingKeys: String, CodingKey {
        case outboundLegId = "OutboundLegId"
        case inboundLegId = "InboundLegId"
        case pricingOptions = "PricingOptions"
    }
}
struct FlightSinglePricingOption: Codable {
    let price: Double
    
    enum CodingKeys: String, CodingKey {
        case price = "Price"
    }
}

// Legs
struct FlightSingleLeg: Codable {
    let id: String
    let stops: [Int]
    let duration: Int
    let carriers: [Int] // as per task requirements, use only the first one
    let directionality: String // don't really need it, but it's better to double check
    let segmentIds: [Int]
    let originStation: Int
    let destinationStation: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case stops = "Stops"
        case duration = "Duration"
        case carriers = "Carriers"
        case directionality = "Directionality"
        case segmentIds = "SegmentIds"
        case originStation = "OriginStation"
        case destinationStation = "DestinationStation"
    }
}

// Segments
struct FlightSegments: Codable {
    let id: Int
    let departureDateTime: String
    let arrivalDateTime: String
    let carrier: Int
    let duration: Int
    let directionality: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case departureDateTime = "DepartureDateTime"
        case arrivalDateTime = "ArrivalDateTime"
        case carrier = "Carrier"
        case duration = "Duration"
        case directionality = "Directionality"
    }
}

// Carriers
struct FlightSingleCarrier: Codable {
    let id: Int
    let name: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case imageUrl = "ImageUrl"
    }
}

// Places
struct FlightPlace: Codable {
    let id: Int
    let code: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case code = "Code"
        case name = "Name"
    }
}

class DataParser {
    static func parseJson(data: Data) -> (Flights?, ErrorData?){
        let jsonDecoder = JSONDecoder()
        var flights: Flights? = nil
        do {
            flights = try jsonDecoder.decode(Flights.self, from: data)
        }catch {
            let errorData = ErrorData(errorTitle: Constants.Errors.errorDataTitle, errorMsg: error.localizedDescription)
            return (nil, errorData)
        }
        return (flights, nil)
    }
}

