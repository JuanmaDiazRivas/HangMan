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
        presenter?.useLetter(letter: key)
    }
}

// MARK: - HangmanPresenterDelegate
extension ViewController: HangManPresenterDelegate {
    func informAttemptFailed(triesLeft: Float) {
        hangmanCorpse.prepareNextAttempt(triesLeft: triesLeft)
    }
    
    
    func showResult(alertController: UIAlertController) {
        present(alertController,animated: true)
    }
    
    
    func changeSoundIcon(image: UIImage) {
        self.soundButton.setImage(image, for: .normal)
    }
    
    func changeTextWordLabel(text: String) {
        hangmanCorpse.changeMainWord(newWord: text)
    }
    
    func resetView(progress: Float, tintColor: UIColor){
        life.progress = progress
        life.progressTintColor = tintColor
        hangmanCorpse.resetCorpse()
        hangmanKeyboard.reloadKeyBoard()
    }
    
    func changeLifeProgress(_ lifeProgress: Float){
        life.setProgress(lifeProgress, animated: true)
    }
    
    func changeLifeColor(red: Float,green: Float,blue: Float,alpha:Float){
        life.progressTintColor = UIColor(red: CGFloat(red),green: CGFloat(green),blue: CGFloat(blue),alpha: CGFloat(alpha))
    }
    
    func enableKey(_ key: String) {
        hangmanKeyboard.enableWord(key)
    }
    
    func disableKey(_ key: String) {
        hangmanKeyboard.disableWord(key)
    }
    
    func setErrorKey(_ key: String) {
        hangmanKeyboard.setErrorKey(key)
    }
    
}
