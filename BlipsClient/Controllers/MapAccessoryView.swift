//
//  MapAccessoryView.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-16.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit

enum AccessoryAnimationType {
    case fade
    case scroll
}

class MapAccessoryView: UIView, MapModelObserver {
    let fadeTimer: Double = 0.25
    
    private var lastAlpha: CGFloat!
    private var originFrame: CGRect!
    private var setOriginFrame = false
    var heightConstraint: NSLayoutConstraint?
    
    private func fadeHideView() {
        if self.alpha != 0 {
            self.lastAlpha = self.alpha
        }
        
        //heightConstraint?.constant -= 25
        
        UIView.animate(withDuration: fadeTimer) {
            self.alpha = 0
        }
        
        self.isHidden = true
        self.isUserInteractionEnabled = false
    }
    
    private func scrollHideView(scrollPosition: CGFloat) {
        UIView.animate(withDuration: fadeTimer, delay: 0.0, options: [], animations: {
            self.center.y = scrollPosition
            self.frame.size.height = self.originFrame.size.height
        }, completion: { (finished: Bool) in
            self.isHidden = true
            self.isUserInteractionEnabled = false
        })
    }
    
    private func fadeShowView() {
        self.isHidden = false
        self.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: fadeTimer) {
            self.alpha = self.lastAlpha
        }
    }
    
    private func scrollShowView(scrollPosition: CGFloat) {
        self.isHidden = false
        self.isUserInteractionEnabled = true
        
        self.alpha = self.lastAlpha
        self.frame.size.height = self.originFrame.size.height
        
        UIView.animate(withDuration: fadeTimer) {
            self.center.y = scrollPosition
        }
    }
    
    func asyncHide(animationType: AccessoryAnimationType, scrollPosition: CGFloat) {
        DispatchQueue.main.async {
            if animationType == AccessoryAnimationType.fade {
                self.fadeHideView()
            } else if animationType == AccessoryAnimationType.scroll {
                self.scrollHideView(scrollPosition: scrollPosition)
            }
        }
    }
    
    func asyncShow(animationType: AccessoryAnimationType) {
        DispatchQueue.main.async {
            if animationType == AccessoryAnimationType.fade {
                self.fadeShowView()
            } else if animationType == AccessoryAnimationType.scroll {
                self.scrollShowView(scrollPosition: self.originFrame.midY)
            }
        }
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
