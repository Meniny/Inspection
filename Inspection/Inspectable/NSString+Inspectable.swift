//
//  NSString+Inspectionable.swift
//  Inspection
//
//  Created by Shaps Benkau on 10/03/2018.
//

import Foundation

extension NSString {
    
    internal var inspection_preview: UIImage {
        let textView = UITextView()
        
        textView.layoutManager.showsInvisibleCharacters = true
        textView.isSelectable = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textColor = .white
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.text = self as String
        textView.frame.size = CGSize(width: 320, height: 150)
        
        return ImageRenderer(size: textView.bounds.size).image { context in
            textView.drawHierarchy(in: context.format.bounds, afterScreenUpdates: true)
        }
    }
    
    open override func prepareInspection(with coordinator: Coordinator) {
        coordinator.appendPreview(image: inspection_preview, forModel: self)
        
        super.prepareInspection(with: coordinator)
    }
    
}
