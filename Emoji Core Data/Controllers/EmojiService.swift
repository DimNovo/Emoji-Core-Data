//
//  EmojiService.swift
//  Emoji Core Data
//
//  Created by Dmitry Novosyolov on 26/02/2019.
//  Copyright © 2019 Dmitry Novosyolov. All rights reserved.
//

import Foundation
import CoreData

class EmojiService {
    
    private let managedObjectContext: NSManagedObjectContext
    private var emojis = [Emoji]()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
    // MARK: - ... Public
    
    // Read
    func getAllEmojis() -> [Emoji]? {
        
        let request: NSFetchRequest<Emoji> = Emoji.fetchRequest()
        
        do {
            emojis = try managedObjectContext.fetch(request)
            return emojis
        } catch let error as NSError {
            print("Error fetching emojis: \(error.localizedDescription)")
        }
        return nil
    }
    
    // Create
    func addEmoji(symbol: String, name: String,
                  summary: String) {
        
        let emoji = Emoji(context: managedObjectContext)
        
        emoji.name = name
        emoji.symbol = symbol
        emoji.summary = summary
        
        emojis.append(emoji)
        save()
    }
    
    // Update
    func updateEmoji(symbol: String, name: String, summary: String) {
        
        let emoji = Emoji(context: managedObjectContext)
        managedObjectContext.delete(emoji)
        
        emoji.name = name
        emoji.symbol = symbol
        emoji.summary = summary
        
        save()
    }
    
    // Delete
    func delete(emoji: Emoji) {
        
        emojis = emojis.filter({$0 != emoji})
        managedObjectContext.delete(emoji)
        save()
    }
    
    // MARK: - ... Private
    
    // Save func
    private func save() {
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Save failed: \(error.localizedDescription)")
        }
    }
}
