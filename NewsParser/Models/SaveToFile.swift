//
//  SaveToFile.swift
//  NewsParser
//
//  Created by Harbros61 on 8.05.21.
//

import Foundation
import AppKit

protocol SaveManager {
    func save()
}

class SaveToFile: SaveManager {
    
    let readFromFirebase: ReadData!
    
    init(readManager: ReadData = ReadFromFirebase()) {
        self.readFromFirebase = readManager
    }
    
    func save() {
        readFromFirebase.getData { result in
            switch result {
            case .success(let data):
                self.saveToFile(data: data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func saveToFile(data: Data) {
        let savePanel = NSSavePanel()
        
        savePanel.directoryURL = FileManager.default.urls(for: .desktopDirectory,
                                                          in: .userDomainMask).first
        
        savePanel.message = "Save json file"
        savePanel.nameFieldStringValue = "jsonNews\(Date())"
        savePanel.showsHiddenFiles = false
        savePanel.showsTagField = false
        savePanel.canCreateDirectories = true
        savePanel.allowsOtherFileTypes = true
        savePanel.isExtensionHidden = true

        if savePanel.runModal() == .OK {
            let url = savePanel.url!
            let finishUrl = url.appendingPathExtension("json")
            
            print(finishUrl)
            do {
//                try String(data: data, encoding: .utf8)!.write(to: finishUrl, atomically: true, encoding: .utf8)
                try data.write(to: finishUrl)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("canceled")
        }
     }
}

