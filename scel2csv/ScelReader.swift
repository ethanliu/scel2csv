//
//  ScelReader.swift
//  scel2csv
//
//  Created by Ethan Liu on 2018/9/15.
//  Copyright © 2018 Ethan. All rights reserved.
//

import Foundation

final public class SogouDictionaryReader {
    
    var name = ""
    var category = ""
    var description = ""
    var example = ""
    
    fileprivate var path: URL?
    fileprivate var address = [Int]()
    
    fileprivate var pinyinTable: [Int: String]?
    fileprivate var lexiconTable = [String: [String]]()
    
    var debugDescription: String {
        return "Name: \(self.name)\nCategory: \(self.category)\nDescription: \(self.description)\nExample: \(self.example)\n"
    }
    
    // MARK: Lifecycle
    
    init(_ path: URL) {
        self.path = path
    }
    
    // MARK: Public
    
    public func load() -> Bool {
        guard let url = self.path, let stream = InputStream(url: url) else {
            return false
        }
        
        stream.open()
        //        defer {
        //            stream.close()
        //        }
        
        guard self.validHeader(stream) else {
            return false
        }
        
        self.getName(stream)
        self.getCategory(stream)
        self.getDescription(stream)
        self.getExample(stream)
        
        if self.validPinyinTableHeader(stream) == false {
            return false
        }
        
        self.getPinyinTable(stream)
        self.getLexiconTable(stream)
        
        stream.close()
        
        self.pinyinTable = nil
        
        return true
    }
    
    public func getLexicon() -> [String: [String]] {
        return self.lexiconTable
    }
    
    // MARK: private
    
    fileprivate func validHeader(_ stream: InputStream) -> Bool {
        let blockLength = 0x130
        var buffer: [UInt8] = [UInt8](repeating: 0, count: blockLength)
        
        stream.read(&buffer, maxLength: blockLength)
        
        if buffer[..<12] == [0x40, 0x15, 0x00, 0x00, 0x44, 0x43, 0x53, 0x01, 0x01, 0x00, 0x00, 0x00] {
            self.address = [0x130, 0x338, 0x540, 0xd40, 0x1540, 0x2628]
        }
        else if buffer[..<12] == [0x40, 0x15, 0x00, 0x00, 0x45, 0x43, 0x53, 0x01, 0x01, 0x00, 0x00, 0x00] {
            self.address = [0x130, 0x338, 0x540, 0xd40, 0x1540, 0x26c4]
        }
        
        return self.address.count > 0 ? true : false
    }
    
    fileprivate func validPinyinTableHeader(_ stream: InputStream) -> Bool {
        let blockLength = 4
        var buffer: [UInt8] = [UInt8](repeating: 0, count: blockLength)
        let length = stream.read(&buffer, maxLength: blockLength)
        
        if length == blockLength, buffer == [0x9D, 0x01, 0x00, 0x00] {
            return true
        }
        
        return false
    }
    
    fileprivate func getName(_ stream: InputStream) {
        let blockLength = self.address[1] - self.address[0]
        var buffer: [UInt8] = [UInt8](repeating: 0, count: blockLength)
        let length = stream.read(&buffer, maxLength: blockLength)
        
        var text = ""
        for i in stride(from: 0, to: length, by: 2) {
            if let word = self.byteToString(bytes: Array(buffer[i...(i+1)])) {
                text += word
            }
        }
        
        self.name = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    fileprivate func getCategory(_ stream: InputStream) {
        let blockLength = self.address[2] - self.address[1]
        var buffer: [UInt8] = [UInt8](repeating: 0, count: blockLength)
        let length = stream.read(&buffer, maxLength: blockLength)
        
        var text = ""
        for i in stride(from: 0, to: length, by: 2) {
            if let word = self.byteToString(bytes: Array(buffer[i...(i+1)])) {
                text += word
            }
        }
        
        self.category = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    fileprivate func getDescription(_ stream: InputStream) {
        let blockLength = self.address[3] - self.address[2]
        var buffer: [UInt8] = [UInt8](repeating: 0, count: blockLength)
        let length = stream.read(&buffer, maxLength: blockLength)
        
        var text = ""
        for i in stride(from: 0, to: length, by: 2) {
            if let word = self.byteToString(bytes: Array(buffer[i...(i+1)])) {
                text += word
            }
        }
        
        self.description = text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    fileprivate func getExample(_ stream: InputStream) {
        let blockLength = self.address[4] - self.address[3]
        var buffer: [UInt8] = [UInt8](repeating: 0, count: blockLength)
        let length = stream.read(&buffer, maxLength: blockLength)
        
        var text = ""
        for i in stride(from: 0, to: length, by: 2) {
            if let word = self.byteToString(bytes: Array(buffer[i...(i+1)])) {
                text += word
            }
        }
        
        self.example = text
    }
    
    fileprivate func getPinyinTable(_ stream: InputStream) {
        
        self.pinyinTable = [:]
        
        let blockLength = self.address[5] - self.address[4] - 4
        var buffer: [UInt8] = [UInt8](repeating: 0, count: blockLength)
        let length = stream.read(&buffer, maxLength: blockLength)
        
        var pos: Int = 0
        var index: Int = 0
        var size = 0
        var text = ""
        
        while pos < length {
            index = Int(buffer[pos]) + Int(buffer[pos + 1]) * 255
            pos += 2
            size = Int(buffer[pos]) + Int(buffer[pos + 1]) * 255
            pos += 2
            
            text = ""
            for i in pos..<(pos + size) {
                if let word = self.byteToString(bytes: [buffer[i], 0]) {
                    text += word
                }
            }
            
            text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.pinyinTable![index] = text
            text = ""
            
            pos += size
        }
    }
    
    fileprivate func getPinyin(_ buffer: [UInt8]) -> String {
        var pos = 0
        var text = ""
        while pos < buffer.count {
            let index = Int(buffer[pos]) + Int(buffer[pos + 1]) * 255
            text += self.pinyinTable?[index] ?? ""
            pos += 2
        }
        
        return text
    }
    
    fileprivate func getLexiconTable(_ stream: InputStream) {
        var buffer: [UInt8] = [UInt8](repeating: 0, count: 64)
        var length = 0
        var amountOfLexicon = 0
        var lengthOfPinyin = 0
        var lengthOfLexicon = 0
        
        while stream.hasBytesAvailable {
            
            _ = stream.read(&buffer, maxLength: 4)
            
            amountOfLexicon = Int(buffer[0]) + Int(buffer[1]) * 255
            lengthOfPinyin = Int(buffer[2]) + Int(buffer[3]) * 255
            
            length = stream.read(&buffer, maxLength: lengthOfPinyin)
            let pinyin = self.getPinyin(Array(buffer[0..<length]))
            
            var lexicon = [String]()
            
            for _ in 0 ..< amountOfLexicon {
                _ = stream.read(&buffer, maxLength: 2)
                lengthOfLexicon = Int(buffer[0]) + Int(buffer[1]) * 255
                _ = stream.read(&buffer, maxLength: lengthOfLexicon)
                
                var text = ""
                for i in stride(from: 0, to: lengthOfLexicon, by: 2) {
                    if let word = self.byteToString(bytes: Array(buffer[i...(i+1)])), word != "\n" {
                        text += word
                    }
                }
                
                text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                lexicon.append(text)
                
                // skip next 12 bytes leading by \n
                _ = stream.read(&buffer, maxLength: 12)
            }
            
            self.lexiconTable[pinyin] = lexicon
            
        }
        
        
    }
    
    
    
    // MARK: Utility
    
    fileprivate func byteToString(bytes: [UInt8]) -> String? {
        guard bytes != [0, 0], bytes != [1, 0],  let text = String(bytes: bytes, encoding: .utf16LittleEndian) else {
            return nil
        }
        
        if bytes == [32, 0] || bytes == [10, 0] {
            return "\n"
        }
        
        //        if text == "\r" || text == "\n" || text == "\t" || text == "\r\n" || text == "\n\r" {
        //            print("newline")
        //            return "\n"
        //        }
        
        return text
    }
    
    
}
