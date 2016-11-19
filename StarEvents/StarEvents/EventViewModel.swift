//
//  EventViewModel.swift
//  StarEvents
//
//  Created by Liam Butler-Lawrence on 11/18/16.
//  Copyright © 2016 Liam Butler-Lawrence. All rights reserved.
//

import Foundation

struct EventViewModel {
    func format(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        // By default, "AM" and "PM" are used.
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mma"
        return dateFormatter.string(from: date)
    }
}
