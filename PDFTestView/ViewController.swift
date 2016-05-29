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

class ViewController: UIViewController {

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
                let request = NSURLRequest(URL: fileURL)
                view.loadRequest(request)
            }
            self.presentViewController(pdfViewerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func qlPrevewControllerTapped(sender: UIButton) {
    }
    
    @IBAction func uiDocumentInteractionControllerTapped(sender: UIButton) {
    }
    
    @IBAction func vfrReaderTapped(sender: UIButton) {
    }
    
    // MARK - helpers
    
    func instantiateViewerController<T>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let pdfViewerController = storyboard.instantiateViewControllerWithIdentifier("PDFViewerViewController")  as! T
        return pdfViewerController
    }

    func selectDocument(sender: UIButton) -> Future<NSURL, AnyError> {
        let promise = Promise<NSURL, AnyError>()
        
        let urlPickedFuture = NADocumentPicker.show(from: sender, parentViewController: self, documentTypes:[kUTTypePDF as String])
        
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