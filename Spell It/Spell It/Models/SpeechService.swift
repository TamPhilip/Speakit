import UIKit
import Alamofire
import AVFoundation
import SwiftyJSON

class SpeechService: NSObject, AVAudioPlayerDelegate {
    
    // Create the Instance so it is a singleton
    static let shared = SpeechService()
    
    // Check if currently in request
    private(set) var busy: Bool = false
    private var player: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    
    func setupSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: .allowBluetooth)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print(audioSession.currentRoute)
        } catch {
            print(error)
        }
    }
    
    // Main Function
    func speak(text: String, completion: @escaping () -> Void) { // Check only if the completion is true
        if busy {
            print("Return Busy")
            return
        }
        busy = true
        
        DispatchQueue.global(qos: .background).async {
            var voiceParams = ["languageCode": "en-US", "name": "en-US-Wavenet-C"]
            
            let params: [String: Any] = [ "input": ["text": text], "voice": voiceParams, "audioConfig": ["audioEncoding": "LINEAR16", "speakingRate": 1]] // LINEAR 16 in wav
            
            let url = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"
            
            let headers = ["X-Goog-Api-Key": APIKey, "Content-Type": "application/json; charset=utf-8"]
            
            let manager = Alamofire.SessionManager.default
            
            // Request Timeout
            manager.session.configuration.timeoutIntervalForRequest = 30
            manager.session.configuration.timeoutIntervalForResource = 30
            
            let request = manager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data {
                            let json = try JSON.init(data: data)
                            
                            // Get the string from json
                            guard let audioContent = json.dictionaryObject?["audioContent"] as? String else {
                                print("Invalid response: \(response)")
                                self.busy = false
                                DispatchQueue.main.async {
                                    completion()
                                }
                                return
                            }
                            
                            // Decode the base64 string into a Data object
                            guard let audioData = Data(base64Encoded: audioContent) else {
                                self.busy = false
                                DispatchQueue.main.async {
                                    completion()
                                }
                                return
                            }
                            
                            print(audioData.base64EncodedString())
                            
                            DispatchQueue.main.async {
                                self.completionHandler = completion
                                do {
                                    self.player = try AVAudioPlayer(data: audioData, fileTypeHint: "wav")
                                } catch {
                                    print(error)
                                }
                                
                                self.player!.prepareToPlay()
                                self.player!.delegate = self
                                self.player!.play()
                            }
                            print("Success")

                        }
                    } catch {
                        print(error)
                    }
                    break
                case .failure(let error):
                    print(error)
                }
            })
        }
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Done")
        self.player?.delegate = nil
        self.player = nil
        self.busy = false
        self.completionHandler!()
        self.completionHandler = nil
    }
    
    func getSpeechProgress() -> Double {
        guard let player = player else {
            return 0
        }
        return player.currentTime / player.duration
    }
    
    
}

