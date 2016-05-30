//
//  SecurityScopedURLHolder.swift
//  PDFTestView
//
//  Ensures that `startAccessingSecurityScopedResource` and `stopAccessingSecurityScopedResource` are called during 
//  creation and destruction, respectively
//
//  Created by Nick Ager on 30/05/2016.
//  Copyright © 2016 RocketBox Ltd. All rights reserved.
//

import UIKit
import NACommonUtils
import Result

enum SecurityScopedURLHolderError : ErrorType, AnyErrorConverter {
    case UnableStartSecurityScopedResource
}

class SecurityScopedURLHolder {
    let fileURL: NSURL
    
    class func create(fileURL: NSURL) -> Result<SecurityScopedURLHolder, AnyError> {
        if let securityScopedURLHolder = SecurityScopedURLHolder(fileURL: fileURL) {
            return Result(value: securityScopedURLHolder)
        }
        return Result(error: SecurityScopedURLHolderError.UnableStartSecurityScopedResource.asAnyError())
    }
    
    init?(fileURL: NSURL) {
        if !fileURL.startAccessingSecurityScopedResource() {
            return nil
        }
        self.fileURL = fileURL
    }

    deinit {
        fileURL.stopAccessingSecurityScopedResource()
    }
}
