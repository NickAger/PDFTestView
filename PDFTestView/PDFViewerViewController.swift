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
        targetView = T()
        targetView.useAutolayout()
        view.addSubview(targetView)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[targetView]|", options:[],metrics:nil, views:["targetView":targetView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[targetView]|", options:[],metrics:nil, views:[ "targetView":targetView]))
    }
}
