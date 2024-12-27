//
//  Package.swift
//  NirvanaTour
//
//  Created by Yohanes  Ari on 18/10/24.
//

import Foundation
import FirebaseFirestore

struct InventoryItem: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    let name: String
    let category: String
    let description: String
    let price: Double
    let imageUrl: [String]?
    var stock: Int
    let supplierId: String
    let supplierName: String
    
    var dictionary: [String: Any] {
        return [
            "id": id ?? "",
            "name": name,
            "category": category,
            "description": description,
            "stock": stock,
            "price": price,
            "imageUrl": imageUrl ?? [],
            "supplierId": supplierId,
            "supplierName": supplierName
        ]
    }
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String ?? ""
        self.category = dictionary["category"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.stock = dictionary["stock"] as? Int ?? 0
        self.price = dictionary["price"] as? Double ?? 0.0
        self.imageUrl = dictionary["imageUrl"] as? [String]
        self.supplierId = dictionary["supplierId"] as? String ?? ""
        self.supplierName = dictionary["supplierName"] as? String ?? ""
    }
    
    init(id: String? = nil,
         name: String,
         category: String,
         description: String,
         stock: Int,
         price: Double,
         imageUrl: [String]?,
         supplierId: String,
         supplierName: String) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.stock = stock
        self.price = price
        self.imageUrl = imageUrl
        self.supplierId = supplierId
        self.supplierName = supplierName
    }
}
