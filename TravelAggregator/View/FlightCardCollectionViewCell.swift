//
//  FlightCardCollectionViewCell.swift
//  TravelAggregator
//
//  Created by doc on 30/03/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit

class FlightCardCollectionViewCell: UICollectionViewCell {
    
    // outbound leg data
    @IBOutlet private weak var carrierOutboundImage: UIImageView!
    @IBOutlet private weak var outboundTime: UILabel!
    @IBOutlet private weak var outboundSegmentCarrier: UILabel!
    @IBOutlet private weak var outboundStops: UILabel!
    @IBOutlet private weak var outboundDuration: UILabel!
    
    // inbound leg data
    @IBOutlet private weak var carrierInboundImage: UIImageView!
    @IBOutlet private weak var inboundTime: UILabel!
    @IBOutlet private weak var inboundSegmentCarrier: UILabel!
    @IBOutlet private weak var inboundStops: UILabel!
    @IBOutlet private weak var inboundDuration: UILabel!
    
    // itinerary data
    @IBOutlet private weak var smileImage: UIImageView!
    @IBOutlet private weak var itineraryScore: UILabel!
    @IBOutlet private weak var itineraryTop: UILabel!
    @IBOutlet private weak var itineraryPrice: UILabel!
    @IBOutlet private weak var itineraryNote: UILabel!
    
    //  Image setting
    func set(carrierOutboundImage withValue: Data){
        carrierOutboundImage.image = UIImage(data: withValue)
    }
    func set(carrierInboundImage withValue: Data){
        carrierInboundImage.image = UIImage(data: withValue)
    }
    func set(smileImage withValue: Data){
        smileImage.image = UIImage(data: withValue)
    }
    
    func set(card: FlightDataCard){
        //outbound leg
        outboundTime.text = card.outboundFlight.displayedTime
        outboundSegmentCarrier.text = card.outboundFlight.displayedSegmentCarrier
        outboundStops.text = card.outboundFlight.stops
        outboundDuration.text = card.outboundFlight.duration
        
        //inbound leg
        inboundTime.text = card.inboundFlight.displayedTime
        inboundSegmentCarrier.text = card.inboundFlight.displayedSegmentCarrier
        inboundStops.text = card.inboundFlight.stops
        inboundDuration.text = card.inboundFlight.duration
        
        //itinerary
        itineraryScore.text = "10"
        itineraryPrice.text = card.formattedPrice
        itineraryTop.text = card.formattedCheapShort
    }
}

