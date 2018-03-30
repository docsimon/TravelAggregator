//
//  DataCardBuilder.swift
//  TravelAggregator
//
//  Created by doc on 30/03/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import Foundation
class DataCardBuilder {
    let dataFlights: Flights
    
    init(data: Flights){
        dataFlights = data
    }
    
    func buildFlightCards() -> TripData{
        let bestRoute = shortestRoute()
        let bestPrice = cheapestPrice()
        let tripDescription =
        "\(findPlace(place: dataFlights.query.originPlace).1) to \(findPlace(place: dataFlights.query.destinationPlace).1)"
        let tripDates = "\(set(tripDate: dataFlights.query.outboundDate)) - \(set(tripDate: dataFlights.query.inboundDate))"
        let fCount = dataFlights.itineraries.count // number of itineraries
        let flightCounter = "\(fCount) out of \(fCount) results shown"
        
        var flightDataCards = [FlightDataCard]()
        
        for itinerary in dataFlights.itineraries {
            
            // Building up the flight card
            // that resembles the FlightDataCard struct
            
            // Define itinerary overhead variables
            let isBestPrice = itinerary.pricingOptions[0].price <= bestPrice
            let price = String(itinerary.pricingOptions[0].price)
            var inboundFlight: FlightData
            var outboundFlight: FlightData
            
            // Extract legs
            let outboundLeg = dataFlights.legs.filter{ $0.id == itinerary.outboundLegId }[0]
            let inboundLeg = dataFlights.legs.filter{ $0.id == itinerary.inboundLegId }[0]
            
            let isShortestRoute = (inboundLeg.duration + outboundLeg.duration) <= bestRoute
            
            outboundFlight = buildLegs(leg: outboundLeg)
            inboundFlight = buildLegs(leg: inboundLeg)
            let flightCard = FlightDataCard(price: price, isCheapest: isBestPrice, isShortest: isShortestRoute, outboundFlight: outboundFlight, inboundFlight: inboundFlight)
            
            flightDataCards.append(flightCard)
            
        }
        
        let tripData = TripData(flightDescription: tripDescription, flightDates: tripDates, flightCounter: flightCounter, flightDataCards: flightDataCards)
        
        return tripData
    }
    
}

// MARK: Utility methods
extension DataCardBuilder {
    
    // returns the Code of the Airport (ex: EDI) and the name of the City
    private func findPlace(place: String) -> (String,String){
        let flightPlaces = dataFlights.places
        let place = flightPlaces.filter { $0.id == Int(place)!}[0]
        return (place.code, place.name)
    }
    
    private func cheapestPrice() -> Double{
        let itineraries = dataFlights.itineraries
        let prices = itineraries.map {$0.pricingOptions[0]}
        let cheapestPrice = prices.sorted(by: {$0.price < $1.price})[0].price
        return cheapestPrice
    }
    
    private func shortestRoute() -> Int{
        // I would consider as shortest route the sum of the duration of the two legs
        let itineraries = dataFlights.itineraries
        let legsDuration = itineraries.map {itinerary -> Int in
            let outLeg = dataFlights.legs.filter {$0.id == itinerary.outboundLegId}[0].duration
            let inLeg = dataFlights.legs.filter {$0.id == itinerary.inboundLegId}[0].duration
            return (outLeg + inLeg)
        }
        
        let orderedDurations = legsDuration.sorted(by: {$0 < $1})[0]
        
        return orderedDurations
    }
    
    private func buildLegs(leg: FlightSingleLeg) -> FlightData {
        // let find sub structs (Segments, Carriers)
        let segment = dataFlights.segments.filter{ $0.id == leg.segmentIds[0]}[0]
        let carrier = dataFlights.carriers.filter{ $0.id == leg.carriers[0]}[0]
        let placeOrigin = dataFlights.places.filter{ $0.id == leg.originStation}[0]
        let placeDestination = dataFlights.places.filter{ $0.id == leg.destinationStation}[0]
        let stops = leg.stops.count == 0 ? Constants.Descriptions.noStops : "\(leg.stops.count) stops"
        let duration = convert(timeInMinutes: leg.duration)
        let carrierId = carrier.id
        let carrierName = carrier.name
        let carrierImageUrl = carrier.imageUrl
        let departureTime = convert(dateValue: segment.departureDateTime, inputFormat: Constants.DateFormat.ISO8601DateTime, outputFormat: Constants.DateFormat.hoursMinutes)
        let arrivalTime = convert(dateValue: segment.arrivalDateTime, inputFormat: Constants.DateFormat.ISO8601DateTime, outputFormat: Constants.DateFormat.hoursMinutes)
        let placeCodes = "\(placeOrigin.code)-\(placeDestination.code)"
        
        let flightLeg = FlightData(stops: stops, departureTime: departureTime, arrivalTime: arrivalTime, duration: duration, carrierId: carrierId, carrierName: carrierName, carrierImageUrl: carrierImageUrl, placeCodes: placeCodes)
        
        return flightLeg
    }
    
    private func convert(timeInMinutes: Int) -> String {
        let hours = timeInMinutes/60
        let minutes = timeInMinutes%60
        let formattedH = hours == 0 ? "" : "\(hours)h "
        let formattedM = "\(minutes)m"
        
        let formattedTime = formattedH + formattedM
        
        return formattedTime
    }
    
    private func convert(dateValue: String, inputFormat: String, outputFormat: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = inputFormat//
        let date = formatter.date(from: dateValue)
        formatter.dateFormat = outputFormat//
        if let date = date {
            return  formatter.string(from: date)
        }
        return "N/A"
    }
    
    private func set(tripDate: String)-> String{
        let formattedDate = convert(dateValue: tripDate, inputFormat: Constants.DateFormat.yearMonthDay, outputFormat: Constants.DateFormat.monthDayNames)
        return formattedDate
    }
}
