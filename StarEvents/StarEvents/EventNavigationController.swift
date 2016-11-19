//
//  EventNavigationController.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/19/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import UIKit

class EventNavigationController: UINavigationController {
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
