//
//  ViewController.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-23.
//  Copyright © 2018 Spell It. All rights reserved.
//

import AVFoundation
import UIKit

class ReadController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    // Play button will then be 
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.imageView?.contentMode = .scaleAspectFit
            playButton.layer.cornerRadius = 35
            playButton.layer.borderColor = playButton.tintColor.cgColor
            playButton.layer.borderWidth = 2
           
            
        }
    }
    
    // Round the button
    @IBOutlet weak var recordButton: UIButton! {
        didSet {
             recordButton.imageView?.contentMode = .scaleAspectFit
            recordButton.layer.cornerRadius = 35
            
        }
    }
    
    // Setup the Shadows for all fo the views)
    @IBOutlet var shadowCollection: [UIView]!
    
    func setupShadow() {
        shadowCollection.forEach { (view) in
            view.layer.shadowPath = UIBezierPath(roundedRect: view.layer.bounds, cornerRadius:view.layer.cornerRadius).cgPath
            view.layer.shadowColor = UIColor.lightGray.cgColor
            view.layer.shadowRadius = 2
            view.layer.shadowOffset = CGSize(width: 0, height: 1)
            view.layer.shadowOpacity = 1
        }
    }
    
      var backgroundColor = UIColor(hexString: "DAF5EE")
    
    var timer: Timer?
    
    var index = 0
    
    // Questions (NOT GOOD BUT FOR DEMO)
    var questions: [String] = ["""
        Once upon a time in a small village lived four Brahmins named Alice, Bob, Mike and Joey. They had grown up together to become good friends. Alice, Bob and Mike were very knowledgeable. But Joey spent most of his time eating and sleeping. He was considered foolish by everyone.

    Once famine struck the village. All the crops failed. Rivers and lakes started to dry up. The people of the villages started moving to other villages to save their lives.

    “We also need to move to another place soon or else we will also die like many others," said Alice. They all agreed with him.

    “But what about Joey?" Asked Alice.

    “Do we need him with us? He has no skills or learning. We cannot take him with us," replied Mike. “He will be a burden on us."

    “How can we leave him behind? He grew up with us," said Bob. “We will share what ever we earn equally among the four of us."

    They all agreed to take Joey along with them.

    They packed all necessary things and set out for a nearby town. On the way, they had to cross a forest.

    As they were walking through the forest, they came across the bones of an animal. They became curious and stopped to take a closer look at the bones.

    “Those are the bones of a lion," said Bob.

    The others agreed.

    “This is a great opportunity to test our learning," said Alice.

    “I can put the bones together." So saying, he brought the bones together to form the skeleton of a lion.

    “Mike said, “I can put muscles and tissue on it." Soon a lifeless lion lay before them.

    “I can breathe life into that body." said Bob.

    But before he could continue, Joey jumped up to stop him. “No. Don't! If you put life into that lion, it will kill us all," he cried.

    “Oh you coward! You can’t stop me from testing my skills and learning," shouted an angry Bob. “You are here with us only because I requested the others to let you come along."

    “Then please let me climb that tree first,’ said a frightened Joey running towards the nearest tree. Just as Joey pulled himself on to the tallest branch of the tree, Alice brought life into the lion. Getting up with a deafening roar, the lion attacked and killed the three learned Brahmins.
    """]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        textView.text = questions[index]
        
        self.view.backgroundColor = backgroundColor
        
        self.navigationItem.title = title
        
        RecordingService.shared.getPermission { (success) in
            if success {
                self.setupUI()
            } else {
                
            }
        }
        
        
       
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupUI() {
        recordButton.isHidden = false
         setupShadow()
    }
    
    // MARK: Recording Service
    
    @IBAction func recordPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            recordButton.backgroundColor = UIColor(hexString: "B14643")
            recordButton.setImage(UIImage(named: "recording"), for: .normal)
            
        } else if sender.tag == 1 {
            sender.tag = 0
            recordButton.backgroundColor = UIColor(hexString: "BEF394")
             recordButton.setImage(UIImage(named: "record"), for: .normal)
        }
        
        RecordingService.shared.record { text in
            print(text)
        }
    }
    
    // MARK: Speech Service

    @IBAction func playPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            
            SpeechService.shared.speak(text: textView.text) {
                // Finished speaking!
                self.timer = nil
            }
            sender.tag = 1
        } else {
            sender.tag = 0
        }
       
    }
    
    @objc func update() {
        // Assuming you're using an AVAudioPlayer, calculate how far along you are
        let progress = SpeechService.shared.getSpeechProgress()
        
        // Get the number of characters
        let characters = textView.text.characters.count
        
        // Calculate where to scroll
        let location = Double(characters) * progress
        
        // Scroll the textView
        textView.scrollRangeToVisible(NSRange(location: Int(location), length: 20))
    }
    
}

