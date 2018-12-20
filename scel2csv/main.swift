//
//  main.swift
//  scel2csv
//
//  Created by Ethan Liu on 2018/12/20.
//  Copyright © 2018 Ethan Liu. All rights reserved.
//

import Foundation

let cli = CommandLineKit()

//guard let srcPath = cli.args[.source], let destPath = cli.args[.output] else {
//    cli.printUsage()
//    exit(EX_USAGE)
//}

let srcPath = "/Users/Ethan/Web/www/dummy/日常用词.scel"
let destPath = "/Users/Ethan/Web/www/dummy/日常用词.csv"

let reader = SogouDictionaryReader(URL(fileURLWithPath: srcPath))
if reader.load() == false {
    print("error")
    exit(EXIT_FAILURE)
}

print(reader.name)
print(reader.category)
print(reader.description)
print(reader.example)

try? FileManager.default.removeItem(atPath: destPath)
FileManager.default.createFile(atPath: destPath, contents: nil, attributes: nil)

do {
    let writter = try FileHandle(forWritingTo: URL(fileURLWithPath: destPath))
    writter.seekToEndOfFile()
    
    for (var pinyin, phrases) in reader.getLexicon() {
        pinyin = pinyin.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if pinyin == "" || phrases.isEmpty {
            continue
        }
        
        for var phrase in phrases {
            phrase = phrase.trimmingCharacters(in: .whitespacesAndNewlines)
            if phrase == "" {
                continue
            }
            
            let data = Data("\(phrase)\t0\t\(pinyin)\n".utf8)
            writter.write(data)
        }
    }
    
    writter.closeFile()
    exit(EXIT_SUCCESS)
}
catch {
    print("File open failed")
    print(error)
    exit(EX_USAGE)
}
