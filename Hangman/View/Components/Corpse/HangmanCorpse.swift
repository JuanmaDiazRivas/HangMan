//
//  HangmanCorpse.swift
//  Hangman
//
//  Created by Plexus on 11/12/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import UIKit

@IBDesignable
public class HangmanCorpse: UIView,ViewComponent{
    public var view: UIView!
    
    @IBOutlet var corpseImg: UIImageView!
    @IBOutlet var mainWord: UILabel!
    
    //MARK: - Constants
    private let characterSpacing : Double = 12
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    //MARK: - Setup UI
    public func setupUI() {
        backgroundColor = .clear
        view.backgroundColor = .clear
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        view.prepareForInterfaceBuilder()
    }
    
    //MARK: - Component methods
    public func prepareNextAttempt(triesLeft: Float){
        if let image = UIImage(named: "\(Int(triesLeft)).png"){
            corpseImg.image = image
        }
    }
    
    public func changeMainWord(newWord: String){
        mainWord.text = newWord.uppercased()
        mainWord.addCharacterSpacing(characterSpacing)
    }
    
    public func resetCorpse(){
        corpseImg.image = nil
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

