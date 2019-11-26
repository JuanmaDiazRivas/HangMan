//
//  HangManViewDelegate.swift
//  hangman
//
//  Created by Plexus on 26/11/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import Foundation

protocol HangManViewDelegate: NSObjectProtocol{
    func startGame()
    func changeTextWordLabel(text:String)
    func resetView()
}
