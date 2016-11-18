//
//  EventDetailViewController.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/14/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    weak var event: StarEvent!
    
    override func viewWillAppear(_ animated: Bool) {
        let navigationBar = navigationController!.navigationBar
        navigationBar.barTintColor = .clear
        navigationBar.tintColor = .white
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func viewDidLoad() {
        let viewModel = EventViewModel()
        
        navigationItem.title = event.title
        titleLabel.text = event.title
        dateLabel.text = viewModel.format(event.date)
        
        loadEventBody()
        loadHeaderImage()
    }
    
    private func loadHeaderImage() {
        if let image = event.image {
            headerImageView.image = image
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = headerImageView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        headerImageView.layer.mask = gradientLayer
    }
    
    private func loadEventBody() {
        let bodyComponents = [
            event.locationLine1,
            event.locationLine2,
            event.phone,
            event.eventDescription
            ].flatMap { $0 }
        let eventBody = bodyComponents.joined(separator: "\n")
        
        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.paragraphSpacing = 10
        let attributedEventBody = NSAttributedString(string: eventBody, attributes: [NSParagraphStyleAttributeName: bodyStyle])
        
        bodyLabel.attributedText = attributedEventBody
    }
    
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    @IBAction private func shareButtonTapped(_ sender: UIBarButtonItem) {
        let sharedText = "\(event.title): \(event.eventDescription)"
        let shareViewController = UIActivityViewController(activityItems: [sharedText], applicationActivities: nil)
        
        if let sharePopoverController = shareViewController.popoverPresentationController {
            sharePopoverController.barButtonItem = sender
        }
        
        present(shareViewController, animated: true, completion: nil)
    }
}
