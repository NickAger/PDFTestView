//
//  QLDelegate.swift
//  PDFTestView
//
//  Created by Nick Ager on 29/05/2016.
//  Copyright © 2016 RocketBox Ltd. All rights reserved.
//

import UIKit
import QuickLook

class QLDelegate : NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    let fileUrl : NSURL
    var keepInMemory: QLDelegate?
    
    init(fileUrl: NSURL) {
        self.fileUrl = fileUrl
        super.init()
        keepInMemory = self
    }
    
    @objc func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    @objc func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return fileUrl
    }
    
    @objc func previewControllerDidDismiss(controller: QLPreviewController) {
        keepInMemory = nil
    }
}
