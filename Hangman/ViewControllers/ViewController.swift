//
//  ViewController.swift
//  hangman
//
//  Created by Plexus on 06/08/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, HangManViewDelegate {
    
    //Constants
    private let characterSpacing : Double = 12
    private let textFieldLentgh: Int = 1
    private let alertControllerKeyMessage: String = "attributedMessage"
    enum MessageType : String{
        case Error
        case Sucess
    }
    
    //IBOutlets
    @IBOutlet var contentScroll: UIScrollView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var life: UIProgressView!
    @IBOutlet var imageHangMan: UIImageView!
    @IBOutlet weak var volumeButton: UIButton!
    
    //keyboardIboutlets
    
    
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
    
    //Presenter
    private let hangmanPresenter = HangManPresenter()
    
    //Controllers
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hangmanPresenter.setViewDelegate(hangmanViewDelegate: self)
        hangmanPresenter.startGame()
        hangmanPresenter.prepareMusic(withName: nameOfMainTheme)
        
        
        playMainSong()
        
    }
    
    //IBACTIONS
    @IBAction func changeAudioMode(_ sender: Any) {
        hangmanPresenter.changeAudioMode()
    }
    
    @IBAction func refreshGame(_ sender: Any) {
        startGame()
    }
    
    @IBAction func playLatter(_ sender: UIButton) {
        
        let result = hangmanPresenter.playLetter(letter: sender.titleLabel?.text, nameEffectIfDie: nameOfWriteEffect)
        
        switch(result){
            case "failed":
                sender.setTitleColor(.red, for: .normal)
                break
            case "used":
                sender.setTitleColor(.lightGray, for: .normal)
                break
            default:
                sender.setTitleColor(.black, for: .normal)
        }
        
    }
    
    //view functions
    private func formatMessage(message: String,messageType : MessageType) -> NSMutableAttributedString{
        
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message + String(hangmanPresenter.originalWord).uppercased(), attributes: [NSAttributedString.Key : Any]())
        messageMutableString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: NSRange(location:message.count,length: hangmanPresenter.originalWord.count))
        
        let color = (messageType == MessageType.Sucess) ? sucessColor : errorColor
        messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location:message.count,length:hangmanPresenter.originalWord.count))
        
        return messageMutableString
        
    }
    
    func startGame(){
        self.hangmanPresenter.startGame()
    }
    
    func assignImageToVolumeButton(_ nameOfImageToAssign :String) {
        if let image = UIImage(named: nameOfImageToAssign){
            volumeButton.setImage(image, for: .normal)
        }
    }
    
    func showFailedSolution() {
        //play dead effect before die
        hangmanPresenter.playEffectWithString(nameOfDeadEffect)
        
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
            self.hangmanPresenter.startGame()
        })
        
        present(ac,animated: true)
    }
    
    func changeHangmanImg(literalName: String) {
        imageHangMan.image = UIImage(imageLiteralResourceName: literalName)
    }
    
    func getCurrentWordLabel() -> String{
        guard let wordLabel = wordLabel.text else {return ""}
        return wordLabel
    }
    
    @objc internal func changeTextWordLabel(text: String) {
        wordLabel.text = text.uppercased()
        wordLabel.addCharacterSpacing(characterSpacing)
    }
    
    func resetView(){
        life.progress = 100
        life.progressTintColor = .green
        imageHangMan.image = nil
    }
    
    //Sounds functions
    func prepareMusic(musicURL: URL){
        do {
            backgroundMusicAvAudioPlayer = try AVAudioPlayer(contentsOf: musicURL)
            backgroundMusicAvAudioPlayer?.volume = backgroundMusicVolume
        } catch {
            // couldn't load file :(
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
    
    func showMuteIconAndMuteApp(){
        assignImageToVolumeButton(nameOfMuteIcon)
        backgroundMusicAvAudioPlayer?.volume = 0.0
    }
    
    func showSoundIconAndUnmuteApp(){
        assignImageToVolumeButton(nameOfSoundIcon)
        backgroundMusicAvAudioPlayer?.volume = backgroundMusicVolume
    }
    
    private func playMainSong(){
        //music will loop forever
        backgroundMusicAvAudioPlayer?.numberOfLoops = -1
        backgroundMusicAvAudioPlayer?.play()
    }
    
    
    //life functions
    func changeLifeProgress(_ lifeProgress: Float){
        life.progress = lifeProgress
    }
    
    func getLifeProgress() -> Float {
        return life.progress
    }
    
    func changeLifeColor(red: Float,green: Float,blue: Float,alpha:Float){
        life.progressTintColor = UIColor(red: CGFloat(red),green: CGFloat(green),blue: CGFloat(blue),alpha: CGFloat(alpha))
    }
    
}

extension UILabel {
    func addCharacterSpacing(_ kernValue: Double = 1.30) {
        guard let attributedString: NSMutableAttributedString = {
            if let text = self.text, !text.isEmpty {
                return NSMutableAttributedString(string: text)
            } else if let attributedText = self.attributedText {
                return NSMutableAttributedString(attributedString: attributedText)
            }
            return nil
            }() else { return}
        
        attributedString.addAttribute(
            NSAttributedString.Key.kern,
            value: kernValue,
            range: NSRange(location: 0, length: attributedString.length)
        )
        self.attributedText = attributedString
    }
}
