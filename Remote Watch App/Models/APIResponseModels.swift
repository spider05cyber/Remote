//
//  APIResponseModels.swift
//  Remote
//
//  Created by Jayden Scarpa on 21/04/2025.
//

import Foundation

// Raw API response model
struct Entity: Decodable {
    struct Attributes: Decodable {
        let friendly_name: String?
    }
    
    let attributes: Attributes
    let entity_id: String
    let last_changed: String
    let state: String
}

// App representation model
struct MediaPlayer: Identifiable {
    let id = UUID()
    let entityId: String
    let name: String
    
    init(from entity: Entity) {
        self.entityId = entity.entity_id
        self.name = entity.attributes.friendly_name ?? entity.entity_id
    }
    
    // Standard initializer
    init(entityId: String, name: String) {
        self.entityId = entityId
        self.name = name
    }
    
    var volumeEntityId: String {
            get {
                return UserDefaults.standard.string(forKey: "volumeEntityId\(entityId)") ?? entityId
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "volumeEntityId\(entityId)")
            }
        }
    
    var brightnessEntityId: String {
        get {
            return UserDefaults.standard.string(forKey: "brightnessEntityId_\(entityId)") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "brightnessEntityId_\(entityId)")
        }
    }


}
