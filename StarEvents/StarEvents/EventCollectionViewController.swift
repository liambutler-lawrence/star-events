//
//  EventCollectionViewController.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/14/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import UIKit
import CoreData

class EventCollectionViewController: UIViewController {
    
    // MARK: Variables
    
    // The NSFetchedResultsController delegate methods were designed for UITableView, which provides procedural-style "beginUpdates" and "endUpdates" methods that map directly to "controllerWillChangeContent" and "controllerDidChangeContent"
    // UICollectionView uses a closure-based pattern instead ("performBatchUpdates"), so we have to store all pending updates reported by the delegate methods and then perform the necessary updates all at once
    fileprivate var pendingUpdates = [() -> ()]()
    fileprivate weak var spinner: UIActivityIndicatorView?
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
    fileprivate let fetchedResultsController: NSFetchedResultsController<StarEvent> = {
        let fetchRequest = NSFetchRequest<StarEvent>(entityName: String(describing: StarEvent.self))
        let sortKey = "timestamp"
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]
        
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataContext.shared,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }()
    
    // MARK: View Controller

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewDidLoad() {
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Could not fetch events from Core Data")
        }
        
        EventDataManager().loadEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let events = fetchedResultsController.fetchedObjects
            else { fatalError("Cannot retrieve fetched events") }
        
        events.isEmpty ? addSpinner() : removeSpinner()
        
        let navigationBar = navigationController!.navigationBar
        navigationBar.barTintColor = .white
        navigationBar.tintColor = .black
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
     }
    
    // MARK: Spinner
    
    fileprivate func addSpinner() {
        guard self.spinner == nil else { return }
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
        } else {
            NSLayoutConstraint.activate([.centerX, .centerY].map {
                NSLayoutConstraint(item: spinner, attribute: $0, relatedBy: .equal, toItem: view, attribute: $0, multiplier: 1, constant: 0)
            })
        }
        
        spinner.startAnimating()
        self.spinner = spinner
    }
    
    fileprivate func removeSpinner() {
        guard let spinner = self.spinner else { return }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
}

extension EventCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let eventCount = fetchedResultsController.fetchedObjects?.count ?? 0
        return eventCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let events = fetchedResultsController.fetchedObjects
            else { fatalError("Cannot retrieve fetched event at index \(indexPath.item)") }
        let event = events[indexPath.item]
        
        let cellIdentifier = String(describing: EventCollectionViewCell.self)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? EventCollectionViewCell
            else { fatalError("Could not dequeue \(EventCollectionViewCell.self)") }
        
        // Create composite location string
        let eventLocation = "\(event.locationLine1), \(event.locationLine2)"
        
        let viewModel = EventViewModel()
        
        cell.dateLabel.text = viewModel.format(event.date)
        cell.titleLabel.text = event.title
        cell.locationLabel.text = eventLocation
        cell.descriptionLabel.text = event.eventDescription
        cell.backgroundImageView.image = event.image ?? #imageLiteral(resourceName: "EventDefaultImage")

        return cell
    }
}

extension EventCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let events = fetchedResultsController.fetchedObjects
            else { fatalError("Cannot retrieve fetched event at index \(indexPath.item)") }
        
        let detailViewControllerIdentifier = String(describing: EventDetailViewController.self)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let detailViewController = mainStoryboard.instantiateViewController(withIdentifier: detailViewControllerIdentifier) as? EventDetailViewController
            else { fatalError("Could not instantiate \(EventCollectionViewCell.self)") }
        detailViewController.event = events[indexPath.item]
        
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

extension EventCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        pendingUpdates.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // iOS 8 bug: this method is occasionally called with invalid NSFetchedResultsChangeType '0' (the valid cases are in 1...4)
        // In this scenario, Swift executes the first declared case in the switch statement, which causes unexpected behavior
        // Workaround: explicity guard against this invalid case
        guard type.rawValue > 0 else { return }
        
        let operation: () -> ()
        
        switch type {
        case .delete:
            operation = { self.collectionView.deleteItems(at: [indexPath!]) }
        case .insert:
            operation = { self.collectionView.insertItems(at: [newIndexPath!]) }
        case .move:
            operation = { self.collectionView.moveItem(at: indexPath!, to: newIndexPath!) }
        case .update:
            operation = { self.collectionView.reloadItems(at: [indexPath!]) }
        }
        
        pendingUpdates.append(operation)
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let events = fetchedResultsController.fetchedObjects
            else { fatalError("Cannot retrieve fetched events") }
        
        events.isEmpty ? addSpinner() : removeSpinner()
        
        collectionView.performBatchUpdates({
            self.pendingUpdates.forEach { $0() }
        }) { _ in
            self.pendingUpdates.removeAll()
        }
    }
}
