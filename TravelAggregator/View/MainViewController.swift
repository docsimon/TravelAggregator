//
//  MainViewController.swift
//  TravelAggregator
//
//  Created by doc on 30/03/2018.
//  Copyright © 2018 Simone Barbara. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let viewModel = MainViewModel()
    var tripData: TripData? = nil
    var imageCache = [Int:Data]()
    var errorManager = ErrorManager()
    @IBOutlet weak var flightsCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flightCounter: UILabel!
    @IBOutlet weak var flightDates: UILabel!
    @IBOutlet weak var tripLocations: UILabel!
    @IBOutlet weak var travelBg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        errorManager.delegate = self
        setFlowLayout()
        viewModel.delegate = self
        fetchRemoteData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: viewModel protocol implementation
extension MainViewController: TravelModel {
    
    func displayError(errorData: ErrorData){
        errorManager.displayError(errorTitle: errorData.errorTitle, errorMsg: errorData.errorMsg)
    }
    
    // Here the view gets updated from the viewModel
    func updateUIWithFlightData(flights: TripData) {
        activityIndicator.stopAnimating()
        travelBg.isHidden = true
        tripData = flights
        setTripValues(description: flights.flightDescription, dates: flights.flightDates, count: flights.flightCounter)
        flightsCollectionView.reloadData()
    }
}

extension MainViewController: ErrorControllerProtocol {
    
    func dismissActivityControl() {
        activityIndicator.stopAnimating()
    }
    
    func presentError(alertController: UIAlertController){
        present(alertController, animated: true)
    }
    
    func fetchData(){
        fetchRemoteData()
    }
}

// MARK: Fetching data
extension MainViewController {
    func fetchRemoteData(){
        let dates = viewModel.tripDates(bookingDate: Date(), outboundDay: .monday, inboundDay: .tuesday)
        let sessionBody = SessionBody(locationSchema: "iata", country: "UK", currency: "GBP", locale: "en-GB", originplace: "EDI-sky", destinationplace: "LOND-sky", outbounddate: dates.0, inbounddate: dates.1, adults: "1", apikey: Constants.Apis.travelApi)
        let bodyArray = [
            "locationSchema=\(sessionBody.locationSchema)",
            "country=\(sessionBody.country)",
            "currency=\(sessionBody.currency)",
            "locale=\(sessionBody.locale)",
            "originplace=\(sessionBody.originplace)",
            "destinationplace=\(sessionBody.destinationplace)",
            "outbounddate=\(sessionBody.outbounddate)",
            "inbounddate=\(sessionBody.inbounddate)",
            "adults=\(sessionBody.adults)",
            "apikey=\(sessionBody.apikey)"
        ]
        viewModel.fetchData(with: bodyArray)
    }
}
// MARK: Implementing CollectionView delegate methods and flow layout
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tripData?.flightDataCards.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "flightCard", for: indexPath) as? FlightCardCollectionViewCell, let tripData = tripData else {
            return UICollectionViewCell()
        }
        
        let card = tripData.flightDataCards[indexPath.row]
        cell.set(card: card)
        
        // fetching the carrier image
        // in this case the binding between the view and the viewModel occurs via closure callback
        self.updateImage(leg: card.outboundFlight){ data, error in
            if let data = data{
                DispatchQueue.main.async {
                    cell.set(carrierOutboundImage: data)
                }
            }
        }
        self.updateImage(leg: card.inboundFlight){ data, error in
            if let data = data{
                DispatchQueue.main.async {
                    cell.set(carrierInboundImage: data)
                }
            }
        }
        return cell
    }
    
    private func updateImage(leg: FlightData, completion: @escaping CompletionClosure<Data>){
        if let cache = imageCache[leg.carrierId] {
            completion(cache, nil)
        }else{
            let imageUrl = leg.carrierImageUrl
            viewModel.fetchImage(with: imageUrl) { data, error in
                if error == nil, let data = data {
                    self.imageCache[leg.carrierId] = data
                    completion(data, nil)
                }else{
                    completion(nil, error)
                }
            }
        }
    }
    
    private func setFlowLayout(){
        let space:CGFloat = Constants.UIViews.CollectionViewCellSize.cellSpace
        let width = view.frame.size.width
        let height = Constants.UIViews.CollectionViewCellSize.cellHeight
        
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.minimumLineSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    private func setTripValues(description: String, dates: String, count: String){
        tripLocations.text = description
        flightDates.text = dates
        flightCounter.text = count
    }
}
