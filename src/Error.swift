//
//  Error.swift
//  Renderer
//
//  Created by Arman Uguray on 5/14/20.
//  Copyright © 2020 Arman Uguray. All rights reserved.
//

import Foundation

// Generic error type with an error message. This can be used in situations where more specific
// error-handling is not needed.
enum RendererError: Error {
    case runtimeError(String)
}
