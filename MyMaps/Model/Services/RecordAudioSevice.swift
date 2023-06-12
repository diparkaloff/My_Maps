//
//  RecordAudioSevice.swift
//  MyMaps
//
//  
//

import Foundation
import AVFoundation
import UIKit

class RecordAudioService: NSObject {
    
    private var recorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    var meterTimer: Timer?
    
    var delegate: RecordAudioServiceDelegate?
    var isPlaying = false
    
    func recordNewAudio() {
        prepareRecordNewAudio()
        recorder?.record()
        meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                          target:self,
                                          selector: #selector(self.updateAudioMeterForRecording(timer:)),
                                          userInfo:nil,
                                          repeats:true)
    }
    
    func stopRecord() {
        if recorder?.isRecording == true {
            recorder?.stop()
            meterTimer?.invalidate()
        }
    }
    
    func playRecord() {
        if FileManager.default.fileExists(atPath: getUrl(for: "newRecord.m4a").path) {
            preparePlay()
            audioPlayer?.play()
            meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                              target:self,
                                              selector: #selector(self.updateAudioMeterForPlayer(timer:)),
                                              userInfo:nil,
                                              repeats:true)
            isPlaying = true
        }
    }
    
    func stopPlayingRecord() {
        audioPlayer?.pause()
        meterTimer?.invalidate()
        isPlaying = false
    }
    
    private func prepareRecordNewAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            recorder = try AVAudioRecorder(url: getUrl(for: "newRecord.m4a"),
                                           settings: [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                                      AVSampleRateKey: 44100.0,
                                                      AVNumberOfChannelsKey: 2])
        } catch {
            print(error.localizedDescription)
        }
        recorder?.delegate = self
        recorder?.prepareToRecord()
    }
    
    private func preparePlay() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getUrl(for: "newRecord.m4a"))
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
        }
        catch {
            print("Error")
        }
    }
    
    @objc func updateAudioMeterForRecording(timer: Timer) {
        guard let recorder = recorder else { return }
        if recorder.isRecording {
            let hr = Int((recorder.currentTime / 60) / 60)
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            delegate?.getMeterTimer(timer: totalTimeString)
            recorder.updateMeters()
        }
    }
    
    @objc func updateAudioMeterForPlayer(timer: Timer) {
        guard let audioPlayer = audioPlayer else { return }
        if audioPlayer.isPlaying {
            let hr = Int((audioPlayer.currentTime / 60) / 60)
            let min = Int(audioPlayer.currentTime / 60)
            let sec = Int(audioPlayer.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            delegate?.getMeterTimer(timer: totalTimeString)
            audioPlayer.updateMeters()
        }
    }
    
    private func getUrl(for file: String) -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        let url = paths[0].appendingPathComponent(file)
        return url
    }
}

extension RecordAudioService: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }
    
    func audioRecorderBeginInterruption(_ recorder: AVAudioRecorder) {
        self.recorder = nil
        try? AVAudioSession.sharedInstance().setCategory(.playback)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        delegate?.recordDidFinishPlaying()
    }
}
