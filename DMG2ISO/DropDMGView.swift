//
//  DMG2ISOView.swift
//  DMG2ISO
//
//  Created by Flavius12 on 09/11/2020.
//  Copyright © 2020 EvolSoft. All rights reserved.
//

import Cocoa;

class DropDMGView : NSView {
    
    @IBOutlet var tabView : NSTabView!
    
    @IBOutlet weak var fileInfoView : FileInfoView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        self.wantsLayer = true;
        setOpacity(alpha: 0);
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL]);
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if(checkExtension(sender) == true){
            setOpacity(alpha: 0.5);
            return .copy;
        }else{
            return NSDragOperation();
        }
    }
    
    func setOpacity(alpha: Float){
        self.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor.copy(alpha: CGFloat(alpha));
        //self.layer?.opacity = 1 - alpha;
    }

    fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
              let path = board[0] as? String
        else{
            return false;
        }
        let ext = URL(fileURLWithPath: path).pathExtension;
        if(ext.lowercased() == "dmg"){
            return true;
        }
        return false;
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        setOpacity(alpha: 0);
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
        setOpacity(alpha: 0);
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let pathString = pasteboard[0] as? String
        else{
            return false;
        }
        let path = URL.init(string: pathString);
        LoadDMGFile(fileUrl: path!);
        return true;
    }
    
    @IBAction func onButtonBrowseClick(_ sender: Any){
        let dialog = NSOpenPanel();
        dialog.title = "Choose a .dmg file";
        dialog.canChooseDirectories = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes = ["dmg"];
        if(dialog.runModal() == NSApplication.ModalResponse.OK){
            LoadDMGFile(fileUrl: dialog.url!);
        }
    }
    
    //TODO Drag and Drop actions
    
    func LoadDMGFile(fileUrl: URL){
        do{
            let attr:[FileAttributeKey: Any] = try FileManager.default.attributesOfItem(atPath: fileUrl.path);
            
            fileInfoView.setFileInfo(fileInfo: FileInfo(fileUrl: fileUrl, fileSize: attr[FileAttributeKey.size] as! UInt64));
            tabView.selectTabViewItem(at: 1);
        }catch{
            print("ERROR");
        }
    }
}
