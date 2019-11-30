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
    func getCurrentWordLabel() -> String
    func resetView()
    func playEffectWithString(_ efectURL : URL)
    func prepareMusic(musicURL: URL)
    func changeHangmanImg(literalName: String)
    func changeLifeProgress(_ lifeProgress: Float)
    func getLifeProgress() -> Float
    func changeLifeColor(red: Float,green: Float,blue: Float,alpha:Float)
    func showFailedSolution()
    func cleanInputLetter()
    func showMuteIconAndMuteApp()
    func showSoundIconAndUnmuteApp()
}
