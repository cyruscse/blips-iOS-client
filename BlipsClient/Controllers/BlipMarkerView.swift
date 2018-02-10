//
//  BlipMarkerView.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-04.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import Foundation
import MapKit
import SDWebImage

class BlipMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let blip = newValue as? Blip else { return }
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
            imageView.sd_setImage(with: blip.icon) { (_, _, _, _) in }
            imageView.contentMode = .scaleAspectFit
            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            leftCalloutAccessoryView = imageView
        }
    }
}
