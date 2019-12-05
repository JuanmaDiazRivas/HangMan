//
//  ViewController.swift
//  hangman
//
//  Created by Plexus on 06/08/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    class var nibName: String {
        return "ViewController"
    }
    
    //IBOutlets
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var life: UIProgressView!
    @IBOutlet var imageHangMan: UIImageView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet var hangmanKeyboard: HangmanKeyboard!
    
    //Presenter
    private let presenter: HangManPresenter? = HangManPresenterImpl()
    
    //Controllers
    override func viewDidLoad() {
        super.viewDidLoad()
        hangmanKeyboard.delegate = self
        presenter?.viewDidLoad(hangmanPresenterDelegate: self)
    }
    
    //IBACTIONS
    @IBAction func changeAudioMode(_ sender: Any) {
        presenter?.changeAudioMode()
    }
    @IBAction func refreshGame(_ sender: Any) {
        presenter?.startGame()
    }
    
    //view function
    func getCurrentWordLabel() -> String{
        guard let wordLabel = wordLabel.text else {return ""}
        return wordLabel
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

// MARK: - HangmangKeyboardDelegate
extension ViewController: HangmangKeyboardDelegate {
    func keyDidTapped(key: String) {
        guard let result = presenter?.playLetter(letter: key) else { return }
        hangmanKeyboard.changeKey(forKey: key, withResult: result)
    }
}

extension ViewController: HangManPresenterDelegate {
    
    func changeSoundIcon(image: UIImage) {
        self.soundButton.imageView?.image  = image
    }
    
    func changeHangmanImg(image: UIImage) {
        self.imageHangMan.image = image
    }
    
    func changeTextWordLabel(text: String, withCharacterSpacing: Double) {
        wordLabel.text = text.uppercased()
        wordLabel.addCharacterSpacing(withCharacterSpacing)
    }
    
    func resetView(progress: Float, tintColor: UIColor){
        life.progress = progress
        life.progressTintColor = tintColor
        imageHangMan.image = nil
    }
    
}
