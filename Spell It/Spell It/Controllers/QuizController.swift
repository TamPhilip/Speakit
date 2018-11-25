//
//  QuizController.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-24.
//  Copyright © 2018 Spell It. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseFirestore
import SVProgressHUD

enum Quiz {
    case alphabet
    case sentences
    case words
}

class QuizController: UIViewController {
    
    @IBOutlet weak var leftArrow: UIImageView!
    @IBOutlet weak var rightArrow: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.isPagingEnabled = true
            let nib = UINib(nibName: "QuizCell", bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: "QuizCell")
        }
    }
    
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.imageView?.contentMode = .scaleAspectFit
            playButton.layer.cornerRadius = 35
            playButton.layer.borderColor = playButton.tintColor.cgColor
            playButton.layer.borderWidth = 2
        }
    }
    @IBOutlet weak var recordButton: UIButton! {
        didSet {
            recordButton.imageView?.contentMode = .scaleAspectFit
            recordButton.layer.cornerRadius = 35
        }
    }
    
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
    
    @IBOutlet weak var pageLabel: UILabel!
    
    var page = 0
    
    var timer: Timer?
    
    var index = 0
    
    var quizType: Quiz = .alphabet
    
    var currentText = ""
    
    var backgroundColor = UIColor(hexString: "DAF5EE")
    
    var questions: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SpeechService.shared.setupSession()
        
        // Do any additional setup after loading the view, typically from a nib.
        questions = QuizData().getQuestions(index: index, quiz: quizType)
          pageLabel.text = "\(1) / \(questions.count)"
        currentText = questions[0]
        
        self.collectionView.reloadData()
        
        self.view.backgroundColor = backgroundColor
        self.collectionView.backgroundColor = backgroundColor
        
        self.navigationItem.title = title
        
        self.leftArrow.alpha = 0
        
        RecordingService.shared.getPermission { (success) in
            if success {
                self.setupUI()
            } else {
                
            }
        }
        
        if checkIfDone() {
            self.statusLabel.text = "Status: Done"
        } else {
            self.statusLabel.text = "Status: To Do"
        }
        
        self.tabBarController?.tabBar.isHidden = true
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
            if text == self.getSpeechText() {
                self.saveToFirestore(word: text, { (success, error) in
                    if success {
                        
                    } else {
                        print(error)
                    }
                })
                
                SVProgressHUD.showSuccess(withStatus: "You got it!")
                
                SVProgressHUD.dismiss(withDelay: 2)
                
                
            } else {
                SVProgressHUD.showError(withStatus: "You didn't get it")
                
                SVProgressHUD.dismiss(withDelay: 2)
            }
        }
    }
    
    // MARK: Speech Service
    
    @IBAction func playPressed(_ sender: UIButton) {
        let text = getSpeechText()
        currentText = questions[page]
        SpeechService.shared.speak(text: text) {
                // Finished speaking!
            
        }
    }
    
    func getSpeechText() -> String {
        if quizType == .alphabet  && index == 0 {
            var toRemove = currentText
            return String(toRemove.removeLast())
        } else {
            print(currentText)
            return currentText
        }
    }
}


extension QuizController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCell", for: indexPath)
        guard let cell = model as? QuizCell else {
            return model
        }
        
        cell.backgroundColor = backgroundColor
        cell.label.text = questions[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        let indexPath = IndexPath(item: currentPage, section: 0)
        print(currentPage)
        if !(currentPage == questions.count) {
            currentText = questions[currentPage]
            pageLabel.text = "\(currentPage + 1) / \(questions.count)"
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            page = currentPage
            if User.shared.solved.contains(currentText) {
                statusLabel.text = "Status: Done"
            } else {
                statusLabel.text = "Status: To Do"
            }
        }
        if checkIfDone() {
            self.statusLabel.text = "Status: Done"
        } else {
            self.statusLabel.text = "Status: To Do"
        }
        
        UIView.animate(withDuration: 0.2) {
            if currentPage == self.questions.count {
                self.rightArrow.alpha = 0
            } else if currentPage == 0 {
                self.leftArrow.alpha = 0
            } else {
                self.leftArrow.alpha = 1
                self.rightArrow.alpha = 1
            }
        }
    }
    
    func checkIfDone() -> Bool {
        return success.keys.contains(getSpeechText())
    }
    
    func saveToFirestore(word: String,_ completionHandler: @escaping (Bool, Error?) -> ()) {
        let db = Firestore.firestore().collection("userdata").document("0")
        
        let data = [word: true]
        NotificationCenter.default.post(name: .updateTables, object: nil)
        success[word] = true
        
        if checkIfDone() {
            self.statusLabel.text = "Status: Done"
        } else {
            self.statusLabel.text = "Status: To Do"
        }
        
        db.setData(data, merge: true) { (error) in
            if let error = error {
                completionHandler(false, error)
            }
            completionHandler(true, nil)
        }
    }
    
}
