//
//  EmojiTableViewController.swift
//  Emoji Core Data
//
//  Created by Dmitry Novosyolov on 26/02/2019.
//  Copyright © 2019 Dmitry Novosyolov. All rights reserved.
//

import UIKit
import CoreData

class EmojiTableViewController: UITableViewController {
    
    // MARK: - ... Public Properties
    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            guard let managedObjectContext = managedObjectContext else { return }
            emojiService = EmojiService(managedObjectContext: managedObjectContext)
        }
    }
    
    // MARK: - ... Private Properties
    private var emojiService: EmojiService?
    private var emojiList = [Emoji]()
    private var emojiToUpdate: Emoji?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadEmojis()
    }
    
    func alertController(actionType: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Emoji Add",
                                                message: "Choose your Emoji...",
                                                preferredStyle: .alert)
        alertController.addTextField { [weak self] (textField: UITextField) in
            textField.placeholder = "symbol"
            textField.text = self?.emojiToUpdate == nil ? "" : self?.emojiToUpdate?.symbol
        }
        
        alertController.addTextField { [weak self] (textField: UITextField) in
            textField.placeholder = "name"
            textField.text = self?.emojiToUpdate == nil ? "" : self?.emojiToUpdate?.name
        }
        
        alertController.addTextField { [weak self] (textField: UITextField) in
            textField.placeholder = "summary"
            textField.text = self?.emojiToUpdate == nil ? "" : self?.emojiToUpdate?.summary
        }
        
        let defaultAction = UIAlertAction(title: actionType.uppercased(), style: .default) { [weak self] (action)
            in
            guard let symbol = alertController.textFields?[0].text,
                let name = alertController.textFields?[1].text,
                let summary = alertController.textFields?[2].text else{ return }
            
            if actionType.caseInsensitiveCompare("add") == .orderedSame {
                self?.emojiService?.addEmoji(symbol: symbol, name: name, summary: summary)
            }
            else {
                guard let symbol = alertController.textFields?[0].text, !symbol.isEmpty,
                    let name = alertController.textFields?[1].text, !name.isEmpty,
                    let summary = alertController.textFields?[2].text, !summary.isEmpty,
                    let emojiToUpdate = self?.emojiToUpdate
                    else { return }
                
                self?.emojiService?.updateEmoji(symbol: emojiToUpdate.symbol!,
                                                name: emojiToUpdate.name!,
                                                summary: emojiToUpdate.summary!)
                
                self?.emojiToUpdate = nil
            }
            
            DispatchQueue.main.async {
                self?.loadEmojis()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            
        }
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    @IBAction func addEmojiAction(_ sender: UIBarButtonItem) {
        
        present(alertController(actionType: "add"), animated: true, completion: nil)
        
    }
    
    private func loadEmojis() {
        guard let emojis = emojiService?.getAllEmojis() else { return }
        emojiList = emojis
        tableView.reloadData()
    }
}

// MARK: - ... Extensions:

// MARK: - ... Delegate
extension EmojiTableViewController {
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "𝘿𝙀𝙇𝙀𝙏𝙀") {
            (action, indexPath) in
            let emoji = self.emojiList[indexPath.row]
            self.emojiList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.emojiService?.delete(emoji: emoji)
            
        }
        
        let insert = UITableViewRowAction(style: .normal, title: "𝙄𝙉𝙎𝙀𝙍𝙏") {
            (action, indexPath) in
            let emoji = self.emojiList[indexPath.row]
            self.emojiList.insert(emoji, at: indexPath.row)
            tableView.insertRows(at: [indexPath], with: .bottom)
            self.emojiService?.addEmoji(symbol: emoji.symbol!,
                                        name: emoji.name!,
                                        summary: emoji.summary!)
            
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        insert.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return [delete, insert]
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        emojiToUpdate = emojiList[indexPath.row]
        present(alertController(actionType: "update"), animated: true, completion: nil)
    }
}

// MARK: - ... DataSource
extension EmojiTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return emojiList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell")! as! EmojiTableViewCell
        
        let emoji = emojiList[indexPath.row]
        configure(cell: cell, emoji: emoji)
        
        return cell
    }
    
    func configure(cell: EmojiTableViewCell, emoji: Emoji) {
        
        cell.symbolLabel.text = emoji.symbol
        cell.nameLabel.text = emoji.name
        cell.summaryLabel.text = emoji.summary
    }
}
