//
//  DetailViewController.swift
//  HomeAwayCodingChallenge
//
//  Created by Andrew Whitehead on 9/11/18.
//  Copyright © 2018 Andrew Whitehead. All rights reserved.
//

import UIKit
import AlamofireImage

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    
    var imageCache: AutoPurgingImageCache? //passed down from MasterViewController in prepare(for segue:)
    
    
    var event: Event? {
        didSet {
            configureView()
        }
    }
    

    func configureView() {
        //update the user interface for the event
        
        guard let event = self.event else {
            navigationItem.rightBarButtonItem = nil
            
            return
        }
        
        self.title = event.title
        
        //use AlamofireImage to asynchronously fetch image and then cache
        if let imageView = self.imageView {
            if let cachedImage = imageCache?.image(withIdentifier: String(event.id)) {
                imageView.image = cachedImage
            } else if let imageURL = event.performers?.first?.imageURL {
                imageView.af_setImage(withURL: imageURL, placeholderImage: #imageLiteral(resourceName: "placeholder")) { [weak self] (dataResponse) in
                    if let image = self?.imageView.image {
                        self?.imageCache?.add(image, withIdentifier: String(event.id))
                    }
                }
            } else {
                imageView.image = #imageLiteral(resourceName: "placeholder")
                
                imageCache?.add(#imageLiteral(resourceName: "placeholder"), withIdentifier: String(event.id))
            }
        }
        
        if let dateLabel = self.dateLabel {
            dateLabel.text = event.dateDisplayString
        }
        
        if let locationLabel = self.locationLabel {
            locationLabel.text = (event.venue?.location ?? "Unknown")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let favoriteButton = UIButton(type: .custom)
        favoriteButton.tintColor = .red
        favoriteButton.adjustsImageWhenHighlighted = false
        favoriteButton.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        favoriteButton.setImage(#imageLiteral(resourceName: "heart-selected"), for: .selected)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite(_:)), for: .touchUpInside)
        favoriteButton.isSelected = (event?.isFavorite ?? false)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        
        configureView()
    }

    @objc func toggleFavorite(_ sender: Any?) {
        guard let event = self.event else {
            return
        }
        
        do {
            if event.isFavorite {
                try FavoritesHelper.shared.remove(event)
            } else {
                try FavoritesHelper.shared.add(event)
            }
        } catch let error {
            print("favorite error: \(error)")
            
            let alert = UIAlertController(title: "Error", message: "The event was not added to favorites.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in }))
            self.present(alert, animated: true, completion: nil)
        }
        
        if let button = sender as? UIButton {
            button.isSelected = event.isFavorite
        }
    }
    
}

