//
//  PDFViewerViewController.swift
//  PDFTestViewer
//
//  Created by Nick Ager on 28/05/2016.
//  Copyright © 2016 RocketBox Ltd. All rights reserved.
//

import UIKit

class PDFViewerViewController<T: UIView>: UIViewController {
    var urlHolder: SecurityScopedURLHolder!
    var targetView: T!
    var setupView: ((view: T, fileURL: NSURL) -> ())!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        setupViews()
        setupView(view: targetView, fileURL: urlHolder.fileURL)
    }
    
    func setupViews() {
        let navigationBar = addNavigationBar()

        targetView = T()
        targetView.useAutolayout()
        view.addSubview(targetView)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[navigationBar][targetView]|", options:[],metrics:nil, views:["navigationBar":navigationBar, "targetView":targetView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[targetView]|", options:[],metrics:nil, views:[ "targetView":targetView]))
    }
    
    func addNavigationBar() -> UINavigationBar {
        let navigationBar = UINavigationBar()
        navigationBar.useAutolayout()
        self.view.addSubview(navigationBar)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[navigationBar(60)]", options:[],metrics:nil, views:["navigationBar":navigationBar]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[navigationBar]|", options:[],metrics:nil, views:["navigationBar":navigationBar]))
        
        let navigationItem = UINavigationItem(title: title!)
        
        let leftButton =  UIBarButtonItem(title: "Done", style:   UIBarButtonItemStyle.Done, target: self, action: #selector(closeButtonPressed(_:)))
        
        navigationItem.leftBarButtonItem = leftButton
        navigationBar.items = [navigationItem]
        return navigationBar
    }
    
    @IBAction func closeButtonPressed(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
