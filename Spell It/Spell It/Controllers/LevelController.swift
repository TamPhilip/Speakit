//
//  LevelController.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-24.
//  Copyright © 2018 Spell It. All rights reserved.
//

import ChameleonFramework
import UIKit
import Material
import Motion
import FirebaseFirestore

private let reuseIdentifier = "SelectCell"

class LevelController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.delegate  = self
            self.collectionView.dataSource = self
            let nib = UINib(nibName: "SelectCell", bundle: nil)
            self.collectionView.register(nib, forCellWithReuseIdentifier: "SelectCell")
        }
    }
    
    @IBOutlet weak var changeAgeButton: FABButton! 
    
    var selectedTitle = "Alphabet"
    var type: Quiz = .alphabet
    var age = 3
    var index = 0
    var backgroundColor = UIColor(hexString: "DAF5EE")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let nav = self.navigationController else {return}
        
        nav.navigationBar.layer.masksToBounds = false
        nav.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        nav.navigationBar.layer.shadowOpacity = 0.8
        nav.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        nav.navigationBar.layer.shadowRadius = 2
        
        guard let font = UIFont(name: "Futura", size: 21) else {return}
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor:UIColor(hexString: "7CBDEA"), NSAttributedString.Key.font: font as Any]
        nav.navigationBar.titleTextAttributes = textAttributes
        
        nav.view.backgroundColor = UIColor(hexString: "F5F5F5")
    }

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        switch age {
        case 3:
            return 6
        case 4:
            return 2
        case 5:
            return 3
        default:
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        guard let cell = model as? SelectCell else {
            return model
        }
    
        if age == 3 {
            if indexPath.item == 0 {
                cell.backgroundColor = UIColor.init(hexString: "EC8E7E")
                cell.category.text = "Alphabet"
                cell.imageView.image = UIImage(named: "Alphabet")
            } else if indexPath.item == 1 {
                cell.backgroundColor = UIColor.flatMint().lighten(byPercentage: 1)
                cell.category.text = "Letter Sound 1"
                cell.imageView.image = UIImage(named: "phonetic")
            } else if indexPath.item == 2 {
                cell.backgroundColor = UIColor.darkGray
                cell.category.text = "Letter Sound 2"
                cell.imageView.image = UIImage(named: "phonetic")
            } else if indexPath.item == 3 {
                cell.backgroundColor = UIColor.flatForestGreen().lighten(byPercentage: 1)
                cell.category.text = "Letter Sound 3"
                cell.imageView.image = UIImage(named: "phonetic")
            } else if indexPath.item == 4 {
                cell.backgroundColor = UIColor.flatSand().lighten(byPercentage: 1)
                cell.category.text = "Letter Sound 4"
                cell.imageView.image = UIImage(named: "phonetic")
            } else {
                cell.backgroundColor = UIColor.flatTeal()?.lighten(byPercentage: 1)
                cell.category.text = "Words 1"
                cell.imageView.image = UIImage(named: "words")
            }
        } else if age == 4 {
            if indexPath.item == 0 {
                cell.backgroundColor = UIColor.flatTeal()?.lighten(byPercentage: 1)
                cell.category.text = "Words 2"
            } else {
                cell.backgroundColor = UIColor.flatLime()
                cell.category.text = "Sentences 1"
            }
        } else {
            if indexPath.item == 1 {
                cell.backgroundColor = UIColor.flatLime()
                cell.category.text = "Sentences 2"
            } else if indexPath.item == 0 {
                cell.backgroundColor = UIColor.flatTeal()?.lighten(byPercentage: 0.2)
                cell.category.text = "Words 3"
            } else {
                cell.backgroundColor = UIColor.flatSand()
                cell.category.text = "Story 1"
            }
        }
        // Configure the cell
        
        return cell
    }
    
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if age == 3 {
            if indexPath.item == 0 {
                index = 0
                type = .alphabet
            } else if indexPath.item == 1 {
                index = 1
                type = .alphabet
            } else if indexPath.item == 2 {
                index = 2
                type = .alphabet
            } else if indexPath.item == 3 {
                index = 3
                type = .alphabet
            } else if indexPath.item == 4 {
                index = 4
                type = .alphabet
            } else {
                type = .words
                index = 0
            }
        } else if age == 4 {
            if indexPath.item == 0 {
                index = 1
                type = .words
            } else {
                type = .sentences
                index = 1
            }
        } else {
            if indexPath.item == 0 {
                type = .words
                index = 2
            } else if indexPath.item == 1{
                type = .sentences
                index = 0
            }
        }
    
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectCell {
            backgroundColor = cell.backgroundColor
            selectedTitle = cell.category.text!
        }
    
        if indexPath.item == 2 && age == 5 {
            performSegue(withIdentifier: "goToRead", sender: self)
        }
    
        performSegue(withIdentifier: "goToQuiz", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToQuiz" {
            guard let dc = segue.destination as? QuizController else {return}
            dc.index = index
            dc.quizType = type
            dc.backgroundColor = backgroundColor
            dc.title = selectedTitle
        } else if segue.identifier == "goToRead" {
            guard let dc = segue.destination as? ReadController else {return}
            dc.index = index
            dc.backgroundColor = backgroundColor
            dc.title = selectedTitle
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width / 2 - 15, height: self.collectionView.frame.height / 2 - 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

extension Notification.Name {
    static let updateTables = Notification.Name("updateTables")
}
