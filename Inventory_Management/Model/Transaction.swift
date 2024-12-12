//
//  Transaction.swift
//  Inventory_Management
//
//  Created by Yohanes  Ari on 05/12/24.
//

import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case masuk = "Masuk"
    case keluar = "Keluar"
}

struct Transaction: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: TransactionType
    var amount: Int
    var date: Date
}

