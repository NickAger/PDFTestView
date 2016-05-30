//
//  DocumentInteractionControllerDelegateImp.swift
//  PDFTestView
//
//  Created by Nick Ager on 30/05/2016.
//  Copyright © 2016 RocketBox Ltd. All rights reserved.
//

import UIKit
import NACommonUtils

final class DocumentInteractionControllerDelegateImp: NSObject, UIDocumentInteractionControllerDelegate, KeepInMemoryMixin {
    var keepInMemory: DocumentInteractionControllerDelegateImp?
    let urlHolder : SecurityScopedURLHolder
    let viewController: UIViewController
    
    init(urlHolder: SecurityScopedURLHolder, viewController: UIViewController) {
        self.urlHolder = urlHolder
        self.viewController = viewController
        super.init()
        keepOurselvesInMemory()
    }
    
    // MARK - UIDocumentInteractionControllerDelegate
    
    func documentInteractionControllerViewControllerForPreview(_: UIDocumentInteractionController) -> UIViewController {
        return viewController
    }
    
    func documentInteractionControllerDidEndPreview(_: UIDocumentInteractionController) {
        freeOurselvesFromMemory()
    }
}
