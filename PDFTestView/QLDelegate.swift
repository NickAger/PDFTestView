//
//  QLDelegate.swift
//  PDFTestView
//
//  Created by Nick Ager on 29/05/2016.
//  Copyright © 2016 RocketBox Ltd. All rights reserved.
//

import UIKit
import QuickLook
import NACommonUtils

final class QLDelegate : NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate, KeepInMemoryMixin {
    let urlHolder : SecurityScopedURLHolder
    var keepInMemory: QLDelegate?
    
    init(urlHolder: SecurityScopedURLHolder) {
        self.urlHolder = urlHolder
        super.init()
        keepOurselvesInMemory()
    }
    
    @objc func numberOfPreviewItemsInPreviewController(controller: QLPreviewController) -> Int {
        return 1
    }
    
    @objc func previewController(controller: QLPreviewController, previewItemAtIndex index: Int) -> QLPreviewItem {
        return urlHolder.fileURL
    }
    
    @objc func previewControllerDidDismiss(controller: QLPreviewController) {
        freeOurselvesFromMemory()
    }
}
