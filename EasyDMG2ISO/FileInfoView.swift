//
//  FileInfoView.swift
//  DMG2ISO
//
//  Created by Flavius12 on 09/11/2020.
//  Copyright © 2020 EvolSoft. All rights reserved.
//

import Cocoa;

struct FileInfo {
    let fileUrl : URL?;
    let fileSize: UInt64;
}

class FileInfoView : NSView {
    
    var fileInfo : FileInfo = {return FileInfo(fileUrl: nil, fileSize: 0)}();
    
    @IBOutlet var tabView : NSTabView!
    
    @IBOutlet var fileIcon : NSImageView!
    
    
    @IBOutlet var fileName: NSTextField!
    @IBOutlet var filePath: NSTextField!
    @IBOutlet var fileSize: NSTextField!
    
    @IBOutlet var fileFormat: NSPopUpButton!
    
    @IBOutlet var buttonBack : NSButton!
    @IBOutlet var buttonConvert : NSButton!
    
    @IBOutlet var progressView : ProgressView!
    
    @IBOutlet var statusView: StatusView!
    
    func setFileInfo(fileInfo: FileInfo){
        self.fileInfo = fileInfo;
        fileName.stringValue = fileInfo.fileUrl!.lastPathComponent;
        filePath.stringValue = fileInfo.fileUrl!.path;
        fileSize.stringValue = ByteCountFormatter.string(fromByteCount: Int64(fileInfo.fileSize), countStyle: ByteCountFormatter.CountStyle.file);
        fileFormat.selectItem(at: 0); //Reset selected format to ISO
    }
    
    override func viewWillDraw(){
        super.viewWillDraw();
        fileIcon.image = NSWorkspace.shared.icon(forFileType: "dmg");
    }
    
    @IBAction func onButtonBackClick(_ sender: Any) {
        tabView.selectTabViewItem(at: 0);
    }
    
    @IBAction func onButtonConvertClick(_ sender: Any) {
        var status : Bool;
        let dialog = NSSavePanel();
        if(fileFormat.selectedItem?.tag == 0){
            dialog.title = "Choose a .iso file"; //TODO Change
            dialog.nameFieldStringValue = fileInfo.fileUrl?.deletingPathExtension().appendingPathExtension("iso").lastPathComponent as! String;
                       dialog.allowedFileTypes = ["iso"];
        }else{
            dialog.title = "Choose a .cdr file"; //TODO change
             dialog.nameFieldStringValue =  fileInfo.fileUrl?.deletingPathExtension().appendingPathExtension("cdr").lastPathComponent as! String;
            dialog.allowedFileTypes = ["cdr"];
        }
        if(dialog.runModal() == NSApplication.ModalResponse.OK){
            if(fileFormat.selectedItem?.tag == 0){
                status = ConvertToIso(destFile: dialog.url!);
            }else{
                status = ConvertToCdr(destFile: dialog.url!);
            }
            statusView.outputPath = dialog.url!;
            tabView.selectTabViewItem(at: 2);
        }
    }
    
    func deleteFileIfExists(filePath: String) -> Bool {
        let fileManager = FileManager.default;
        if(fileManager.fileExists(atPath: filePath)){
            do{
                try fileManager.removeItem(atPath: filePath);
                return true;
            }catch{
                return false;
            }
        }
        return false;
    }
    
    public func ConvertToIso(destFile: URL) -> Bool {
        /*
        //$ hdiutil convert -format UDTO -o [filename].cdr [filename].dmg
        //$ hdiutil makehybrid -iso -joliet -o [filename].iso [filename].cdr
        var cdrTempFile: URL = destFile.deletingPathExtension().appendingPathExtension("cdr");
        ConvertToCdr(destFile: cdrTempFile);
        print("ISO: SRC: " + cdrTempFile.path + " DEST: " + destFile.path);
        let process = Process();
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil");
        process.arguments = ["makehybrid", "-iso", "-joliet", "-o", destFile.path, cdrTempFile.path];
        try? process.run()
        process.waitUntilExit();
        return true;*/
        //$ hdiutil makehybrid -iso -joliet -o [filename].iso [filename].dmg
        // From there, get your UIStoryboard reference from the
        // rootViewController in your UIWindow
        /*alert.beginSheetModal(for: NSApplication.shared.keyWindow!, completionHandler: { (response) in
            
        });*/
        //TODO Replace if file exists
        progressView.statusText.stringValue = "Converting " + fileInfo.fileUrl!.lastPathComponent + " to ISO...";
        showProgressDialog();
        deleteFileIfExists(filePath: destFile.path);
        let process = Process();
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil");
        //print("ISO: SRC: " + fileInfo.fileUrl!.path + " DEST: " + destFile.path)
        process.arguments = ["makehybrid", "-iso", "-joliet", "-o", destFile.path, fileInfo.fileUrl!.path];
        process.qualityOfService = QualityOfService.utility;
        try? process.run()
        process.waitUntilExit();
        closeProgressDialog();
        return true;
    }
    
    public func ConvertToCdr(destFile: URL) -> Bool {
        //$ hdiutil convert -format UDTO -o [filename].cdr [filename].dmg
        //TODO Replace if file exists
        progressView.statusText.stringValue = "Converting " + fileInfo.fileUrl!.lastPathComponent + " to CDR...";
        showProgressDialog();
        deleteFileIfExists(filePath: destFile.path);
        let process = Process();
        //print("CDR: SRC: " + fileInfo.fileUrl!.path + " DEST: " + destFile.path)
        process.executableURL = URL(fileURLWithPath: "/usr/bin/hdiutil");
        process.arguments = ["convert", "-format", "UDTO", "-o", destFile.path, fileInfo.fileUrl!.path];
        try? process.run()
        process.waitUntilExit();
        closeProgressDialog();
        return true;
    }
    
    func showProgressDialog(){
        progressView.progressBar.startAnimation(self);  //Big Sur Fix
        window!.beginSheet(progressView.window!) {(response) in
            //self.testWindowSheet.makeKeyAndOrderFront(self);
        }
        fileFormat.isEnabled = false;
        buttonBack.isEnabled = false;
        buttonConvert.isEnabled = false;
    }
    
    func closeProgressDialog(){
        progressView.progressBar.stopAnimation(self);  //Big Sur Fix
        progressView.window!.close();
        fileFormat.isEnabled = true;
        buttonBack.isEnabled = true;
        buttonConvert.isEnabled = true;
    }
}
