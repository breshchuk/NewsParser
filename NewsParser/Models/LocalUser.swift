//
//  LocalUser.swift
//  News
//
//  Created by dimam on 12.03.21.
//

import Foundation
import Firebase

struct LocalUser {
    let email: String
    let userID: String
    
    init(user: User) {
        self.email = user.email!
        self.userID = user.uid
    }
}
