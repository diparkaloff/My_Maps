//
//  LocationCoordinate.swift
//  MyMaps
//
//  
//

import Foundation
import RealmSwift
import GoogleMaps

class LocationRealm: Object {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
    func addCoordinate(_ coordinates: [CLLocationCoordinate2D]) {
        do {
            let realm = try Realm()
            realm.beginWrite()
            for coordinate in coordinates {
                let location = LocationRealm()
                location.latitude = coordinate.latitude
                location.longitude = coordinate.longitude
                realm.add(location)
            }
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func getAllLocations(completionHandler: ([CLLocationCoordinate2D]) -> ()) {
        do {
            let realm = try Realm()
            let objects = realm.objects(LocationRealm.self)
            var locations: [CLLocationCoordinate2D] = []
            
            for location in objects {
                let loc = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                locations.append(loc)
            }
            completionHandler(locations)
        } catch {
            print(error)
        }
    }
    
    func deleteAllLocations() {
        do {
            let realm = try Realm()
            let locations = realm.objects(LocationRealm.self)
            realm.beginWrite()
            realm.delete(locations)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
}
