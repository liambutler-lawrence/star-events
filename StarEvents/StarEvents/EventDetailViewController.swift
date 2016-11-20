//
//  EventDetailViewController.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/14/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    // MARK: Variables
    
    // This property must be set before viewDidLoad is called
    weak var event: StarEvent!
    
    fileprivate var previousScrollViewYOffset: CGFloat = 0
    
    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var headerImageView: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var bodyLabel: UILabel!
    
    @IBOutlet weak var headerImageViewTopConstraint: NSLayoutConstraint!
    
    // MARK: View Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewModel = EventViewModel()
        
        titleLabel.text = event.title
        dateLabel.text = viewModel.format(event.date)
        
        loadEventBody()
        loadHeaderImage()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Views
    
    fileprivate func setHeaderTitle(hidden titleHidden: Bool) {
        let fadeAnimation = CATransition()
        fadeAnimation.duration = 0.5
        fadeAnimation.type = kCATransitionFade
        navigationBar.layer.add(fadeAnimation, forKey: "fadeTitleTransition")
        
        navigationBar.topItem!.title = titleHidden ? "" : event.title
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
    
    // MARK: Actions
    
    @IBAction private func backButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func shareButtonTapped(_ sender: UIBarButtonItem) {
        let sharedText = "\(event.title): \(event.eventDescription)"
        let shareViewController = UIActivityViewController(activityItems: [sharedText], applicationActivities: nil)
        
        if let sharePopoverController = shareViewController.popoverPresentationController {
            sharePopoverController.barButtonItem = sender
        }
        
        present(shareViewController, animated: true, completion: nil)
    }
}

extension EventDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newScrollViewOffset = scrollView.contentOffset.y
        let triggerPoint: CGFloat = 45
        
        if previousScrollViewYOffset < newScrollViewOffset
            && (previousScrollViewYOffset...newScrollViewOffset).contains(triggerPoint) {
            setHeaderTitle(hidden: false)
        } else if newScrollViewOffset < previousScrollViewYOffset
            && (newScrollViewOffset...previousScrollViewYOffset).contains(triggerPoint) {
            setHeaderTitle(hidden: true)
        }
        
        previousScrollViewYOffset = newScrollViewOffset
    }
}
