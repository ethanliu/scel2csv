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
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "-s": self = .source
        case "-o": self = .output
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
        print("usage:")
        print("\(executableName) -s source_path -o output_path")
        print("\(executableName) -h to show usage information")
    }
    
    func getOptions() {
        let count = Int(CommandLine.argc)
        let args = CommandLine.arguments
        
        var index = 1
        var option: CommandLineOption
        
        while index < count {
            option = CommandLineOption(value: args[index])

            if option != .unknown, let value = args[index + 1] as String? {
                self.args[option] = value
                index += 2
            }
            else {
                index += 1
            }
        }
        
    }
    
}

