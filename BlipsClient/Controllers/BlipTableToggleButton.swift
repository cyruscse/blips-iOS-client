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
    let fadeTimer: Double = 0.25
    
    private var lastAlpha: CGFloat!
    private var originFrame: CGRect!
    private var setOriginFrame = false
    var viewsVisible: Bool = true
    
    private func fadeHideView() {
        if self.alpha != 0 {
            self.lastAlpha = self.alpha
        }
        
        UIView.animate(withDuration: fadeTimer) {
            self.alpha = 0
        }
        
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    func fadeShowView() {
        self.isHidden = false
        self.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: fadeTimer) {
            self.alpha = self.lastAlpha
        }
    }
    
    func scrollView(scrollPosition: CGFloat) {
        var scrollPos = scrollPosition
        
        if scrollPos == 0.0 {
            scrollPos = originFrame.midY
        }
        
        UIView.animate(withDuration: fadeTimer) {
            self.center.y = scrollPos
        }
    }
    
    func rotateButtonImage() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.fadeTimer) {
                let transform = self.transform.rotated(by: CGFloat(Double.pi))
                
                self.transform = transform
            }
        }
    }

    func annotationsUpdated(annotations: [MKAnnotation]) {
        DispatchQueue.main.async {
            if self.setOriginFrame == false {
                self.setOriginFrame = true
                self.originFrame = self.frame
            }
            
            if annotations.count == 0 {
                self.fadeHideView()
            } else {
                self.frame = self.originFrame
                self.fadeShowView()
            }
        }
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {}
    
    func focusOnBlip(blip: Blip) {}
}
