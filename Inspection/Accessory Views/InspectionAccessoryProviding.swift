//
//  InspectionAccessoryProviding.swift
//  Inspection
//
//  Created by Shaps Benkau on 28/03/2018.
//

import Foundation

public protocol InspectionAccessoryProviding {
    var theme: InspectionTheme { get set }
    var intrinsicContentSize: CGSize { get }
}
