//
//  InspectionSectionedViewController.swift
//  Inspection
//
//  Created by Shaps Benkau on 26/02/2018.
//

import UIKit

internal class InspectionSectionedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    internal let tableView: UITableView
    internal unowned let inspection: Inspection
    
    internal init(inspection: Inspection) {
        self.inspection = inspection
        self.tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        prepareNavigationBar()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func sectionTitle(for section: Int) -> String {
        return "Inspection"
    }
    
    func sectionIsExpanded(for section: Int) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InspectorCell", for: indexPath) as! InspectionInspectorCell
        
        cell.detailTextLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.textColor = inspection.options.theme.primaryTextColor
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        cell.textLabel?.textColor = inspection.options.theme.secondaryTextColor
        
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.editingAccessoryView = nil
        cell.editingAccessoryType = .none
        
        cell.selectedBackgroundView?.backgroundColor = inspection.options.theme.selectedBackgroundColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CollapsibleSectionHeaderView") as! CollapsibleSectionHeaderView
        header.contentView.backgroundColor = inspection.options.theme.backgroundColor
        header.label.text = sectionTitle(for: section)
        header.label.font = UIFont.systemFont(ofSize: 15, weight: .black)
        header.label.textColor = inspection.options.theme.primaryTextColor
        header.setExpanded(sectionIsExpanded(for: section))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sectionIsExpanded(for: indexPath.section) ? UITableViewAutomaticDimension : 0
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return inspection.supportedOrientations
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return inspection.previousStatusBarStyle
    }
    
}

extension InspectionSectionedViewController {
    
    private func prepareNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = inspection.options.theme.backgroundColor
        navigationController?.navigationBar.tintColor = inspection.options.theme.primaryTextColor
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            
            guard navigationController?.viewControllers.count == 1 || self is ReportViewController else {
                navigationItem.largeTitleDisplayMode = .never
                return
            }
            
            navigationItem.largeTitleDisplayMode = .always
        }
    }
    
    private func prepareTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.estimatedSectionHeaderHeight = 44
        tableView.estimatedSectionFooterHeight = 0
        tableView.keyboardDismissMode = .interactive
        
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = inspection.options.theme.backgroundColor
        tableView.separatorColor = inspection.options.theme.separatorColor
        tableView.separatorStyle = inspection.options.theme == .light ? .singleLine : .none
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        tableView.register(InspectionInspectorCell.self, forCellReuseIdentifier: "InspectorCell")
        tableView.register(PreviewCell.self, forCellReuseIdentifier: "PreviewCell")
        tableView.register(CollapsibleSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "CollapsibleSectionHeaderView")
        
        view.addSubview(tableView, constraints: [
            equal(\.leadingAnchor), equal(\.trailingAnchor),
            equal(\.bottomAnchor), equal(\.topAnchor)
            ])
    }
    
}
