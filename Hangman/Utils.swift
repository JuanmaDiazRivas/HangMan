//
//  Utils.swift
//  Hangman
//
//  Created by Plexus on 05/12/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import Foundation

public class Utils {
    public enum PlayedResult{
        case noChanged,used,failed,win,lose
    }
    
    public static var errorsOnInitAllowed: Float = 7
    
    public static func createUrlWithName(parameter:String) -> URL{
        let path = Bundle.main.path(forResource: parameter, ofType:nil)!
        return URL(fileURLWithPath: path)
    }
}
