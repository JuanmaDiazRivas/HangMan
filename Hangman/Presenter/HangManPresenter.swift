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
    func useLetter(letter: String) -> Utils.PlayedResult
    func startGame()
}

public protocol HangManPresenterDelegate: class {
    func changeTextWordLabel(text:String)
    func resetView(progress: Float, tintColor: UIColor)
    func informAttemptFailed(triesLeft: Float)
    func changeLifeProgress(_ lifeProgress: Float)
    func changeLifeColor(red: Float,green: Float,blue: Float,alpha:Float)
    func changeSoundIcon(image: UIImage)
    func showResult(alertController: UIAlertController)
    func disableKey(_ key: String)
    func enableKey(_ key: String)
    func setErrorKey(_ key: String)
}


class HangManPresenterImpl {
    
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
    
    //Interactor
    private let interactor: HangmanInteractor = HangmanInteractorImpl()
    
    //Delegate
    private weak var delegate: HangManPresenterDelegate?
    
    //Aux variables
    private var originalWord: [Character] = []
    private var lifeProgress = Float()
    
    //Constants
    private let textFieldLentgh: Int = 1
    private let alertControllerKeyMessage: String = "attributedMessage"
    private let resourceName : String = "wordList"
    private let resourceExtension : String = "txt"
    private let viewContainsHealthBar: Bool = true
    enum MessageType : String{
        case Error
        case Sucess
    }
    
    //Music
    private var isMuted = false
    
    public init(withHangmanInteractor interactor: HangmanInteractor) {
        self.interactor = interactor
    }
    
    //Life Functions
    func decreaseHealthBar(){
        let decrease = Float((100/Utils.errorsOnInitAllowed)/100)
        
        lifeProgress -=  decrease
        
        self.changeLifeBarStatus(lifeProgress)
    }

    //MARK: - Sound Functions
    func playMainSong(numberOfLoops: Int){
        
        do{
            backgroundMusicAvAudioPlayer = try AVAudioPlayer(contentsOf: self.createUrlWithName(parameter: nameOfMainTheme))
            backgroundMusicAvAudioPlayer?.volume = backgroundMusicVolume
            
            backgroundMusicAvAudioPlayer?.numberOfLoops = numberOfLoops
            backgroundMusicAvAudioPlayer?.play()
        }catch {
            debugPrint("The music could not be played")
        }
        
    }
    
    func playEffectWithString(_ effectName : String){
        if(!isMuted){
            do{
                playEffect = try AVAudioPlayer(contentsOf: self.createUrlWithName(parameter: effectName))
                playEffect?.play()
            }catch{
                //cannot play audio :(
            }
        }
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
            self.delegate?.changeSoundIcon(image: image)
        }
    }
    
    //MARK: - Enders
    func showFailedSolution() {
        //play dead effect before die
        playEffectWithString(nameOfDeadEffect)
        
        let message = "\nTu salud se ha agotado.\n\n Solución.. "
        
        let ac = UIAlertController(title: "Has muerto..", message: nil, preferredStyle: .alert)
        
        ac.setValue(formatEndMessage(message: message, messageType: MessageType.Error), forKey: alertControllerKeyMessage)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default){
            (alert:UIAlertAction!) in
            self.startGame()
        })
        
        self.delegate?.showResult(alertController: ac)
    }
    
    func showSucessSolution() {
        
        let message = "\nHas conseguido escapar\n\n Solución.. "
        
        let ac = UIAlertController(title: "Enhorabuena!", message: nil, preferredStyle: .alert)
        
        ac.setValue(formatEndMessage(message: message, messageType: MessageType.Sucess), forKey: alertControllerKeyMessage)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default){
            (alert:UIAlertAction!) in
            self.startGame()
        })
        
        self.delegate?.showResult(alertController: ac)
    }
    
    private func formatEndMessage(message: String,messageType : MessageType) -> NSMutableAttributedString{
        
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message + String(originalWord).uppercased(), attributes: [NSAttributedString.Key : Any]())
        messageMutableString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: NSRange(location:message.count,length: originalWord.count))
        
        let color = (messageType == MessageType.Sucess) ? sucessColor : errorColor
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location:message.count, length:originalWord.count))
        
        return messageMutableString
    }
    
    //MARK: - Aux mehtods
    public func createUrlWithName(parameter:String) -> URL{
        let path = Bundle.main.path(forResource: parameter, ofType:nil)!
        return URL(fileURLWithPath: path)
    }
    
}

// MARK: - HangManPresenter
extension HangManPresenterImpl: HangManPresenter{
    func viewDidLoad(hangmanPresenterDelegate: HangManPresenterDelegate?) {
        self.delegate = hangmanPresenterDelegate
        
        self.interactor.presenterDidLoad(hangmanInteractorDelegate: self)
        
        self.startGame()
        self.playMainSong(numberOfLoops: -1)
    }
    
    func startGame() {
        guard let wordInitialized = interactor.initalizeGame() else { return }
        originalWord = wordInitialized
        lifeProgress = 1
        self.delegate?.resetView(progress: lifeProgress, tintColor: .green)
    }
    
    func changeAudioMode() {
        if !isMuted{
            self.showMuteIconAndMuteApp()
        }else{
            self.showSoundIconAndUnmuteApp()
        }
        
        isMuted = !isMuted
    }
    
    func useLetter(letter: String) -> Utils.PlayedResult{
        var control = self.interactor.playLetter(letter: letter,containsHealthBar: viewContainsHealthBar)
        
        switch control {
        case Utils.PlayedResult.failed:
            //if the word doesnt was changed, then we need to reproduce a sound
            self.playEffectWithString(nameOfWriteEffect)
            decreaseHealthBar()
        case Utils.PlayedResult.win:
            self.winGame()
            control = Utils.PlayedResult.used
        case Utils.PlayedResult.lose:
            self.endGame()
            control = Utils.PlayedResult.failed
        default:
            debugPrint("letter played \(letter)")
        }
        
        return control
    }
}

// MARK: - HangmanInteractorDelegate
extension HangManPresenterImpl:  HangmanInteractorDelegate{
    func attemptFailed(currentAttempts: Float) {
        self.delegate?.informAttemptFailed(triesLeft: currentAttempts)
    }
    
    func newMainWord(text: String) {
        self.delegate?.changeTextWordLabel(text: text)
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
    
    func endGame() {
        self.delegate?.changeLifeProgress(0)
        self.playEffectWithString(nameOfDeadEffect)
        self.showFailedSolution()
    }
    
    func winGame() {
        self.showSucessSolution()
    }
}
