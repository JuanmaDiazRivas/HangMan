//
//  HangmanInteractor.swift
//  Hangman
//
//  Created by Plexus on 05/12/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

public protocol HangmanInteractor{
    func initalizeGame() -> [Character]
    func presenterDidLoad(hangmanInteractorDelegate: HangmanInteractorDelegate?)
    func playLetter(letter: String?,containsHealthBar: Bool) -> Utils.PlayedResult
}

public protocol HangmanInteractorDelegate: class{
    func newMainWord(text:String)
    func changeLifeBarStatus(_ progressCalculated: Float)
    func attemptFailed(currentAttempts: Float)
    func endGame()
    func winGame()
}

class HangmanInteractorImpl: HangmanInteractor{
    
    //Aux variables
    var triesLeft = Float()
    var originalWordArray = [Character]()
    var lifeProgress = Float()
    var currentWord: String = ""
    var allWords = [String]()
    
    //Constants
    private let errorsOnInitAllowed: Float = 7
    
    //Delegate
    private weak var delegate: HangmanInteractorDelegate?
    
    //Repository
    private var repository: DictionaryRepository = DictionaryRepositoryImpl()
    
    func presenterDidLoad(hangmanInteractorDelegate: HangmanInteractorDelegate?){
        self.delegate = hangmanInteractorDelegate
    }
    
    
    func initalizeGame() -> [Character]{
        self.triesLeft = errorsOnInitAllowed
        
        //load the word from dicitionary
        let wordFromDictionary = repository.getRandomWord().word
        
        var firstWord = String(repeating: "_", count: wordFromDictionary.count)
        
        self.originalWordArray = Array(wordFromDictionary)
        
        //take 3 random positions and reveal all the letters in word for this letter
        initWord(firstWord: &firstWord)
        
        
        self.currentWord = firstWord
        
        self.delegate?.newMainWord(text: firstWord)
        
        return originalWordArray
    }
    

    private func initWord(firstWord: inout String){
        for _ in 0..<3{
            let random = Int.random(in: 0..<originalWordArray.count)
            let letterToPlay = Array(originalWordArray)[random]
            
            var auxWordArray = Array(firstWord)
            
            self.originalWordArray.enumerated().forEach { index, character in
                if character.uppercased() == letterToPlay.uppercased() {
                    auxWordArray[index] = character
                }
            }

            firstWord = String(auxWordArray)
        }
        
    }
    
    private func modifyWord(letterUsed : Character,currenWord: String) -> Bool?{
        
        var auxWordArray = Array(currenWord)
        var wordModified = false
        
        self.originalWordArray.enumerated().forEach { index, character in
            if character.uppercased() == letterUsed.uppercased() {
                wordModified = true
                auxWordArray[index] = character
            }
        }
        
        if wordModified {
            self.delegate?.newMainWord(text: String(auxWordArray))
            currentWord = String(auxWordArray)
        }
        
        return wordModified
    }
    
    func playLetter(letter: String?,containsHealthBar: Bool) -> Utils.PlayedResult{
        var control = Utils.PlayedResult.noChanged
        
        guard let letterUsed = letter,
            !letterUsed.isEmpty,
            let modified = modifyWord(letterUsed: Character(letterUsed),currenWord: self.currentWord)
            else { return control}
        
        if !currentWord.contains("_"){
            control = Utils.PlayedResult.win
        }
        
        if !modified && control != Utils.PlayedResult.win{
            
            control = Utils.PlayedResult.failed
            
            changeHPBar(containsHealthBar: containsHealthBar)
        }else{
                control = Utils.PlayedResult.used
        }
        
        return control
    }
    
    private func changeHPBar(containsHealthBar: Bool){
        delegate?.attemptFailed(currentAttempts: triesLeft)
        
        triesLeft -= 1
        
        if containsHealthBar{
            let decrease = Float((100/errorsOnInitAllowed)/100)
            
            let progressCalculated = lifeProgress - decrease
            
            updateProgress(progessCalculated: progressCalculated)
        }
        
        if triesLeft.isEqual(to: 0){
            self.delegate?.endGame()
        }
    }
    
    private func updateProgress(progessCalculated: Float){
        delegate?.changeLifeBarStatus(progessCalculated)
    }
    
}
