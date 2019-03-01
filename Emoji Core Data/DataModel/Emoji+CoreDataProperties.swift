//
//  Emoji+CoreDataProperties.swift
//  Emoji Core Data
//
//  Created by Dmitry Novosyolov on 26/02/2019.
//  Copyright © 2019 Dmitry Novosyolov. All rights reserved.
//
//

import Foundation
import CoreData


extension Emoji {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Emoji> {
        return NSFetchRequest<Emoji>(entityName: "Emoji")
    }

    @NSManaged public var name: String?
    @NSManaged public var summary: String?
    @NSManaged public var symbol: String?
    
}
