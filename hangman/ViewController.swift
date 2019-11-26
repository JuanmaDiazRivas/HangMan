//
//  ViewController.swift
//  hangman
//
//  Created by Plexus on 06/08/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
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
    var currentWord: String? {
        get {
            return wordLabel.text
        }
        set {
            wordLabel.text = newValue
        }
    }
    var triesLeft = Float()
    enum MessageType : String{
        case Error
        case Sucess
    }
    
    //IBOutlets
    @IBOutlet var contentScroll: UIScrollView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var life: UIProgressView!
    @IBOutlet var letter: UITextField!
    @IBOutlet var button: UIButton!
    @IBOutlet var imageHangMan: UIImageView!
    @IBOutlet weak var volumeButton: UIButton!
    
    //iOS class
    private var backgroundMusicAvAudioPlayer : AVAudioPlayer?
    private var backgroundMusicVolume : Float = 0.5
    private var playEffect : AVAudioPlayer?
    private let sucessColor : UIColor = UIColor.blue
    private let errorColor : UIColor = UIColor.red
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        assignLetterProperties()
        
        loadDictionary()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        prepareMusic()
        
        playMainSong()

    }
    
    @IBAction func playLetter(_ sender: Any) {
        guard let letterUsed = letter.text,
            !letterUsed.isEmpty,
            let modified = modifyWord(letterUsed: Character(letterUsed))
            else { return }
        
            letter.text?.removeAll()
        
        if !modified {
            //play letter effect before decrease hp
            playEffectWithString(nameOfWriteEffect)
            
            decreaseHp()
        }

        if let wordText = wordLabel.text,
            !wordText.contains("_"){
            showSucessSolution()
        }
    }

    private func checkLetterOnWord(_ indexesOnRealWord: inout [Int], _ letterUsed: String ) {
        for i in 0..<originalWord.count{
            if String(originalWord[i]) == letterUsed.lowercased(){
                indexesOnRealWord.append(i)
            }
        }
    }
    
    @IBAction func refreshGame(_ sender: Any) {
        startGame()
    }
    
    fileprivate func assignImageToVolumeButton(_ nameOfImageToAssign :String) {
        if let image = UIImage(named: nameOfImageToAssign){
            volumeButton.setImage(image, for: .normal)
        }
    }
    
    @IBAction func changeAudioMode(_ sender: Any) {
        if !isMuted{
            muteApp(true)
            assignImageToVolumeButton(nameOfMuteIcon)
        }else{
            muteApp(false)
            assignImageToVolumeButton(nameOfSoundIcon)
        }
        
        isMuted = !isMuted
    }
    
    private func muteApp(_ mute:Bool){
        if mute {
            backgroundMusicAvAudioPlayer?.volume = 0.0
        }else{
            backgroundMusicAvAudioPlayer?.volume = backgroundMusicVolume 
        }
        
    }
    
    private func decreaseHp(){
        switchToNextImage()
        
        let decrease = Float((100/errorsOnInitAllowed)/100)
        
        life.progress = life.progress - decrease
        if life.progress <= decrease{
            life.progress = 0
            
            showFailedSolution()
        }
        
        switch life.progress {
            case 0.0..<0.3:
                life.progressTintColor = .red
                break
            case 0.3..<0.6:
                life.progressTintColor = .orange
                break
            default:
                life.progressTintColor = .green
        }
    }
    
    private func switchToNextImage(){
        imageHangMan.image = UIImage(imageLiteralResourceName: "\(Int(triesLeft)).png")
        triesLeft -= 1
    }
    
    @discardableResult
    private func modifyWord(letterUsed : Character) -> Bool?{
        
        guard
            let currentWord = wordLabel.text,
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
             wordLabel.text = String(auxWordArray).uppercased()
             wordLabel.addCharacterSpacing(characterSpacing)
        }
        
        return wordModified
    }
    
    private func modifyWordWithoutReturn(letterUsed : Character){
        guard let currentWord = wordLabel.text, wordLabel.text != "" else {return}
        
        var auxWordArray = Array(currentWord)
        var wordModified = false
        
        for i in 0..<originalWord.count{
            if originalWord[i].uppercased() == letterUsed.uppercased(){
                auxWordArray[i] = letterUsed
                wordModified = true
            }
        }
        
        if wordModified{
            wordLabel.text = String(auxWordArray).uppercased()
            wordLabel.addCharacterSpacing(characterSpacing)
        }
    }
    
    private func loadDictionary() {
        if let content = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension){
            if let startWords = try? String(contentsOf: content){
                allWords = startWords.components(separatedBy: "\n")
            }
        }
    }
    
    private func showFailedSolution() {
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
    
    private func showSucessSolution() {
        
        let message = "\nHas conseguido escapar\n\n Solución.. "
        
        let ac = UIAlertController(title: "Enhorabuena!", message: nil, preferredStyle: .alert)
        
        ac.setValue(formatMessage(message: message, messageType: MessageType.Sucess), forKey: alertControllerKeyMessage)
        
        ac.addAction(UIAlertAction(title: "OK", style: .default){
            (alert:UIAlertAction!) in
            self.startGame()
        })
        
        present(ac,animated: true)
    }
    
    private func formatMessage(message: String,messageType : MessageType) -> NSMutableAttributedString{
        
        var messageMutableString = NSMutableAttributedString()
        messageMutableString = NSMutableAttributedString(string: message + String(originalWord).uppercased(), attributes: [NSAttributedString.Key : Any]())
        messageMutableString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 15), range: NSRange(location:message.count,length: originalWord.count))

        let color = (messageType == MessageType.Sucess) ? sucessColor : errorColor
    messageMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location:message.count,length:originalWord.count))
        
        return messageMutableString
        
    }
    
    private func assignLetterProperties() {
        //making contraints for the textfield
        letter.autocapitalizationType = UITextAutocapitalizationType.allCharacters
        
        letter.delegate = self
        
        letter.addTarget(self, action: #selector(textFieldChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    private func prepareMusic(){
        do {
            backgroundMusicAvAudioPlayer = try AVAudioPlayer(contentsOf: createUrlWithName(parameter: nameOfMainTheme))
            backgroundMusicAvAudioPlayer?.volume = 0.5
        } catch {
            // couldn't load file :(
        }
    }
    
    private func playMainSong(){
        //music will loop forever
        backgroundMusicAvAudioPlayer?.numberOfLoops = -1
        backgroundMusicAvAudioPlayer?.play()
    }
    
    private func playEffectWithString(_ efectname :String){
        if(!isMuted){
            do{
                playEffect = try AVAudioPlayer(contentsOf: createUrlWithName(parameter: efectname))
                playEffect?.play()
            } catch {
                //could not load file :(
            }
        }
        
    }
    private func createUrlWithName(parameter:String) -> URL{
        let path = Bundle.main.path(forResource: parameter, ofType:nil)!
        return URL(fileURLWithPath: path)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func textFieldChange(textField: UITextField){
     dismissKeyboard()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            contentScroll.contentInset = .zero
        } else {
            contentScroll.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        contentScroll.scrollIndicatorInsets = contentScroll.contentInset
    }
    
    
    
    //new methods
    func resetView(){
        life.progress = 100
        life.progressTintColor = .green
        imageHangMan.image = nil
    }
    
    @objc private func changeTextWordLabel(text: String) {
        wordLabel.text = text.uppercased()
        wordLabel.addCharacterSpacing(characterSpacing)
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range:
        NSRange, replacementString string: String) -> Bool {
        
        // Always allow a backspace
        if string.isEmpty {
            return true
        }
        
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        let regex = try! NSRegularExpression(pattern: ".*[A-Za-z].*", options: [])
        
        let onlyLetters = regex.firstMatch(in: string,
                                           options: [],
                                           range: NSMakeRange(0, string.count)) != nil
        
        return count <= textFieldLentgh && onlyLetters
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
