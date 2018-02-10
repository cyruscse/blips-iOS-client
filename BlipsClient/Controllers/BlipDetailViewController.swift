//
//  BlipDetailViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-09.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit
import Cosmos

class BlipDetailViewController: UIViewController {
    private var blip: Blip!
    
    @IBOutlet weak var blipImage: UIImageView!
    @IBOutlet weak var blipTitle: UILabel!
    @IBOutlet weak var blipType: UILabel!
    @IBOutlet weak var blipRating: CosmosView!
    @IBOutlet weak var blipPrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blipTitle.text = blip.title
        blipType.text = blip.attractionType
        blipRating.rating = blip.rating
        blipImage.image = blip.photo
        
        if blip.price > 0 {
            var priceText = ""
        
            for _ in 1...blip.price {
                priceText = priceText + "$"
            }
        
            blipPrice.text = priceText
        } else {
            blipPrice.text = ""
        }
    }

    @IBAction func gotoMaps(_ sender: Any) {
        // add ability to save preferred transporation in user account then set it here - will need to pass user pref on class creation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        blip.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    func setBlipAnnotation(annotation: BlipMarkerView) {
        self.blip = annotation.blip
    }
}
