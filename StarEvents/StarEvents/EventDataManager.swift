//
//  EventDataManager.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/17/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct EventDataManager {
    
    private let eventsURL = URL(string: "https://raw.githubusercontent.com/phunware/dev-interview-homework/master/feed.json")!
    
    private let eventDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        return dateFormatter
    }()
    
    func loadEvents() {
        let eventsDataTask = URLSession.shared.dataTask(with: eventsURL) { (eventData, _, _) in
            guard
                let eventData = eventData,
                let events = try? JSONSerialization.jsonObject(with: eventData),
                let eventDictionaries = events as? [[String: Any]]
                else { return }
            
            eventDictionaries.forEach { self.update(event: $0) }
        }
        eventsDataTask.resume()
    }
    
    private func update(event eventDictionary: [String: Any]) {
        guard
            let id = eventDictionary["id"] as? Int16,
            
            let title = eventDictionary["title"] as? String,
            let eventDescription = eventDictionary["description"] as? String,
            
            let dateString = eventDictionary["date"] as? String,
            let timestampString = eventDictionary["timestamp"] as? String,
            let date = eventDateFormatter.date(from: dateString),
            let timestamp = eventDateFormatter.date(from: timestampString),
            
            let locationLine1 = eventDictionary["locationline1"] as? String,
            let locationLine2 = eventDictionary["locationline2"] as? String,
            
            let phone = eventDictionary["phone"] as? String?

            else { return }
        
        CoreDataContext.shared.perform {
            let fetchRequest = NSFetchRequest<StarEvent>(entityName: String(describing: StarEvent.self))
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            
            let event: StarEvent
            
            if let existingEvents = try? CoreDataContext.shared.fetch(fetchRequest),
                let existingEvent = existingEvents.first {
                event = existingEvent
            } else {
                event = NSEntityDescription.insertNewTypedObject(into: CoreDataContext.shared)
            }
            
            event.id = id
            event.title = title
            event.eventDescription = eventDescription
            event.date = date
            event.timestamp = timestamp
            event.locationLine1 = locationLine1
            event.locationLine2 = locationLine2
            event.phone = phone
            
            try? CoreDataContext.shared.save()
        }
        
        if let imageURLString = eventDictionary["image"] as? String,
            let imageURL = URL(string: imageURLString) {
            loadImage(from: imageURL, forEventWithID: id)
        }
    }
    
    private func loadImage(from imageURL: URL, forEventWithID id: Int16) {
        let imageDataTask = URLSession.shared.dataTask(with: imageURL) { (imageData, response, error) in
            guard
                let imageData = imageData,
                let image = UIImage(data: imageData) else { return }
            
            self.update(image: image, forEventWithID: id)
        }
        imageDataTask.resume()
    }
    
    private func update(image: UIImage, forEventWithID id: Int16) {
        CoreDataContext.shared.perform {
            let fetchRequest = NSFetchRequest<StarEvent>(entityName: String(describing: StarEvent.self))
            fetchRequest.predicate = NSPredicate(format: "id = %d", id)
            
            if let existingEvents = try? CoreDataContext.shared.fetch(fetchRequest),
                let existingEvent = existingEvents.first {
                
                existingEvent.image = image
            }
            
            try? CoreDataContext.shared.save()
        }
    }
}
