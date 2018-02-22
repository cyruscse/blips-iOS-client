//
//  MapRefreshButton.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-21.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class MapRefreshButton: UIButton {
    private var lastAlpha: CGFloat!
    private var originFrame: CGRect!
    private var setOriginFrame = false
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
}
