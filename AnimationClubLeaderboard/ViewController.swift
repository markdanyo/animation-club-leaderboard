//
//  ViewController.swift
//  AnimationClubLeaderboard
//
//  Created by Mark Daigneault on 11/30/15.
//  Copyright © 2015 Intrepid Pursuits. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let tableViewCellIdentifier = "TableViewCell"
    let names = ["Mark", "Bryan", "Andrew", "Ben", "Logan", "Paul", "Anton", "Lu", "Sara", "Nick", "Colin"]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: tableViewCellIdentifier)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showVisibleCellsAnimated(true)
    }
    
    // MARK: - Animations
    
    private func showVisibleCellsAnimated(animated: Bool) {
        tableView.hidden = false
        
        for cell in tableView.visibleCells {
            cell.transform = CGAffineTransformMakeTranslation(0, tableView.bounds.size.height)
        }
        
        for (index, cell) in tableView.visibleCells.enumerate() {
            let delay = pow(NSTimeInterval(index), 1.5) * 0.025
            UIView.animateWithDuration(0.4,
                delay: delay,
                options: .CurveEaseOut,
                animations: {
                    cell.transform = CGAffineTransformIdentity
                }, completion: nil
            )
        }
    }
    
    private func hideVisibleCellsAnimated(animated: Bool, selectedCell: UITableViewCell? = nil) {
        var selectedCellIndex = NSNotFound
        if let selectedCell = selectedCell {
            selectedCellIndex = tableView.visibleCells.indexOf(selectedCell) ?? NSNotFound
        }
        
        let group = dispatch_group_create()
        
        let visibleCellCount = tableView.visibleCells.count
        for (index, cell) in tableView.visibleCells.enumerate() {
            if index == selectedCellIndex {
                continue
            }
            
            // Don't include selected index in delay calculation
            var delayIndex = index
            if index < selectedCellIndex {
                ++delayIndex
            }
            
            dispatch_group_enter(group)
            
            let delay = pow(NSTimeInterval(visibleCellCount - delayIndex), 1.5) * 0.025
            UIView.animateWithDuration(0.4,
                delay: delay,
                options: .CurveEaseIn,
                animations: {
                    cell.transform = CGAffineTransformMakeTranslation(0, self.tableView.bounds.size.height)
                }, completion: { finished in
                    dispatch_group_leave(group)
                }
            )
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                self.showVisibleCellsAnimated(true)
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifier, forIndexPath: indexPath) as! TableViewCell
        cell.numberLabel.text = String(indexPath.row)
        cell.nameLabel.text = names[indexPath.row % names.count]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        hideVisibleCellsAnimated(true)
    }
}