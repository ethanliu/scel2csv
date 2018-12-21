//
//  main.swift
//  scel2csv
//
//  Created by Ethan Liu on 2018/12/20.
//  Copyright © 2018 Ethan Liu. All rights reserved.
//

import Foundation

let cli = CommandLineKit()

guard cli.args[.help] == nil, let srcPath = cli.args[.source], let destPath = cli.args[.output], let weight = cli.args[.weight] else {
    cli.printUsage()
    exit(EX_USAGE)
}

let reader = SogouDictionaryReader(URL(fileURLWithPath: srcPath))
if reader.load() == false {
    print("error")
    exit(EXIT_FAILURE)
}

print("SCEL file: \((srcPath as NSString).lastPathComponent)")
print("CSV file: \((destPath as NSString).lastPathComponent)")
print("\nName: \(reader.name)")
print("Category: \(reader.category)")
print("Description: \(reader.description)")
print("Example:\n\(reader.example)")

try? FileManager.default.removeItem(atPath: destPath)
FileManager.default.createFile(atPath: destPath, contents: nil, attributes: nil)

do {
    let writter = try FileHandle(forWritingTo: URL(fileURLWithPath: destPath))
    writter.seekToEndOfFile()
    
    print("Parsing...")
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
            
            let data = Data("\(phrase)\t\(weight)\t\(pinyin)\n".utf8)
            writter.write(data)
        }
    }
    
    writter.closeFile()
    

    if cli.args[.transform] != nil {
        let tonwen = Tonwen(URL(fileURLWithPath: destPath))
        print("Transform phrases...")
        tonwen.convertPhrases()
        print("Transform words...")
        tonwen.convertWords()
        tonwen.cleanup()
    }
    
    print("done")
    exit(EXIT_SUCCESS)
}
catch {
    print("File open failed")
    print(error)
    exit(EX_USAGE)
}
