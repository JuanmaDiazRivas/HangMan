//
//  ViewComponent.swift
//  PresentationKit
//
//  Created by Juan Manuel Diaz Rivas on 06/12/2019.
//  Copyright © 2019 jdiaz. All rights reserved.
//

import UIKit

public protocol ViewComponent where Self: UIView {
    var view: UIView! { get set }
    
    func setupUI()
}

extension ViewComponent where Self: UIView {
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    internal func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view = view
        addSubview(view)
        setupUI()
    }
    
}
