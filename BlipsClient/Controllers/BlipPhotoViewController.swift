//
//  BlipPhotoViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-11.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit

class BlipPhotoViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    private var image: UIImage = UIImage()

    var photoIndex: Int = 0
    
    override func viewDidLoad() {
        self.imageView.image = self.image
    }
    
    func setImage(newImage: UIImage) {
        self.image = newImage
    }
}
