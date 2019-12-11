//
//  ViewController.swift
//  hangman
//
//  Created by Plexus on 06/08/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var life: UIProgressView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet var hangmanKeyboard: HangmanKeyboard!
    @IBOutlet var hangmanCorpse: HangmanCorpse!
    private let presenter: HangManPresenter? = HangManPresenterImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        hangmanKeyboard.delegate = self
        presenter?.viewDidLoad(hangmanPresenterDelegate: self)
    }
    
    // MARK: - IBActions
    @IBAction func changeAudioMode(_ sender: Any) {
        presenter?.changeAudioMode()
    }
    @IBAction func refreshGame(_ sender: Any) {
        presenter?.startGame()
    }
    
}

// MARK: - HangmangKeyboardDelegate
extension ViewController: HangmangKeyboardDelegate {
    
    func keyDidTapped(key: String) {
        guard let result = presenter?.useLetter(letter: key) else { return }
        hangmanKeyboard.changeKey(forKey: key, withResult: result)
        
    }
}

// MARK: - HangmanPresenterDelegate
extension ViewController: HangManPresenterDelegate {
    
    func showResult(alertController: UIAlertController) {
        present(alertController,animated: true)
    }
    
    
    func changeSoundIcon(image: UIImage) {
        self.soundButton.setImage(image, for: .normal)
    }
    
    func informAttemptFailed(image: UIImage) {
        hangmanCorpse.prepareNextAttempt()
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
        hangmanKeyboard.reloadKeyBoard()
    }
    
    func changeLifeProgress(_ lifeProgress: Float){
        life.setProgress(lifeProgress, animated: true)
    }
    
    func changeLifeColor(red: Float,green: Float,blue: Float,alpha:Float){
        life.progressTintColor = UIColor(red: CGFloat(red),green: CGFloat(green),blue: CGFloat(blue),alpha: CGFloat(alpha))
    }
    
}

// MARK: - Extension UILabel
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
