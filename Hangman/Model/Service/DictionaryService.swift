//
//  DictionaryService.swift
//  hangman
//
//  Created by Plexus on 26/11/2019.
//  Copyright © 2019 Plexus. All rights reserved.
//

import Foundation

class DictionaryService{
    
    private let resourceName : String = "wordList"
    private let resourceExtension : String = "txt"
    
    func getDictionary() -> [DictionaryModel]{
        
        var dictionaryModel = [DictionaryModel]()
        
        if let content = Bundle.main.url(forResource: resourceName, withExtension: resourceExtension){
            if let startWords = try? String(contentsOf: content){
               let allWords : [String]  = startWords.components(separatedBy: "\n")
                allWords.forEach { (parametro) in
                    dictionaryModel.append(DictionaryModel(word: parametro, definition: ""))
                }
            }
        }
        
        return dictionaryModel
    }
}
