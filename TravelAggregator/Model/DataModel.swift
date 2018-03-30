//
//  DataModel.swift
//  TravelAggregator
//
//  Created by doc on 30/03/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation
struct ErrorData{
    let errorTitle: String
    let errorMsg: String
}

struct TripData{
    let flightDescription: String // ex: Edinburgh to London
    let flightDates: String // ex: Mar 01., Wed – Mar 05., Sun
    let flightCounter: String // ex: 365 of 365 results shown
    let flightDataCards: [FlightDataCard]
}

struct FlightDataCard {
    let price: String
    var formattedPrice: String {
        return "£\(price)"
    }
    let isCheapest: Bool
    let isShortest: Bool
    var formattedCheapShort: String {
        let cheap = isCheapest ? "Cheapest" : ""
        let short = isShortest ? "Shortest" : ""
        return "\(cheap) \(short)"
    }
    let outboundFlight: FlightData
    let inboundFlight: FlightData
}

struct FlightData {
    let stops: String
    let departureTime: String
    let arrivalTime: String
    var displayedTime: String {
        return "\(departureTime) - \(arrivalTime)"
    }
    let duration: String
    let carrierId: Int // I need it as reference for caching the image
    let carrierName: String // ex: Flybe
    let carrierImageUrl: String
    let placeCodes: String // ex: EDI-LHR
    var displayedSegmentCarrier: String {
        return "\(placeCodes), \(carrierName)"
    }
}

struct SessionBody {
    let locationSchema: String
    let country: String
    let currency: String
    let locale: String
    let originplace: String
    let destinationplace: String
    let outbounddate: String
    let inbounddate: String
    let adults: String
    let apikey: String
}
