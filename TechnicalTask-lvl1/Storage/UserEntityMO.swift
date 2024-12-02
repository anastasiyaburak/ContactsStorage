//
//  UserEntityMO.swift
//  TechnicalTask-lvl1
//
//  Created by mac on 29.11.24.
//

import Foundation
import CoreData

@objc(UserEntityMO)
class UserEntityMO: NSManagedObject {
    @NSManaged var username: String
    @NSManaged var email: String
    @NSManaged var city: String
    @NSManaged var street: String
}
