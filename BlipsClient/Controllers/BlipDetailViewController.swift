//
//  BlipDetailViewController.swift
//  BlipsClient
//
//  Created by Cyrus Sadeghi on 2018-02-09.
//  Copyright © 2018 Cyrus Sadeghi. All rights reserved.
//

import UIKit
import MapKit
import Cosmos

class BlipDetailViewController: UIViewController, UIPageViewControllerDataSource, BlipObserver {
    private var blip: Blip!
    private var blipPageViewController: UIPageViewController?
    var photoIndex: Int!

    @IBOutlet weak var blipTitle: UILabel!
    @IBOutlet weak var blipType: UILabel!
    @IBOutlet weak var blipRating: CosmosView!
    @IBOutlet weak var blipPrice: UILabel!
    @IBOutlet weak var blipDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blip.addObserver(observer: self)
        blip.loadImagesForMetadata()
        
        blipTitle.text = blip.title
        blipType.text = blip.attractionType
        
        if blip.rating > 0 {
            blipRating.rating = blip.rating
        } else {
            blipRating.isHidden = true
        }

        if blip.price > 0 {
            var priceText = ""
        
            for _ in 1...blip.price {
                priceText = priceText + "$"
            }
        
            blipPrice.text = priceText
        }
        
        setupPageControl()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        blipDescription.setContentOffset(CGPoint.zero, animated: false)
    }

    @IBAction func gotoMaps(_ sender: Any) {
        // add ability to save preferred transporation in user account then set it here - will need to pass user pref on class creation
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        blip.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    func setBlipAnnotation(annotation: BlipMarkerView) {
        self.blip = annotation.blip
    }
    
    // UIPageViewControllerDataSource methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let blipPhotoVC = viewController as! BlipPhotoViewController
        
        if blipPhotoVC.photoIndex > 0 {
            return getBlipPhotoVC(itemIndex: blipPhotoVC.photoIndex - 1)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let blipPhotoVC = viewController as! BlipPhotoViewController
        
        if blipPhotoVC.photoIndex + 1 < blip.photos.count {
            return getBlipPhotoVC(itemIndex: blipPhotoVC.photoIndex + 1)
        }
        
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return blip.photoMetadata.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.black
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
    }
    
    private func getBlipPhotoVC(itemIndex: Int) -> BlipPhotoViewController? {
        if itemIndex < blip.photos.count {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let photoVC = storyboard.instantiateViewController(withIdentifier: "blipPhotoVC") as! BlipPhotoViewController
            
            photoVC.photoIndex = itemIndex
            photoVC.setImage(newImage: blip.photos[itemIndex])
            
            return photoVC
        }
        
        return nil
    }
    
    // BlipObserver methods
    
    func photosReady() {
        let firstController = getBlipPhotoVC(itemIndex: 0)!
        let startingVC = [firstController]
        
        blipPageViewController?.setViewControllers(startingVC, direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
    }
    
    // Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? UIPageViewController {
            self.blipPageViewController = destinationVC
            blipPageViewController?.dataSource = self
        }
    }
}
