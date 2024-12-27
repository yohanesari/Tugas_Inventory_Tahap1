//
//  User.swift
//  Project_iOS
//
//  Created by Yohanes  Ari on 29/10/24.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let noHp: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}

extension User{
    static var MOCK_USER = User(id: NSUUID().uuidString, fullname: "Yohanes Ari", noHp: "08123456789", email: "yohanesari@gmail.com")
}

