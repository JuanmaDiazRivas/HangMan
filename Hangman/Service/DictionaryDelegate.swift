//
//  DictionaryProtocol.swift
//  hangman
//
//  Created by Plexus on 26/11/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import Foundation

protocol DictionaryDelegate: NSObjectProtocol{
    func getDictionary(dictionary:[DictionaryModel])
}
