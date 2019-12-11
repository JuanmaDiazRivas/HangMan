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
    
    public func setupUI() {
        backgroundColor = .clear
        view.backgroundColor = .clear
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        view.prepareForInterfaceBuilder()
    }
    
    public func prepareNextAttempt(){
        
    }
    
    
}

