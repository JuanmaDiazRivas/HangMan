//
//  HangManPresenter.swift
//  hangman
//
//  Created by Plexus on 26/11/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import Foundation

class HangManPresenter: NSObject, DictionaryDelegate {
    
    private let dictionaryService = DictionaryService()
    private var dictionaryModel  = [DictionaryModel]()
    weak private var hangmanViewDelegate: HangManViewDelegate?
    
    //Constants
    private let errorsOnInitAllowed: Float = 7
    private let resourceName : String = "wordList"
    private let resourceExtension : String = "txt"
    
    
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
    var currentWord: String = ""
    var triesLeft = Float()
    
    
    override init(){
        super.init()
        dictionaryService.setDelegate(dictionaryDelegate: self)
    }
    
    func setViewDelegate(hangmanViewDelegate: HangManViewDelegate?){
        self.hangmanViewDelegate = hangmanViewDelegate
    }
    
    fileprivate func playAndShowFirstWordInLabel(_ wordFromDictionary: String) {
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
        playAndShowFirstWordInLabel(wordFromDictionary)
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
    
    @discardableResult
    private func modifyWord(letterUsed : Character) -> Bool?{
        
        guard
            let currentWord = self.hangmanViewDelegate?.getCurrentWordLabel(),
            !currentWord.isEmpty
            else {return true}
        
        var auxWordArray = Array(currentWord)
        var wordModified = false
        
        originalWord.enumerated().forEach { index, character in
            if character.uppercased() == letterUsed.uppercased() {
                wordModified = true
                auxWordArray[index] = character
            }
        }
        
        if wordModified {
            self.hangmanViewDelegate?.changeTextWordLabel(text: String(auxWordArray))
        }
        
        return wordModified
    }
    
    private func createUrlWithName(parameter:String) -> URL{
        let path = Bundle.main.path(forResource: parameter, ofType:nil)!
        return URL(fileURLWithPath: path)
    }
    
    //delegate methods
    func getDictionary(dictionary: [DictionaryModel]) {
        self.dictionaryModel = dictionary
    }
    
    func playEffectWithString(_ efectURL : URL){
        if(!isMuted){
            self.hangmanViewDelegate?.playEffectWithString(efectURL)
        }
    }
    func prepareMusic(musicURL: URL){
        self.hangmanViewDelegate?.prepareMusic(musicURL: musicURL)
    }
}
