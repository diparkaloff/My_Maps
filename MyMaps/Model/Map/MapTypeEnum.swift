//
//  MapTypeEnum.swift
//  MyMaps
//
//  
//

import Foundation

enum MapType: String {
    case normal, satellite, hybrid, terrain
    
    static let types: [MapType] = [normal, satellite, hybrid, terrain]
}
