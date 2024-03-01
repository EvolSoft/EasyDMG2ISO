//
//  StatusView.swift
//  DMG2ISO
//
//  Created by Flavius12 on 11/11/2020.
//  Copyright © 2020 EvolSoft. All rights reserved.
//

import Cocoa;

class StatusView : NSView {
    
    @IBOutlet var tabView : NSTabView!
    
    public var outputPath : URL!
    
    @IBAction func onButtonDoneClick(_ sender: Any) {
        tabView.selectTabViewItem(at: 0); //TODO Add tab indexes in constants!!!
    }
    
    @IBAction func onButtonShowInFinderClick(_ sender: Any) {
        if(!NSWorkspace.shared.selectFile(outputPath.path, inFileViewerRootedAtPath: "")){
            print(dialogOKCancel(question: "File not found", text: "Warning"));
        }
    }
    
    func dialogOKCancel(question: String, text: String) -> Bool {
        var status : Bool = false;
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning;
        alert.addButton(withTitle: "OK")
        //return alert.runModal() == .alertFirstButtonReturn
        alert.beginSheetModal(for: window!) { (response) in
            status = response == .alertFirstButtonReturn;
        }
        return status;
    }
}
