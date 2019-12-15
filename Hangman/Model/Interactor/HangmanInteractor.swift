//
//  HangmanInteractor.swift
//  Hangman
//
//  Created by Plexus on 05/12/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

public protocol HangmanInteractor {
    func initalizeGame() -> [Character]
    func presenterDidLoad(hangmanInteractorDelegate: HangmanInteractorDelegate?)
    func playLetter(letter: String?,containsHealthBar: Bool)
}

public protocol HangmanInteractorDelegate: class{
    func newMainWord(text: String)
    func attemptFailed(currentAttempts: Float)
    func endGame()
    func winGame()
    func usedKey(letter: String)
    func failedKey(letter: String)
}

class HangmanInteractorImpl: HangmanInteractor{
    
    
    //MARK: - Aux Variables
    var triesLeft = Float()
    var originalWordArray = [Character]()
    var currentWord: String = ""
    var allWords = [String]()

    //MARK: - Delegate
    private weak var delegate: HangmanInteractorDelegate?
    
    //MARK: - Repository
    private var repository: DictionaryRepository = DictionaryRepositoryImpl()
    
    func presenterDidLoad(hangmanInteractorDelegate: HangmanInteractorDelegate?){
        self.delegate = hangmanInteractorDelegate
    }
    
    //MARK: - Init Game
    func initalizeGame() -> [Character]{
        self.triesLeft = Utils.errorsOnInitAllowed
        
        //load the word from dicitionary
        let wordFromDictionary = repository.getRandomWord().word
        
        var firstWord = String(repeating: "_", count: wordFromDictionary.count)
        
        self.originalWordArray = Array(wordFromDictionary)
        
        //take 3 random positions and reveal all the letters in word for this letter
        let lettersUsedOnInitWord = initWord(firstWord: &firstWord)
        
        self.currentWord = firstWord
        
        self.delegate?.newMainWord(text: firstWord)
        
        self.useFirstLetters(lettersUsedOnInitWord)
        
        return originalWordArray
    }
    

    private func initWord(firstWord: inout String) -> [String]{
        var lettersPlayed = [String]()
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
            
            lettersPlayed.append(letterToPlay.uppercased())
        }
        return lettersPlayed
    }
    
    private func useFirstLetters(_ letters: [String]){
        letters.forEach { (letter) in
            self.delegate?.usedKey(letter: letter)
        }
    }
    
    //MARK: - Modify Main Word
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
    
    func playLetter(letter: String?, containsHealthBar: Bool) {
        guard let letterUsed = letter,
            !letterUsed.isEmpty,
            let modified = modifyWord(letterUsed: Character(letterUsed),currenWord: self.currentWord)
            else { return }
        
        if !modified{
            
            self.delegate?.failedKey(letter: letterUsed)
            
            decreaseLife(containsHealthBar: containsHealthBar)
        }else{
            self.delegate?.usedKey(letter: letterUsed)
        }
        
        if !currentWord.contains("_"){
            self.delegate?.winGame()
        }
    }
    
    //MARK: - Life functions
    private func decreaseLife(containsHealthBar: Bool){
        delegate?.attemptFailed(currentAttempts: triesLeft)
        
        triesLeft -= 1
        
        if triesLeft.isEqual(to: 0){
            self.delegate?.endGame()
        }
    }
}
