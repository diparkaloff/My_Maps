//
//  RecordAudioViewControllerDelegate.swift
//  MyMaps
//
//  
//

import Foundation

protocol RecordAudioServiceDelegate {
    func recordDidFinishPlaying()
    func getMeterTimer(timer: String)
}
