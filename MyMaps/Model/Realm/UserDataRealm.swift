//
//  UserRealm.swift
//  MyMaps
//
//  
//

import Foundation
import RealmSwift

class UserDataRealm: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    override class func primaryKey() -> String? {
        return "login"
    }

    func addUserData(login: String, password: String, completionHandler: () -> ()) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            let userData = UserDataRealm()
            userData.login = login
            userData.password = password
            realm.add(userData, update: .modified)
            
            try realm.commitWrite()
            completionHandler()
        } catch {
            print(error)
        }
    }
    
    func deleteAllUserData() {
        do {
            let realm = try Realm()
            let userData = realm.objects(UserDataRealm.self)
            realm.beginWrite()
            realm.delete(userData)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func getSpecificUserData(for primaryKey: String, completionHandler: (UserDataRealm?) -> ()) {
        var specificUserData: UserDataRealm?
        do {
            let realm = try Realm()
            specificUserData = realm.object(ofType: UserDataRealm.self, forPrimaryKey: primaryKey)
            completionHandler(specificUserData)
        } catch {
            print(error)
        }
    }
}
