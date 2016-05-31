//
//  ListViewerOptionsViewController.swift
//  PDFTestView
//
//  Created by Nick Ager on 31/05/2016.
//  Copyright © 2016 RocketBox Ltd. All rights reserved.
//

import UIKit
import NATableView
import MobileCoreServices
import BrightFutures
import NACommonUtils
import WebKit
import QuickLook
import vfrReader

class ListViewerOptionsViewController: UIViewController {
    var urlHolder: SecurityScopedURLHolder?
    private var collapseDetailViewController = true
    
    @IBOutlet var fileChoosenLabel: UILabel!
    @IBOutlet var tableView: NATableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.preferredDisplayMode = .PrimaryOverlay
        navigationItem.title = "Select a PDF Viewer"
        configureTableView()
        tableView.hidden = true // hidden until urlHolder is valid hmmm ReactiveCocoa would be useful...
        
        splitViewController?.delegate = self
    }

    @IBAction func chooseFilePressed(sender: UIButton) {
        let urlPickedFuture = selectDocument(sender)
        urlPickedFuture.onSuccess { urlHolder in
            self.urlHolder = urlHolder
            self.fileChoosenLabel.text = urlHolder.fileURL.absoluteURL.lastPathComponent
            self.tableView.hidden = false
        }
    }
    
    // MARK - table view
    
    func configureTableView() {
        let cells = [uiwebViewCell(), wkWebViewCell(), qlPreviewControllerCell(), uiDocumentInteractionControllerCell(), vfrReaderCell()]
        let pdfViewerSection = NATableSection(title: "PDF Viewers", cells: cells)
        
        let docMenuSection = NATableSection(title: "Menus", cells: [documentInteractionOptionsMenuCell(), documentInteractionOpenInMenuCell()])
        
        tableView.sections = [pdfViewerSection, docMenuSection]
        
        tableView.anyCellSelectedAction = { [unowned self] (_) in
            if (self.splitViewController?.preferredDisplayMode != .Automatic) {
                self.splitViewController?.preferredDisplayMode = .Automatic
            }
            self.splitViewController?.toggleMasterView()
            self.collapseDetailViewController = false
        }
    }
    
    func uiwebViewCell() -> CellActionPair {
        let cell = createCell("UIWebView")
        
        return (cell, {[unowned self] _ in
            let pdfViewerController = PDFViewerViewController<UIWebView>()
            pdfViewerController.title = "UIWebView"
            pdfViewerController.urlHolder = self.urlHolder!
            pdfViewerController.setupView = { (view: UIWebView, fileURL: NSURL) in
                let request = NSURLRequest(URL: fileURL)
                view.loadRequest(request)
            }
            self.wrapInNavigationControllerAndShow(pdfViewerController)
        })
    }
    
    func wkWebViewCell() -> CellActionPair {
        let cell = createCell("WKWebView")
        
        return (cell, {[unowned self] _ in
            let pdfViewerController = PDFViewerViewController<WKWebView>()
            pdfViewerController.title = "WKWebView"
            pdfViewerController.urlHolder = self.urlHolder!
            pdfViewerController.setupView = { (view: WKWebView, fileURL: NSURL) in
                view.loadFileURL(fileURL, allowingReadAccessToURL: fileURL)
            }
            self.wrapInNavigationControllerAndShow(pdfViewerController)
        })
    }
    
    func qlPreviewControllerCell() -> CellActionPair {
        let cell = createCell("QLPrevewController")
        
        return (cell, { _ in
            let ql = QLPreviewController()

            let delegate = QLDelegate(urlHolder: self.urlHolder!)
            ql.dataSource = delegate
            ql.delegate = delegate
            self.wrapInNavigationControllerAndShow(ql)
        })
    }
    
    func uiDocumentInteractionControllerCell() -> CellActionPair {
        let cell = createCell("UIDocumentInteractionController")
        
        return (cell, { _ in
            let docController = UIDocumentInteractionController(URL: self.urlHolder!.fileURL)
            docController.delegate = DocumentInteractionControllerDelegateImp(urlHolder: self.urlHolder!, viewController: self)
            docController.presentPreviewAnimated(true)
        })
    }
    
    func vfrReaderCell() -> CellActionPair {
        let cell = createCell("VFRReader")
        
        return (cell, { _ in
            let document = ReaderDocument(filePath:self.urlHolder!.fileURL.path!, password: nil)
            let controller = ReaderViewController(readerDocument: document)
            controller.delegate = ReaderViewControllerDelegateImp(urlHolder: self.urlHolder!)
            self.wrapInNavigationControllerAndShow(controller)
        })
    }
    
    func documentInteractionOptionsMenuCell() -> CellActionPair {
        let cell = createCell("OptionsMenu")
        
        return (cell, { [unowned self] aCell in
            let docController = UIDocumentInteractionController(URL: self.urlHolder!.fileURL)
            docController.delegate = DocumentInteractionControllerDelegateImp(urlHolder: self.urlHolder!, viewController: self)
            docController.presentOptionsMenuFromRect(aCell.frame, inView: self.tableView, animated: true)
        })
    }
    
    func documentInteractionOpenInMenuCell() -> CellActionPair {
        let cell = createCell("OpenInMenu")
        
        return (cell, { [unowned self] aCell in
            let docController = UIDocumentInteractionController(URL: self.urlHolder!.fileURL)
            docController.delegate = DocumentInteractionControllerDelegateImp(urlHolder: self.urlHolder!, viewController: self)
            docController.presentOpenInMenuFromRect(aCell.frame, inView: self.tableView, animated: true)
            })
    }
    
    // MARK - helpers
    
    
    func createCell(title: String) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        cell.textLabel?.text = title
        return cell
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
    
    func wrapInNavigationControllerAndShow(viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        self.showDetailViewController(navigationController, sender: self)
        viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        viewController.navigationItem.leftItemsSupplementBackButton = true
    }
}

// see http://nshipster.com/uisplitviewcontroller/ - for iphone in portrait, ensures the master view is displayed initially
extension ListViewerOptionsViewController: UISplitViewControllerDelegate {
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}

extension UISplitViewController {
    func toggleMasterView() {
        let barButtonItem = self.displayModeButtonItem()
        UIApplication.sharedApplication().sendAction(barButtonItem.action, to: barButtonItem.target, from: nil, forEvent: nil)
    }
}
