//
//  Event.swift
//  HomeAwayCodingChallenge
//
//  Created by Andrew Whitehead on 9/11/18.
//  Copyright © 2018 Andrew Whitehead. All rights reserved.
//

import Foundation

struct QueryResult: Codable { //wrapper JSON object
    let events: [Event]?
}

struct Event: Codable, Equatable {
    
    init(id: Int) { //probably should only be used for tests
        self.title = ""
        self.id = id
    }
    
    // MARK: - Equatable
    
    static func ==(lhs: Event, rhs: Event) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Constants
    
    private let dateFormatter = DateFormatter()
    
    // MARK: - Computed Properties
    
    var dateDisplayString: String? {
        guard let date = self.date else {
            return nil
        }
        
        dateFormatter.dateFormat = "EEE, d MMM yyyy hh:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    var isFavorite: Bool {
        return FavoritesHelper.shared.isFavorite(self)
    }
    
    // MARK: - Codable
    
    //Codable allows values that match CodingKeys to automatically be encoded and decoded via JSONEncoder/JSONDecoder
    //The following properties are automatically populated and encoded
    
    var title: String
    var date: Date?
    var venue: Venue?
    var performers: [Performer]?
    var id: Int //per SeatGeek API docs, this is a "unique integer identifier"
    
    
    private enum CodingKeys: String, CodingKey {
        case title
        case date = "datetime_local"
        case venue
        case performers
        case id
    }
    
    struct Venue: Codable {
        var location: String?
        
        private enum CodingKeys: String, CodingKey {
            case location = "display_location"
        }
    }
    
    struct Performer: Codable {
        var imageURL: URL?
        
        private enum CodingKeys: String, CodingKey {
            case imageURL = "image"
        }
    }
    
}
