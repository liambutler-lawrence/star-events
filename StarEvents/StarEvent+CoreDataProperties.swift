//
//  StarEvent+CoreDataProperties.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/15/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import Foundation
import CoreData


extension StarEvent {

    @nonobjc class func fetchRequest() -> NSFetchRequest<StarEvent> {
        return NSFetchRequest<StarEvent>(entityName: String(describing: StarEvent.self));
    }

    @NSManaged var title: String
    @NSManaged var eventDescription: String
    @NSManaged var timestamp: Date
    @NSManaged var date: Date
    @NSManaged var phone: String?
    @NSManaged var id: Int16
    @NSManaged var locationLine1: String
    @NSManaged var locationLine2: String
    @NSManaged var imageName: String?
}
