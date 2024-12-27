//
//  Transaction.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 05/12/24.
//

import Foundation
import FirebaseFirestore

struct Transaction: Identifiable, Codable {
    @DocumentID var id: String?
    let type: TransactionType
    let quantity: Int
    let date: Date
    let inventoryItemId: String
    
    enum TransactionType: String, Codable {
        case incoming = "Masuk"
        case outgoing = "Keluar"
    }
    
    var dictionary: [String: Any] {
        return [
            "id": id ?? "",
            "type": type.rawValue,
            "quantity": quantity,
            "date": Timestamp(date: date),
            "inventoryItemId": inventoryItemId
        ]
    }
    
    init(id: String? = nil, type: TransactionType, quantity: Int, date: Date, inventoryItemId: String) {
        self.id = id
        self.type = type
        self.quantity = quantity
        self.date = date
        self.inventoryItemId = inventoryItemId
    }
    
    init?(dictionary: [String: Any]) {
        guard let typeString = dictionary["type"] as? String,
              let type = TransactionType(rawValue: typeString),
              let quantity = dictionary["quantity"] as? Int,
              let timestamp = dictionary["date"] as? Timestamp,
              let inventoryItemId = dictionary["inventoryItemId"] as? String else {
            return nil
        }
        
        self.id = dictionary["id"] as? String
        self.type = type
        self.quantity = quantity
        self.date = timestamp.dateValue()
        self.inventoryItemId = inventoryItemId
    }
}
