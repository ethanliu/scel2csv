//
//  Tonwen.swift
//  scel2csv
//
//  Created by Ethan Liu on 2018/12/21.
//  Copyright © 2018 Ethan Liu. All rights reserved.
//

import Foundation

// Command Line Tools do not use bundles, they are just a raw executable file and are
// not compatible with the copy files build phase or the NSBundle class.

// memory usage and performance is not a concern in current purpose

final public class Tonwen {
    var fileURL: URL
    var phrases: [String: String] = [:]
    var words: [String: String] = [:]
    
    init(_ fileURL: URL) {
        self.fileURL = fileURL
//        self.load("word_s2t", toWords: true)
//        self.load("phrase_s2t", toWords: false)
        
        self.words = kWords
        self.phrases = kPhrases
    }
    
    fileprivate func load(_ filename: String, toWords: Bool) {
        let path = URL(fileURLWithPath: "/tmp/\(filename).txt")
        
        do {
            let data = try String(contentsOf: path).split(separator: "\r\n")
            for line in data {
                let items = line.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
                let s = String(items[0])
                let t = String(items[1])
                
                if s.isEmpty || t.isEmpty {
                    continue
                }
                
                if toWords {
                    self.words[s] = t
                }
                else {
                    self.phrases[s] = t
                }
            }
        }
        catch let error {
            print(error)
            print(error.localizedDescription)
        }
        
//        print(self.words)
//        print(self.phrases)
        
    }
    
    func cleanup() {
        try? FileManager.default.removeItem(atPath: "/tmp/word_s2t.txt")
        try? FileManager.default.removeItem(atPath: "/tmp/phrase_s2t.txt")
    }
    
//    func toHalfWidth(_ text: String) -> String {
//        let _text = NSMutableString(string: text)
//        CFStringTransform(_text, nil, kCFStringTransformFullwidthHalfwidth, false)
//        return String(_text)
//    }
//
    func convertWords() {
        do {
            var data = try String(contentsOf: self.fileURL)
            for (ss, tt) in self.words {
                data = data.replacingOccurrences(of: ss, with: tt)
            }
            try? data.write(to: self.fileURL, atomically: true, encoding: .utf8)
        }
        catch let error {
            print(error)
        }
    }
    
    func convertPhrases() {
        do {
            var data = try String(contentsOf: self.fileURL)
            for (ss, tt) in self.phrases {
                data = data.replacingOccurrences(of: ss, with: tt)
            }
            try? data.write(to: self.fileURL, atomically: true, encoding: .utf8)
        }
        catch let error {
            print(error)
        }
    }
    
}
