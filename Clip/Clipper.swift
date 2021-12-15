//
//  Clipper.swift
//  Clip
//

import Foundation
import AVFAudio
import AppKit

class Clipper {
    // Input bus -- default is 0, so that's what we use
    static let BUS = 0

    // Audio Engine we pull input from
    let audioEngine = AVAudioEngine()
    // Queue of buffers (kept at clipSeconds / 0.4 length)
    var buffers: [AVAudioPCMBuffer] = []
    // Length of clip in seconds -- stored in UserDefaults for persistence
    var clipSeconds = UserDefaults.standard.double(forKey: "clipSeconds")

    init() {
        // If first startup, clipSeconds won't be in UserDefaults,
        // so set to default value
        if self.clipSeconds == 0.0 {
            self.clipSeconds = 30
            UserDefaults.standard.set(30.0, forKey: "clipSeconds")
        }
        
        // Register input tap to add buffers to queue
        self.audioEngine.inputNode.installTap(onBus: Clipper.BUS, bufferSize: 20480, format: audioEngine.inputNode.inputFormat(forBus: Clipper.BUS)) {
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
            self.buffers.append(buffer)
            while (self.buffers.count > Int(self.clipSeconds / 0.4)) {
                self.buffers.removeFirst()
            }
        }
        
        // Start engine
        self.audioEngine.prepare()
        try! self.audioEngine.start()
        
        // Create directory for clips if it doesn't exist
        let dataPath = URL(string: "\(FileManager.default.currentDirectoryPath)/Clips")!
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            try! FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    deinit {
        self.audioEngine.stop()
    }
    
    // Clip the last clipSeconds seconds into a file, and show it.
    func clip() {
        // Create name of clip with current datetime
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy--h.mm.ss-a"
        let name = df.string(from: Date.now)
        let filePath = "\(FileManager.default.currentDirectoryPath)/Clips/\(name).wav"
        
        // Write buffers sequentially to audio file
        let settings = self.buffers[0].format.settings
        var file = try? AVAudioFile(forWriting: URL(string: filePath)!, settings: settings)
        for buffer in self.buffers {
            try! file?.write(from: buffer)
        }
        
        // Set file to nil to tell ARC to clean it up and write to it
        file = nil
        // Open directory to clip
        self.openClipDir(filePath: filePath)
    }
    
    // Update the clipSeconds variable in the object and in UserDefaults
    // Used by SwiftUI
    func updateClipSeconds(quantity: Double) {
        self.clipSeconds = quantity
        UserDefaults.standard.set(quantity, forKey: "clipSeconds")
    }
    
    // Open clipDir, either to the directory as a whole
    // or with the file highlighted if specified
    func openClipDir(filePath: String? = nil) {
        NSWorkspace.shared.selectFile(filePath, inFileViewerRootedAtPath: "\(FileManager.default.currentDirectoryPath)/Clips/")
    }
}
