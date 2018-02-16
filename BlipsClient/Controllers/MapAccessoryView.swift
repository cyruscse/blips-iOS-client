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
    
    private func hideView() {
        if self.alpha != 0 {
            self.lastAlpha = self.alpha
        }
        
        self.alpha = 0
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    private func showView() {
        self.isHidden = false
        self.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = self.lastAlpha
        })
    }
    
    func asyncHide() {
        DispatchQueue.main.async {
            self.hideView()
        }
    }
    
    func asyncShow() {
        DispatchQueue.main.async {
            self.showView()
        }
    }
    
    func annotationsUpdated(annotations: [MKAnnotation]) {
        DispatchQueue.main.async {            
            if annotations.count == 0 {
                self.hideView()
            } else {
                if self.setOriginFrame == false {
                    self.setOriginFrame = true
                    self.originFrame = self.frame
                } else {
                    self.frame = self.originFrame
                }
                
                self.showView()
            }
        }
    }
    
    func locationUpdated(location: CLLocationCoordinate2D, latitudinalMeters: CLLocationDistance, longitudinalMeters: CLLocationDistance) {}
    
    func focusOnBlip(blip: Blip) {}
}
