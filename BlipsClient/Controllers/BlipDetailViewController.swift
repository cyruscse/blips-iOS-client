//
//  BlipDetailViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-09.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class BlipDetailViewController: UIViewController {
    private var blip: Blip!
    @IBOutlet weak var blipImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blipImage.image = blip.photo
    }

    func setBlipAnnotation(annotation: BlipMarkerView) {
        self.blip = annotation.blip
    }
}
