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

class ViewController: UIViewController {
    var docController:UIDocumentInteractionController!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func uiWebviewTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { url in
            let pdfViewerController = PDFViewerViewController<UIWebView>()
            pdfViewerController.title = "UIWebView"
            pdfViewerController.fileURL = url
            pdfViewerController.setupView = { (view: UIWebView, fileURL: NSURL) in
                let request = NSURLRequest(URL: fileURL)
                view.loadRequest(request)
            }
            self.presentViewController(pdfViewerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func wkWebviewTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { url in
            let pdfViewerController = PDFViewerViewController<WKWebView>()
            pdfViewerController.title = "WKWebView"
            pdfViewerController.fileURL = url
            pdfViewerController.setupView = { (view: WKWebView, fileURL: NSURL) in
                view.loadFileURL(fileURL, allowingReadAccessToURL: fileURL)
            }
            self.presentViewController(pdfViewerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func qlPrevewControllerTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { url in
            let ql = QLPreviewController()
        
            let delegate = QLDelegate(fileUrl: url)
            ql.dataSource = delegate
            ql.delegate = delegate
            self.presentViewController(ql, animated: true, completion: nil)
        }
    }
    
    @IBAction func uiDocumentInteractionControllerTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { url in
            self.docController = UIDocumentInteractionController(URL: url)
            self.docController.delegate = self
//            self.docController.presentOptionsMenuFromRect(sender.frame, inView: sender.superview!, animated: true)
            self.docController.presentPreviewAnimated(true)
        }
    }
    
    @IBAction func vfrReaderTapped(sender: UIButton) {
    }
    
    
    @IBAction func documentInteractionControllerOptionTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { url in
            self.docController = UIDocumentInteractionController(URL: url)
            self.docController.presentOptionsMenuFromRect(sender.frame, inView: sender.superview!, animated: true)
            self.docController.presentPreviewAnimated(true)
        }
    }
    
    
    @IBAction func documentInteractionControllerOpenInMenuTapped(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { url in
            self.docController = UIDocumentInteractionController(URL: url)
            self.docController.presentOpenInMenuFromRect(sender.frame, inView: sender.superview!, animated: true)
            self.docController.presentPreviewAnimated(true)
        }
    }
    
    // MARK - helpers
    
    func instantiateViewerController<T>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let pdfViewerController = storyboard.instantiateViewControllerWithIdentifier("PDFViewerViewController")  as! T
        return pdfViewerController
    }

    func selectDocument(sender: UIButton) -> Future<NSURL, AnyError> {
        let promise = Promise<NSURL, AnyError>()
        
        let urlPickedFuture = NADocumentPicker.show(from: sender, parentViewController: self, documentTypes:[kUTTypePDF as String/*,  "com.apple.iWork.Keynote.key"*/])
        
        urlPickedFuture.onComplete { value in
            switch (value) {
            case let .Success(fileURL):
                if !fileURL.startAccessingSecurityScopedResource() {
                    let filename = fileURL.absoluteURL.lastPathComponent!
                    let alertController  = UIAlertController(title:"Unable to load PDF" , message: "Can't load file: '\(filename)'", preferredStyle: .Alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (_) -> () in
                        promise.failure(FileLoadErrors.UnableStartSecurityScopedResource.asAnyError())
                    }
                    alertController.addAction(cancelAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    promise.success(fileURL)
                }
                
            case let .Failure(error):
                promise.failure(error)
            }
            
        }
        return promise.future
    }
}

enum FileLoadErrors : ErrorType, AnyErrorConverter {
    case UnableStartSecurityScopedResource
}

extension ViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

