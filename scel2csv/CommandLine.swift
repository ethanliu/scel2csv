//
//  CommandLine.swift
//  scel2csv
//
//  Created by Ethan Liu on 2018/12/20.
//  Copyright © 2018 Ethan Liu. All rights reserved.
//

import Foundation

enum CommandLineOption: String {
    case help = "h"
    case source = "s"
    case output = "o"
    case transform = "t"
    case weight = "w"
    case unknown
    
    init(value: String) {
        switch value {
        case "-h": self = .help
        case "-s": self = .source
        case "-o": self = .output
        case "-t": self = .transform
        case "-w": self = .weight
        default: self = .unknown
        }
    }
}

class CommandLineKit {
    
    public var args: [CommandLineOption: String] = [:]
    
    init() {
        self.args[.transform] = ""
        self.args[.weight] = "0"

        self.getOptions()
    }
    
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        print("\(executableName) - version 1.0")
        print("Convert Sogou SCEL dictionary to CSV with lexicon, weight and pinyin columns.")
        print("\nUsage:\n\(executableName) -s scel_path [-o output_csv_path] [-w 1234] [-t]")
        print("\nOptions:")
        print("-h to show usage information")
        print("-s scel_path")
        print("-o output_csv_path")
        print("-w lexicon weight")
        print("-t to transform from Simplified Chinese to Traditional Chinese")
    }
    
    func getOptions() {
        let count = Int(CommandLine.argc)
        let args = CommandLine.arguments
        
        var index = 1
        var option: CommandLineOption

        while index < count {
            option = CommandLineOption(value: args[index])

            if option == .help {
                self.args[.help] = "1"
            }
            else if option == .transform {
                self.args[.transform] = "1"
            }
            else if option != .unknown, let value = args[index + 1] as String? {
                self.args[option] = value
                index += 2
                continue
            }

            index += 1
        }
        
        if self.args[.weight]?.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            self.args[.weight] = "0"
        }

        if self.args[.output] == nil, self.args[.source] != nil {
            self.args[.output] = self.args[.source]?.replacingOccurrences(of: ".scel", with: ".csv")
        }
        
    }
    
}

