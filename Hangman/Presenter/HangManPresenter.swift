//
//  HangManPresenter.swift
//  hangman
//
//  Created by Plexus on 26/11/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public protocol HangManPresenter {
    func viewDidLoad(hangmanPresenterDelegate: HangManPresenterDelegate?)
    func changeAudioMode()
    func playLetter(letter: String?) -> Utils.PlayedResult
    func startGame()
}

public protocol HangManPresenterDelegate: class {
    func changeTextWordLabel(text:String, withCharacterSpacing: Double)
    func getCurrentWordLabel() -> String
    func resetView(progress: Float, tintColor: UIColor)
    func changeHangmanImg(image: UIImage)
    func changeLifeProgress(_ lifeProgress: Float)
    func getLifeProgress() -> Float
    func changeLifeColor(red: Float,green: Float,blue: Float,alpha:Float)
    func changeSoundIcon(image: UIImage)
}

class HangManPresenterImpl: HangManPresenter {
    
    //iOS class
    private var backgroundMusicAvAudioPlayer : AVAudioPlayer?
    private var backgroundMusicVolume : Float = 0.5
    private var playEffect : AVAudioPlayer?
    private let sucessColor : UIColor = UIColor.blue
    private let errorColor : UIColor = UIColor.red
    
    //Music constants
    private let nameOfMainTheme = "background.mp3"
    private let nameOfDeadEffect = "deadEffect.mp3"
    private let nameOfWriteEffect = "writeEffect.mp3"
    private let nameOfMuteIcon = "mute.png"
    private let nameOfSoundIcon = "sound.png"
    
    
    private let dictionaryService = DictionaryService()
    private var dictionaryModel  = [DictionaryModel]()
    
    //Interactor
    private let interactor: HangmanInteractor? = HangmanInteractorImpl()
    
    //Delegate
    private weak var delegate: HangManPresenterDelegate?
    
    //Constants
    private let characterSpacing : Double = 12
    private let textFieldLentgh: Int = 1
    private let alertControllerKeyMessage: String = "attributedMessage"
    private let resourceName : String = "wordList"
    private let resourceExtension : String = "txt"
    enum MessageType : String{
        case Error
        case Sucess
    }
    
    //Music
    private var isMuted = false
    
    func viewDidLoad(hangmanPresenterDelegate: HangManPresenterDelegate?) {
        self.delegate = hangmanPresenterDelegate
        self.startGame()
        self.playMainSong(numberOfLoops: -1)
    }
    
    private func createUrlWithName(parameter:String) -> URL{
        let path = Bundle.main.path(forResource: parameter, ofType:nil)!
        return URL(fileURLWithPath: path)
    }
    
    
    //life functions
    
    
    //game functions
    func startGame() {
         self.delegate?.resetView(progress: 100, tintColor: .green)
        
        interactor?.initalizeGame()
    }
    
    private func endGame() {
            self.delegate?.changeLifeProgress(0)
    }
        
    func playLetter(letter: String?) -> Utils.PlayedResult{
        var control = Utils.PlayedResult.noChanged
        
        guard let letterUsed = letter,
            !letterUsed.isEmpty,
            let modified = modifyWord(letterUsed: Character(letterUsed))
            else { return control
        }
        
        if !modified {
            //play letter effect before decrease hp
            self.delegate?.playEffectWithString(createUrlWithName(parameter: nameEffectIfDie))
            
            control = Utils.PlayedResult.failed
            
            changeGameStatus()
        }else{
            if let wordCompleted = delegate?.getCurrentWordLabel(){
                if !wordCompleted.contains("_"){
                    delegate?.showSucessSolution()
                }
            }
            control = Utils.PlayedResult.used
        }
        
        return control
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
            self.delegate?.showMuteIconAndMuteApp()
        }else{
            self.delegate?.showSoundIconAndUnmuteApp()
        }
        
        isMuted = !isMuted
    }
    
    func showMuteIconAndMuteApp(){
        assignImageToVolumeButton(nameOfMuteIcon)
        backgroundMusicAvAudioPlayer?.volume = 0.0
    }
    
    func showSoundIconAndUnmuteApp(){
        assignImageToVolumeButton(nameOfSoundIcon)
        backgroundMusicAvAudioPlayer?.volume = backgroundMusicVolume
    }
    
    func assignImageToVolumeButton(_ nameOfImageToAssign :String) {
        if let image = UIImage(named: nameOfImageToAssign){
            volumeButton.setImage(image, for: .normal)
        }
    }
    
    func playMainSong(numberOfLoops: Int){
        //music will loop forever
        do{
            backgroundMusicAvAudioPlayer = try AVAudioPlayer(contentsOf: createUrlWithName(parameter: nameOfMainTheme))
            backgroundMusicAvAudioPlayer?.volume = backgroundMusicVolume
            
            backgroundMusicAvAudioPlayer?.numberOfLoops = numberOfLoops
            backgroundMusicAvAudioPlayer?.play()
        }catch {
            debugPrint("The music could not be played")
        }
        
    }
    
    func playEffectWithString(_ efectURL : URL){
        do{
            playEffect = try AVAudioPlayer(contentsOf: efectURL)
            playEffect?.play()
        }catch{
            //cannot play audio :(
        }
    }
    
    //view functions
    func showFailedSolution() {
        //play dead effect before die
        playEffectWithString(nameOfDeadEffect)
        
        let message = "\nTu salud se ha agotado.\n\n Solución.. "
        
        let ac = UIAlertController(title: "Has muerto..", message: nil, preferredStyle: .alert)
        
        ac.setValue(formatMessage(message: message, messageType: MessageType.Error), forKey: alertControllerKeyMessage)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default){
            (alert:UIAlertAction!) in
            self.startGame()
        })
        
        present(ac,animated: true)
    }
    
    func showSucessSolution() {
        
        let message = "\nHas conseguido escapar\n\n Solución.. "
        
        let ac = UIAlertController(title: "Enhorabuena!", message: nil, preferredStyle: .alert)
        
        ac.setValue(formatMessage(message: message, messageType: MessageType.Sucess), forKey: alertControllerKeyMessage)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default){
            (alert:UIAlertAction!) in
            self.presenter?.startGame()
        })
        
        present(ac,animated: true)
    }

    
    //delegate methods
    func getDictionary(dictionary: [DictionaryModel]) {
        self.dictionaryModel = dictionary
    }
    
    func playEffectWithString(_ effectName : String){
        if(!isMuted){
            self.delegate?.playEffectWithString(createUrlWithName(parameter: effectName))
        }
    }
    
}

extension HangManPresenterImpl:  HangmanInteractorDelegate{
    func attemptFailed(currentAttempts: Float) {
        guard let image = UIImage(named: "\(Int(currentAttempts)).png") else {return}
            
        self.delegate?.changeHangmanImg(image: image)
    }
    
    func newMainWord(text: String) {
        self.delegate?.changeTextWordLabel(text: text, withCharacterSpacing: characterSpacing)
    }
    
    func changeLifeBarStatus(_ progressCalculated: Float) {
        self.delegate?.changeLifeProgress(progressCalculated)
        
        switch progressCalculated {
        case 0.0..<0.3:
            self.delegate?.changeLifeColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
            break
        case 0.3..<0.6:
            self.delegate?.changeLifeColor(red:1.00, green:0.64, blue:0.13, alpha:1.0)
            break
        default:
            self.delegate?.changeLifeColor(red:0.14, green:0.91, blue:0.07, alpha:1.0)
        }
    }
}
