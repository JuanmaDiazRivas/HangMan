//
//  HangManPresenter.swift
//  hangman
//
//  Created by Plexus on 26/11/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import Foundation

class HangManPresenter {
    private let dictionaryService: DictionaryService
    weak private var hangmanViewDelegate: HangManViewDelegate?
    weak private var DictonaryDelegate: DictionaryDelegate?
    
    //Constants
    private let textFieldLentgh: Int = 1
    private let errorsOnInitAllowed: Float = 7
    private let resourceName : String = "wordList"
    private let resourceExtension : String = "txt"
    private let alertControllerKeyMessage : String = "attributedMessage"
    private let characterSpacing : Double = 12
    
    //Music
    private let nameOfMainTheme = "background.mp3"
    private let nameOfDeadEffect = "deadEffect.mp3"
    private let nameOfWriteEffect = "writeEffect.mp3"
    private let nameOfMuteIcon = "mute.png"
    private let nameOfSoundIcon = "sound.png"
    private var isMuted = false
    
    //Aux variables
    var allWords = [String]()
    var originalWord = [Character]()
    var currentWord: String
    var triesLeft = Float()
    enum MessageType : String{
        case Error
        case Sucess
    }
    
    init(){}
    
    func setViewDelegate(hangmanViewDelegate: HangManViewDelegate?){
        self.hangmanViewDelegate = hangmanViewDelegate
    }
    
    func setModelDelegate(dictionaryDelegate: DictionaryDelegate){
        self.DictonaryDelegate = dictionaryDelegate
    }
    
    fileprivate func playAndShowFirstWord(_ wordFromDictionary: String) {
        originalWord = Array(wordFromDictionary)
        var prepareFirstWord = String(repeating: "_", count: originalWord.count)
        
        for _ in 0..<3{
            let random = Int.random(in: 0..<originalWord.count)
            let letterToPlay = Array(originalWord)[random]
            modifyWord(letterUsed: letterToPlay)
        }
        
        self.hangmanViewDelegate?.changeTextWordLabel(text: prepareFirstWord)
    }
    
    func startGame() {
        let wordFromDictionary = shuffleDictionaryWord()
        
        self.hangmanViewDelegate?.resetView()
        
        triesLeft = errorsOnInitAllowed
        
        //take 3 positions and reveal all the letters on the word for this letter
        playAndShowFirstWord(wordFromDictionary)
    }
    
    private func shuffleDictionaryWord() -> String {
        var auxWord = String()
        allWords.shuffle()
        allWords.forEach { (valor) in
            if valor.count <= 8{
                auxWord = valor
            }
        }
        return auxWord
    }
    
}
