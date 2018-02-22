//
//  MapRefreshButton.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-21.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class MapRefreshButton: UIButton {
    private var originFrame: CGRect!
    private var setOriginFrame = false
    var animationTimer: Double!
    
    func fadeShowView() {
        self.isHidden = false
        self.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: animationTimer) {
            self.alpha = 1.0
        }
    }
    
    func fadeHideView() {
        self.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: animationTimer, animations: {
            self.alpha = 0.0
        }) { (finished: Bool) in
            self.isHidden = true
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
    
    func asyncShow() {
        DispatchQueue.main.async {
            self.fadeShowView()
        }
    }
    
    func asyncHide() {
        DispatchQueue.main.async {
            self.fadeHideView()
        }
    }
}
