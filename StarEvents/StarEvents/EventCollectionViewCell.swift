//
//  EventCollectionViewCell.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/14/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        let smallMargin: CGFloat = 30
        let largeMargin: CGFloat = 60
        layoutMargins = UIEdgeInsets(top: largeMargin, left: smallMargin, bottom: smallMargin, right: smallMargin)
    }
}
