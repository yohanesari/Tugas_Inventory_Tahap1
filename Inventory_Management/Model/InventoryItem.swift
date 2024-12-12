//
//  InventoryItem.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 26/11/24.
//

import Foundation

struct InventoryItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var description: String
    var price: Double
    var category: String
    var stock: Int
    var imageData: Data?
}
