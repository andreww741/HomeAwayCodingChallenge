//
//  EventTableViewCell.swift
//  HomeAwayCodingChallenge
//
//  Created by Andrew Whitehead on 9/11/18.
//  Copyright © 2018 Andrew Whitehead. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var favoriteIndicator: UIButton! { //use button for easy image tint change
        didSet {
            favoriteIndicator.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
}
