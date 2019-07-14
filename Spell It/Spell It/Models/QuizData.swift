//
//  QuizData.swift
//  Spell It
//
//  Created by Philip Tam on 2018-11-24.
//  Copyright © 2018 Spell It. All rights reserved.
//

import Foundation

// Data for Quizzing
class QuizData {
    // Gets the case of each alphabet
    func getQuestions(index: Int, quiz: Quiz) -> [String] {
        switch quiz {
        case .alphabet :
            if index == 0 {
                return ["A  a","B   b","C  c", "D   d", "E  e", "F  f", "G  g", "H  h", "I  i", "J  j", "K  k", "L  l", "M  m", "N  n", "O  o", "P  p", "Q  q", "R  r", "S  s", "T  t", "U  u", "V  v", "W  w", "X  x", "Y  y", "Z  z"]
            } else if index == 1 {
                return ["a", "bb", "bu", "be", "c", "ke", "ch", "qu", "que", "cc"]
            } else if index == 2 {
                return ["d", "dd", "ed", "de", "e", "ea", "ie", "ei"]
            } else if index == 3 {
                return ["d", "dd", "ed", "de", "e", "ea", "ie", "ei"]
            } else if index == 4 {
                return ["d", "dd", "ed", "de", "e", "ea", "ie", "ei"]
            } 
        case .words:
            if index == 0 {
                return ["Cat", "Dog",  "Water", "Fire", "Car", "Tree", "Mom", "Dad", "You", "I", "Eat", "Sleep"]
            } else if index == 1 {
                return ["Helicopter", "Ambulance", "Police", "School", "Teacher", "Classroom", "Pencil", "Eraser", "Food"]
            } else if index == 2 {
                return ["Friendship", "Sneaker", "Bottle", "Telephone", "Garbage", "Feeling", "Computer", "Outrageous"]
            }
        case .sentences:
            if index == 0 {
                return ["The lion is big", "The elephant is huge", "The cat is sleeping", "The cub eats his food"]
            } else if index == 1 {
                return ["A walking animnal is fast", "The turtle is moving slowly", "Those boots are very heavy", "I like eating macaroni"]
            }
        }
        return []
    }
}
