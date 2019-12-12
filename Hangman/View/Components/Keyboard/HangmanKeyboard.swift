//
//  HangmanKeyboard.swift
//  Hangman
//
//  Created by Plexus on 03/12/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import UIKit

public protocol HangmangKeyboardDelegate: class {
    func keyDidTapped(key: String)
}

@IBDesignable
public class HangmanKeyboard: UIView, ViewComponent {
    
    public var keyButtons = [UIButton]()
    
    // MARK: - Outlets
    
    @IBOutlet var qButton: UIButton!
    @IBOutlet var wButton: UIButton!
    @IBOutlet var eButton: UIButton!
    @IBOutlet var rButton: UIButton!
    @IBOutlet var tButton: UIButton!
    @IBOutlet var yButton: UIButton!
    @IBOutlet var uButton: UIButton!
    @IBOutlet var iButton: UIButton!
    @IBOutlet var oButton: UIButton!
    @IBOutlet var pButton: UIButton!
    @IBOutlet var aButton: UIButton!
    @IBOutlet var sButton: UIButton!
    @IBOutlet var dButton: UIButton!
    @IBOutlet var fButton: UIButton!
    @IBOutlet var gButton: UIButton!
    @IBOutlet var hButton: UIButton!
    @IBOutlet var jButton: UIButton!
    @IBOutlet var kButton: UIButton!
    @IBOutlet var lButton: UIButton!
    @IBOutlet var nnButton: UIButton!
    @IBOutlet var zButton: UIButton!
    @IBOutlet var xButton: UIButton!
    @IBOutlet var cButton: UIButton!
    @IBOutlet var vButton: UIButton!
    @IBOutlet var bButton: UIButton!
    @IBOutlet var nButton: UIButton!
    @IBOutlet var mButton: UIButton!
 
    
    // MARK: - Outlet Actions
    
    @IBAction func qButtonTouchUp(_ sender: UIButton) {
        guard let currentTitle = sender.currentTitle else { return }
        
        delegate?.keyDidTapped(key: currentTitle)
    }
    
    // MARK: - Class Properties
    
    public var delegate: HangmangKeyboardDelegate?
    
    // MARK: - UI Properties
    
    public var view: UIView!
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        setupButtons()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        setupButtons()
    }
    
    // MARK: - Public Functions
    
    public func changeKey(forKey value: String, withResult: Utils.PlayedResult) {
        guard let button = keyButtons.first(where: { $0.currentTitle == value })
            else { return }
        
            switch withResult {
            case .failed:
                    button.setTitleColor(.red, for: .normal)
                    button.isUserInteractionEnabled = false
                    break
            case .used:
                    button.setTitleColor(.gray, for: .normal)
                    button.isUserInteractionEnabled = false
                    break
            default:
                    button.setTitleColor(.black, for: .normal)
                    break
            }
    }
    
    /// Disable key and set color to gray.
    public func disableWord(_ word: String) {
        guard let button = keyButtons.first(where: { $0.currentTitle == word })
            else { return }
        button.setTitleColor(.gray, for: .normal)
        button.isUserInteractionEnabled = false
    }
    
    /// Enable key and set color to black.
    public func enableWord(_ word: String) {
        guard let button = keyButtons.first(where: { $0.currentTitle == word })
            else { return }
        button.setTitleColor(.black, for: .normal)
        button.isUserInteractionEnabled = true
    }
    
    /// Disable key and set color to red.
    public func setErrorKey(_ word: String) {
        guard let button = keyButtons.first(where: { $0.currentTitle == word })
            else { return }
        button.setTitleColor(.red, for: .normal)
        button.isUserInteractionEnabled = false
    }
    
    public func reloadKeyBoard(){
        keyButtons.forEach { (button) in
            button.setTitleColor(.black, for: .normal)
            button.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Setup Buttons
    
    public func setupButtons() {
        keyButtons = [qButton,wButton,eButton,rButton,tButton,yButton,uButton,iButton,oButton,pButton,aButton,sButton,dButton,fButton,gButton,hButton,jButton,kButton,lButton,nnButton,zButton,xButton,cButton,vButton,bButton,nButton,mButton]
    }
    
    // MARK: - Setup UI
    
    public func setupUI() {
        backgroundColor = .clear
        view.backgroundColor = .clear
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        view.prepareForInterfaceBuilder()
    }
    
    
    
}
