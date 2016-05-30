//
//  ReaderViewControllerDelegateImp.swift
//  PDFTestView
//
//  Created by Nick Ager on 30/05/2016.
//  Copyright © 2016 RocketBox Ltd. All rights reserved.
//

import UIKit
import NACommonUtils
import vfrReader

final class ReaderViewControllerDelegateImp: NSObject, ReaderViewControllerDelegate, KeepInMemoryMixin {
    let urlHolder : SecurityScopedURLHolder
    var keepInMemory: ReaderViewControllerDelegateImp?
    
    init(urlHolder: SecurityScopedURLHolder) {
        self.urlHolder = urlHolder
        super.init()
        keepOurselvesInMemory()
    }
    
    // MARK - ReaderViewControllerDelegate
    
    func dismissReaderViewController(viewController: ReaderViewController!) {
        freeOurselvesFromMemory()
    }
}
