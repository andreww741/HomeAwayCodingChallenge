//
//  FavoritesHelper.swift
//  HomeAwayCodingChallenge
//
//  Created by Andrew Whitehead on 9/11/18.
//  Copyright © 2018 Andrew Whitehead. All rights reserved.
//

import UIKit

class FavoritesHelper {
    
    static let shared = FavoritesHelper()
    
    private init() {
        if !FileManager.default.fileExists(atPath: favoritesDocumentURL.path) { //if the favorites plist doesn't already exist, create it
            let data = try? PropertyListSerialization.data(fromPropertyList: [Int](), format: .xml, options: 0)
            try? data?.write(to: favoritesDocumentURL)
        }
    }
    
    private var favoritesDocumentURL: URL {
        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentDirectoryURL.appendingPathComponent("favorites.plist")
    }

    private func favoriteEventIds() throws -> [Int]? { //store favorites by event id since it is a unique value
        let data = try Data(contentsOf: favoritesDocumentURL)
        return try PropertyListSerialization.propertyList(from: data, format: nil) as? [Int]
    }
    
    func isFavorite(_ event: Event) -> Bool {
        var isFavorite = false
        
        if let favorites = try? favoriteEventIds() {
            isFavorite = (favorites?.contains(event.id) ?? false)
        }
        
        return isFavorite
    }
    
    func add(_ event: Event) throws {
        if isFavorite(event) {
            return
        }
        
        var favorites = try favoriteEventIds() ?? [Int]()
        
        favorites.append(event.id)
        
        let data = try PropertyListSerialization.data(fromPropertyList: favorites, format: .xml, options: 0)
        try data.write(to: favoritesDocumentURL)
    }
    
    func remove(_ event: Event) throws {
        if !isFavorite(event) {
            return
        }
        
        var favorites = try favoriteEventIds() ?? [Int]()
        
        if let index = favorites.index(of: event.id) {
            favorites.remove(at: index)
            
            let data = try PropertyListSerialization.data(fromPropertyList: favorites, format: .xml, options: 0)
            try data.write(to: favoritesDocumentURL)
        }
    }
    
}
