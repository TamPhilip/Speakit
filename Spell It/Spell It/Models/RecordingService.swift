//
//  RecordingService.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-24.
//  Copyright © 2018 Spell It. All rights reserved.
//

import AVFoundation
import Foundation
import Alamofire
import SwiftyJSON

enum RecordingType {
    case sentence
    case word
    case paragraph
}

class RecordingService: NSObject, AVAudioRecorderDelegate {
    // Check if currently in request
    static let shared = RecordingService()
    private let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    private(set) var busy: Bool = false
    private var recordingSession: AVAudioSession!
    private var audioRecorder: AVAudioRecorder!
    
    var type: RecordingType = .word
    
    func record(completionHandler: @escaping (String) -> Void) {
        if self.busy {
            self.busy = false
            finishRecording(success: true) { (text) in
                if let text = text {
                    print("Done")
                    completionHandler(text)
                }
            }
            return
        }
        
        self.busy = true
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
//        print(audioFilename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            print(error)
            finishRecording(success: false) { (_) in
                
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
//        print(paths.count)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false) { (_) in
                
            }
        }
    }
    
    private func finishRecording(success: Bool, _ completionHandler: @escaping (String?) -> ()) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            let request = makeRequest { (success, text) in
                if success {
                    print("Arrived")
                    completionHandler(text)
                }
            }
        }
    }
    
    private func makeRequest( _ completionHandler: @escaping (Bool, String) -> ()) -> Request? {
//        if type == .word {
        var voiceParams: [String: Any] = ["languageCode": "en-US", "sampleRateHertz": 16000, "encoding": "LINEAR16"]
        
            let audio = encode() ?? "fail"
            if audio == "fail" {
                completionHandler(false, "fail")
                return nil
            }
        
        let params: [String: Any] = ["config": voiceParams, "audio" : ["content" : encode() ?? "fail"]]
        
//            print(encode())
        
            let url = "https://speech.googleapis.com/v1/speech:recognize"
        
            let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
            
            let manager = Alamofire.SessionManager.default
            
        let request = manager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    if let data = response.data {
                        let json = try JSON.init(data: data)
                        print("here")
                        // Get the string from json
                        guard let result = json.dictionary?["results"] else {
                            print("Invalid response: \(response)")
                            self.busy = false
                            DispatchQueue.main.async {
                                completionHandler(false, "fail")
                            }
                            return
                        }
                        
                        print(result)
                       
                        
                        print("cool")
                        guard let alternatives = result.first?.1.dictionary?["alternatives"] else {
                            print("Invalid response: \(response)")
                            self.busy = false
                            DispatchQueue.main.async {
                                completionHandler(false, "fail")
                            }
                            return
                        }
                        
                        print("Here")
                        print(alternatives)
                        guard let transcript = alternatives.first?.1.dictionaryObject?["transcript"] as? String else {
                            print("Invalid response: \(response)")
                            self.busy = false
                            DispatchQueue.main.async {
                                completionHandler(false, "fail")
                            }
                            return
                        }
                        
                        completionHandler(true, transcript)
                    }
                } catch {
                    print(error)
                }
                break
            case .failure(let error):
                print(error)
            }
        }
        
        return request
    }
    
    private func encode() -> String? {
        let url = getDocumentsDirectory().appendingPathComponent("recording.wav")
        do {
            let data = try Data(contentsOf: url)
            return data.base64EncodedString()
        } catch {
            print("error: \(error)")
        }
        return nil
    }
    
    func getPermission(_ completionHandler: @escaping (Bool) -> ()) {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        completionHandler(true)
                    } else {
                        // failed to record!
                        completionHandler(false)
                    }
                }
            }
        } catch {
            completionHandler(false)
            // failed to record!
        }
    }
    
}
