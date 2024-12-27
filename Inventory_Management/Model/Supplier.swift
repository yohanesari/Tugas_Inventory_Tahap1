//
//  Supplier.swift
//  Inventory_Firebase
//
//  Created by Yohanes  Ari on 16/12/24.
//

import Foundation

import Foundation

struct Supplier: Identifiable, Hashable {
    var id: String
    var nama: String
    var alamat: String
    var kontak: String
    var latitude: Double
    var longitude: Double

    // Ensure the struct conforms to Hashable by implementing the hash function
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Ensure equality comparison is based on the id
    static func == (lhs: Supplier, rhs: Supplier) -> Bool {
        return lhs.id == rhs.id
    }
}

