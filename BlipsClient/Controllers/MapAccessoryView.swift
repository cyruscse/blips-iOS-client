//
//  MapAccessoryView.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-16.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit

class MapAccessoryView: UIView, MapModelObserver {
    private var lastAlpha: CGFloat!
    private var originFrame: CGRect!
    private var setOriginFrame = false
    var animationTimer: Double!
    
    private func fadeHideView() {
        if self.alpha != 0 {
            self.lastAlpha = self.alpha
        }
        
        UIView.animate(withDuration: animationTimer) {
            self.alpha = 0
        }
        
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    private func fadeShowView() {
        self.isHidden = false
        self.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: animationTimer) {
            self.alpha = self.lastAlpha
        }
    }
    
    func asyncHide() {
        DispatchQueue.main.async {
            self.fadeHideView()
        }
    }
    
    func asyncShow() {
        DispatchQueue.main.async {
            self.fadeShowView()
        }
    }
    
    func makeVisible() {
        self.isHidden = false
        self.isUserInteractionEnabled = true
        self.alpha = self.lastAlpha
    }
    
    func annotationsUpdated(annotations: [MKAnnotation]) {
        DispatchQueue.main.async {            
            if annotations.count == 0 {
                self.fadeHideView()
            } else {
                if self.setOriginFrame == false {
                    self.setOriginFrame = true
                    self.originFrame = self.frame
                } else {
                    self.frame = self.originFrame
                }
                
                self.fadeShowView()
            }
        }
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {}
    
    func focusOnBlip(blip: Blip) {}
}
