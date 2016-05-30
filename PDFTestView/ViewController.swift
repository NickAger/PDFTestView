//
//  ViewController.swift
//  PDFTestView
//
//  Created by Nick Ager on 28/05/2016.
//  Copyright © 2016 RocketBox Ltd. All rights reserved.
//

import UIKit
// import NADocumentPicker
import MobileCoreServices
import BrightFutures
import NACommonUtils
import WebKit
import QuickLook
import vfrReader

class ViewController: UIViewController {
    var docController:UIDocumentInteractionController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func uiWebviewTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { urlHolder in
            let pdfViewerController = PDFViewerViewController<UIWebView>()
            pdfViewerController.title = "UIWebView"
            pdfViewerController.urlHolder = urlHolder
            pdfViewerController.setupView = { (view: UIWebView, fileURL: NSURL) in
                let request = NSURLRequest(URL: fileURL)
                view.loadRequest(request)
            }
            self.presentViewController(pdfViewerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func wkWebviewTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { urlHolder in
            let pdfViewerController = PDFViewerViewController<WKWebView>()
            pdfViewerController.title = "WKWebView"
            pdfViewerController.urlHolder = urlHolder
            pdfViewerController.setupView = { (view: WKWebView, fileURL: NSURL) in
                view.loadFileURL(fileURL, allowingReadAccessToURL: fileURL)
            }
            self.presentViewController(pdfViewerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func qlPrevewControllerTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { urlHolder in
            let ql = QLPreviewController()
        
            let delegate = QLDelegate(urlHolder: urlHolder)
            ql.dataSource = delegate
            ql.delegate = delegate
            self.presentViewController(ql, animated: true, completion: nil)
        }
    }
    
    @IBAction func uiDocumentInteractionControllerTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { urlHolder in
            self.docController = UIDocumentInteractionController(URL: urlHolder.fileURL)
            self.docController.delegate = DocumentInteractionControllerDelegateImp(urlHolder: urlHolder, viewController: self)
            self.docController.presentPreviewAnimated(true)
        }
    }
    
    @IBAction func vfrReaderTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { urlHolder in
            let document = ReaderDocument(filePath:urlHolder.fileURL.path!, password: nil)
            let controller = ReaderViewController(readerDocument: document)
            controller.delegate = ReaderViewControllerDelegateImp(urlHolder: urlHolder)
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func documentInteractionControllerOptionTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { urlHolder in
            self.docController = UIDocumentInteractionController(URL: urlHolder.fileURL)
            self.docController.delegate = DocumentInteractionControllerDelegateImp(urlHolder: urlHolder, viewController: self)
            self.docController.presentOptionsMenuFromRect(sender.frame, inView: sender.superview!, animated: true)
        }
    }
    
    @IBAction func documentInteractionControllerOpenInMenuTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { urlHolder in
            self.docController = UIDocumentInteractionController(URL: urlHolder.fileURL)
            self.docController.delegate = DocumentInteractionControllerDelegateImp(urlHolder: urlHolder, viewController: self)
            self.docController.presentOpenInMenuFromRect(sender.frame, inView: sender.superview!, animated: true)
        }
    }
    
    // MARK - helpers
    
    func instantiateViewerController<T>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let pdfViewerController = storyboard.instantiateViewControllerWithIdentifier("PDFViewerViewController")  as! T
        return pdfViewerController
    }

    func selectDocument(sender: UIButton) -> Future<SecurityScopedURLHolder, AnyError> {
        let promise = Promise<SecurityScopedURLHolder, AnyError>()
        
        let urlPickedFuture = NADocumentPicker.show(from: sender, parentViewController: self, documentTypes:[kUTTypePDF as String/*,  "com.apple.iWork.Keynote.key"*/])
        
        urlPickedFuture.onComplete { value in
            switch (value) {
            case let .Success(fileURL):
                let result = SecurityScopedURLHolder.create(fileURL)

                if case .Failure(_) = result {
                    let filename = fileURL.absoluteURL.lastPathComponent!
                    let alertController  = UIAlertController(title:"Unable to load PDF" , message: "Can't load file: '\(filename)'", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (_) -> () in
                        promise.complete(result)
                    }
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    promise.complete(result)
                }
                
            case let .Failure(error):
                promise.failure(error)
            }
            
        }
        return promise.future
    }
}


