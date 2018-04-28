//
//  ViewController.swift
//  Project02
//
//  Created by Sebastian Suchanowski on 28/04/2018.
//  Copyright © 2018 Synappse. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapPreviewImageView: UIImageView!
    
    // keep this somewhere else so it would not die with this View Controller
    // as it would lost its function
    private let imageCache = NSCache<NSString, UIImage>()
    private static let imageCacheKey: NSString = "CachedMapSnapshot" // this should be object specific name
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func didTapLoadButton(_ sender: Any) {
        if mapPreviewImageView.image != nil {
            return
        }
        
        loadMapPreview()
    }
    
    private func loadMapPreview() {
        if let cachedImage = cachedImage() {
            mapPreviewImageView.image = cachedImage
            return
        }
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let coords = CLLocationCoordinate2D(latitude: 52.239647, longitude: 21.045845)
        let distanceInMeters: Double = 500
        
        let options = MKMapSnapshotOptions()
        options.region = MKCoordinateRegionMakeWithDistance(coords, distanceInMeters, distanceInMeters)
        options.size = mapPreviewImageView.frame.size
        
        let bgQueue = DispatchQueue.global(qos: .background)
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.start(with: bgQueue, completionHandler: { [weak self] (snapshot, error) in
            guard error == nil else {
                return
            }
            
            if let snapShotImage = snapshot?.image, let coordinatePoint = snapshot?.point(for: coords), let pinImage = UIImage(named: "pinImage") {
                UIGraphicsBeginImageContextWithOptions(snapShotImage.size, true, snapShotImage.scale)
                snapShotImage.draw(at: CGPoint.zero)
                // need to fix the point position to match the anchor point of pin which is in middle bottom of the frame
                let fixedPinPoint = CGPoint(x: coordinatePoint.x - pinImage.size.width / 2, y: coordinatePoint.y - pinImage.size.height)
                pinImage.draw(at: fixedPinPoint)
                let mapImage = UIGraphicsGetImageFromCurrentImageContext()
                if let unwrappedImage = mapImage {
                    self?.cacheImage(iamge: unwrappedImage)
                }
                DispatchQueue.main.async {
                    self?.mapPreviewImageView.image = mapImage
                    self?.activityIndicator.stopAnimating()
                    self?.activityIndicator.isHidden = true
                }
                UIGraphicsEndImageContext()
            }
        })
    }
    
    private func cacheImage(iamge: UIImage) {
        imageCache.setObject(iamge, forKey: ViewController.imageCacheKey)
    }
    
    private func cachedImage() -> UIImage? {
        return imageCache.object(forKey: ViewController.imageCacheKey)
    }
}
