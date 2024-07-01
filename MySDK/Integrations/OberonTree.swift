//
//  OberonTree.swift
//  MySDK
//
//  Created by Creonit on 27.06.2024.
//

import Foundation
import os.log


public class OberonLogger {
    static let shared = OberonLogger()

    private init() {}

    public func log(priority: OSLogType, tag: String? = nil, message: String, error: Error? = nil) {
        LogScope.shared.logInfo(identification: message);
    }
}



public class PrintInterceptor {
    private var originalStdout: Int32
    private var pipe: Pipe
    private var fileHandle: FileHandle
    
    init() {
        originalStdout = dup(STDOUT_FILENO)
        pipe = Pipe()
        fileHandle = pipe.fileHandleForReading
        
        dup2(pipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        
        fileHandle.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                self.handlePrint(output)
            }
        }
    }
    
    deinit {
        fflush(stdout)
        dup2(originalStdout, STDOUT_FILENO)
        fileHandle.readabilityHandler = nil
    }
    
    private func handlePrint(_ message: String) {
        // Здесь вы можете обработать или логировать перехваченные сообщения
        print("Intercepted print: \(message)", terminator: "")
        LogScope.shared.logInfo(identification: message);
    }
}

