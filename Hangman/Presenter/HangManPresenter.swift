//
//  HangManPresenter.swift
//  hangman
//
//  Created by Plexus on 26/11/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import Foundation

class HangManPresenter {
    
    private let dictionaryService = DictionaryService()
    private var dictionaryModel  = [DictionaryModel]()
    
    weak private var hangmanViewDelegate: HangManViewDelegate?
    
    //Constants
    private let errorsOnInitAllowed: Float = 7
    private let resourceName : String = "wordList"
    private let resourceExtension : String = "txt"
    
    
    //Music
    private var isMuted = false
    
    //Aux variables
    var allWords = [String]()
    var originalWord = [Character]()
    var currentWord: String = ""
    var triesLeft = Float()
    
    init(){
        prepareWordsModel()
    }
    
    func setViewDelegate(hangmanViewDelegate: HangManViewDelegate?){
        self.hangmanViewDelegate = hangmanViewDelegate
    }
    
    private func prepareWordsModel() {
        dictionaryService.getDictionary().forEach { (wordFromDictionary) in
            allWords.append(wordFromDictionary.word)
        }
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
    
    private func switchToNextImage(){
        self.hangmanViewDelegate?.changeHangmanImg(literalName: "\(Int(triesLeft)).png")
        triesLeft -= 1
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
    
    
    //life functions
    fileprivate func endGame() {
            self.hangmanViewDelegate?.changeLifeProgress(0)
            self.hangmanViewDelegate?.showFailedSolution()
    }
    
    private func changeLifeBarStatus(_ progressCalculated: Float) {
        switch progressCalculated {
            case 0.0..<0.3:
                self.hangmanViewDelegate?.changeLifeColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
                break
            case 0.3..<0.6:
                self.hangmanViewDelegate?.changeLifeColor(red:1.00, green:0.64, blue:0.13, alpha:1.0)
                break
            default:
                self.hangmanViewDelegate?.changeLifeColor(red:0.14, green:0.91, blue:0.07, alpha:1.0)
        }
    }
    
    private func changeGameStatus(){
        
        guard let barProgress = self.hangmanViewDelegate?.getLifeProgress() else {return}
        
        switchToNextImage()
        
        let decrease = Float((100/errorsOnInitAllowed)/100)
        
        let progressCalculated = barProgress - decrease
        
        self.hangmanViewDelegate?.changeLifeProgress(progressCalculated)
        
        if progressCalculated <= decrease{
            endGame()
        }
        
        changeLifeBarStatus(progressCalculated)
    }
    
    //game functions
    private func playAndShowFirstWordInLabel(_ wordFromDictionary: String) {
        originalWord = Array(wordFromDictionary)
        
        let prepareFirstWord = String(repeating: "_", count: originalWord.count)
        
        self.hangmanViewDelegate?.changeTextWordLabel(text: prepareFirstWord)
        for _ in 0..<3{
            let random = Int.random(in: 0..<originalWord.count)
            let letterToPlay = Array(originalWord)[random]
            modifyWord(letterUsed: letterToPlay)
        }
    }
    
    func startGame() {
        let wordFromDictionary = shuffleDictionaryWord()
        
        self.hangmanViewDelegate?.resetView()
        
        triesLeft = errorsOnInitAllowed
        
        //take 3 positions and reveal all the letters on the word for this letter
        playAndShowFirstWordInLabel(wordFromDictionary)
    }
    
    func playLetter(letter: String?, nameEffectIfDie: String) {
        guard let letterUsed = letter,
            !letterUsed.isEmpty,
            let modified = modifyWord(letterUsed: Character(letterUsed))
            else { return }
        
        self.hangmanViewDelegate?.cleanInputLetter()
        
        if !modified {
            //play letter effect before decrease hp
            self.hangmanViewDelegate?.playEffectWithString(createUrlWithName(parameter: nameEffectIfDie))
            
            changeGameStatus()
        }
    }
    
    private func checkLetterOnWord(_ indexesOnRealWord: inout [Int], _ letterUsed: String ) {
        for i in 0..<originalWord.count{
            if String(originalWord[i]) == letterUsed.lowercased(){
                indexesOnRealWord.append(i)
            }
        }
    }
    
    //music functions
    func changeAudioMode() {
        if !isMuted{
            self.hangmanViewDelegate?.showMuteIconAndMuteApp()
        }else{
            self.hangmanViewDelegate?.showSoundIconAndUnmuteApp()
        }
        
        isMuted = !isMuted
    }

    
    //delegate methods
    func getDictionary(dictionary: [DictionaryModel]) {
        self.dictionaryModel = dictionary
    }
    
    func playEffectWithString(_ effectName : String){
        if(!isMuted){
            self.hangmanViewDelegate?.playEffectWithString(createUrlWithName(parameter: effectName))
        }
    }
    
    func prepareMusic(withName: String){
        self.hangmanViewDelegate?.prepareMusic(musicURL: createUrlWithName(parameter: withName))
    }
    
}
