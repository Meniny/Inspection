//
//  Coordinator.swift
//  Inspection
//
//  Created by Shaps Benkau on 24/02/2018.
//

import Foundation

@objc public protocol Coordinator: class {
    @discardableResult
    func appendDynamic(keyPaths: [String], forModel model: Inspectionable, in group: Group) -> Coordinator
    @discardableResult
    func appendDynamic(keyPathToName mapping: [[String: String]], forModel model: Inspectionable, in group: Group) -> Coordinator
    @discardableResult
    func appendStatic(keyPath: String, title: String, detail: String?, value: Any?, in group: Group) -> Coordinator
    @discardableResult
    func appendPreview(image: UIImage, forModel model: Inspectionable) -> Coordinator
    @discardableResult
    func appendTransformed(keyPaths: [String], valueTransformer: AttributeValueTransformer?, forModel model: Inspectionable, in group: Group) -> Coordinator
}

internal protocol SwiftCoordinator: Coordinator {
    @discardableResult
    func appendEnum<T>(keyPath: String..., into: T.Type, forModel model: Inspectionable, group: Group) -> Self where T: RawRepresentable & InspectionDescribing & Hashable, T.RawValue == Int
}

internal final class InspectionCoordinator: SwiftCoordinator {
    
    internal unowned let model: Inspectionable
    internal private(set) var groupsMapping: [Group: InspectionGroup] = [:]
    
    internal init(model: Inspectionable) {
        self.model = model
    }
    
    internal func appendPreview(image: UIImage, forModel model: Inspectionable) -> Coordinator {
        guard image.size.width > 0 && image.size.height > 0 else { return self }
        
        let inspectionGroup = groupsMapping[.preview] ?? Group.preview.inspectionGroup()
        groupsMapping[.preview] = inspectionGroup
        inspectionGroup.attributes.insert(PreviewAttribute(image: image), at: 0)
        
        return self
    }
    
    internal func appendDynamic(keyPaths: [String], forModel model: Inspectionable, in group: Group) -> Coordinator {
        return appendTransformed(keyPaths: keyPaths, valueTransformer: nil, forModel: model, in: group)
    }
    
    internal func appendDynamic(keyPathToName mapping: [[String : String]], forModel model: Inspectionable, in group: Group) -> Coordinator {
        let inspectionGroup = groupsMapping[group] ?? group.inspectionGroup()
        groupsMapping[group] = inspectionGroup
        
        inspectionGroup.attributes.insert(contentsOf: mapping.map {
            DynamicAttribute(title: $0.values.first!, keyPath: $0.keys.first!, model: model)
        }, at: inspectionGroup.attributes.count)
        
        return self
    }
    
    internal func appendStatic(keyPath: String, title: String, detail: String? = nil, value: Any?, in group: Group) -> Coordinator {
        let inspectionGroup = groupsMapping[group] ?? group.inspectionGroup()
        groupsMapping[group] = inspectionGroup
        
        let attribute = StaticAttribute(keyPath: keyPath, title: title, detail: detail, value: value)
        inspectionGroup.attributes.insert(attribute, at: inspectionGroup.attributes.count)
        
        return self
    }
    
    internal func appendTransformed(keyPaths: [String], valueTransformer: AttributeValueTransformer?, forModel model: Inspectionable, in group: Group) -> Coordinator {
        let inspectionGroup = groupsMapping[group] ?? group.inspectionGroup()
        groupsMapping[group] = inspectionGroup
        
        inspectionGroup.attributes.insert(contentsOf: keyPaths.map {
            DynamicAttribute(title: String.capitalized($0), detail: nil, keyPath: $0, model: model, valueTransformer: valueTransformer)
        }, at: inspectionGroup.attributes.count)
        
        return self
    }
    
    internal func appendEnum<T>(keyPath: String..., into: T.Type, forModel model: Inspectionable, group: Group) -> Self where T: RawRepresentable & InspectionDescribing & Hashable, T.RawValue == Int {
        let inspectionGroup = groupsMapping[group] ?? group.inspectionGroup()
        groupsMapping[group] = inspectionGroup
        
        inspectionGroup.attributes.insert(contentsOf: keyPath.map {
            EnumAttribute<T>(title: String.capitalized($0), detail: nil, keyPath: $0, model: model, valueTransformer: nil)
        }, at: inspectionGroup.attributes.count)
        
        return self
    }
    
}

extension InspectionCoordinator: CustomStringConvertible {
    
    internal var description: String {
        return """
        \(type(of: self))
        \(groupsMapping.values.map { "▹ \($0)" }.joined(separator: "\n"))
        """
    }
    
}
