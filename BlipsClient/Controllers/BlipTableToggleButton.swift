//
//  BlipTableToggleButton.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-16.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit

class BlipTableToggleButton: UIButton, MapModelObserver {
    private var lastAlpha: CGFloat!
    private var originFrame: CGRect!
    private var setOriginFrame = false
    var viewsVisible: Bool = true
    var animationTimer: Double!
    
    func fadeShowView() {
        self.isHidden = false
        self.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: animationTimer) {
            self.alpha = self.lastAlpha
        }
    }
    
    func scrollView(scrollPosition: CGFloat) {
        var scrollPos = scrollPosition
        
        if scrollPos == 0.0 {
            scrollPos = originFrame.midY
        }
        
        UIView.animate(withDuration: animationTimer) {
            self.center.y = scrollPos
        }
    }
    
    func rotateButtonImage() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.animationTimer) {
                let transform = self.transform.rotated(by: CGFloat(Double.pi))
                
                self.transform = transform
            }
        }
    } 

    func annotationsUpdated(annotations: [MKAnnotation], updateType: UpdateType) {
        DispatchQueue.main.async {
            if self.setOriginFrame == false {
                self.setOriginFrame = true
                self.originFrame = self.frame
            }
            
            if annotations.count == 0 {
                self.alpha = 0.0
                self.lastAlpha = 1.0
            } else {
                self.frame = self.originFrame
                self.fadeShowView()
            }
        }
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {}
    
    func focusOnBlip(blip: Blip) {}
}
