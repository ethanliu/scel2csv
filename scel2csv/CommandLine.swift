//
//  CommandLine.swift
//  scel2csv
//
//  Created by Ethan Liu on 2018/12/20.
//  Copyright © 2018 Ethan Liu. All rights reserved.
//

import Foundation

enum CommandLineOption: String {
    case source = "s"
    case output = "o"
    case transform = "t"
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "-s": self = .source
        case "-o": self = .output
        case "-t": self = .transform
        case "-h": self = .help
        default: self = .unknown
        }
    }
}

class CommandLineKit {
    
    public var args: [CommandLineOption: String] = [:]
    
    init() {
        self.getOptions()
    }
    
    func printUsage() {
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        print("\(executableName) - version 1.0")
        print("Convert Sogou SCEL dictionary to CSV with column lexicon, weight and pinyin")
        print("\nUsage:\n\(executableName) -s scel_path [-o output_csv_path] [-t]")
        print("\nOptions:")
        print("-h to show usage information")
        print("-s scel_path")
        print("-o output_csv_path")
        print("-t to transform from Simplified Chinese to Traditional Chinese")
    }
    
    func getOptions() {
        let count = Int(CommandLine.argc)
        let args = CommandLine.arguments
        
        var index = 1
        var option: CommandLineOption

        self.args[.transform] = ""

        while index < count {
            option = CommandLineOption(value: args[index])

            if option == .transform {
                self.args[.transform] = "1"
            }
            else if option != .unknown, let value = args[index + 1] as String? {
                self.args[option] = value
                index += 2
                continue
            }

            index += 1
        }
        
        
        if self.args[.output] == nil, self.args[.source] != nil {
            self.args[.output] = self.args[.source]?.replacingOccurrences(of: ".scel", with: ".csv")
        }
        
    }
    
}

