//
//  EventCollectionViewController.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/14/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import UIKit

class EventCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension EventCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = String(describing: EventCollectionViewCell.self)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? EventCollectionViewCell
            else { fatalError("Could not dequeue \(EventCollectionViewCell.self)") }
        
        cell.dateLabel.text = "today"
        cell.titleLabel.text = "Hello"
        cell.locationLabel.text = "Columbus, OH"
        cell.descriptionLabel.text = "This is an event"
        
        cell.backgroundImageView.image = #imageLiteral(resourceName: "EventDefaultImage")
        
        return cell
    }
}

extension EventCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailViewControllerIdentifier = String(describing: EventDetailViewController.self)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailViewController = mainStoryboard.instantiateViewController(withIdentifier: detailViewControllerIdentifier) as? EventDetailViewController
            else { fatalError("Could not instantiate \(EventCollectionViewCell.self)") }
        
        navigationController!.pushViewController(detailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight: CGFloat = 225
        let collectionViewWidth = view.bounds.width
        
        switch view.traitCollection.horizontalSizeClass {
        case .compact, .unspecified:
            return CGSize(width: collectionViewWidth, height: cellHeight)
        case .regular:
            return CGSize(width: collectionViewWidth / 2, height: cellHeight)
        }
    }
}
