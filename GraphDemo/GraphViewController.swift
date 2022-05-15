//
//  GraphViewController.swift
//  GraphDemo
//
//  Created by Erwin Bejsta on 15/5/2022.
//

import Foundation

import AppKit

class graphViewController: NSViewController, NSWindowDelegate {
    
    
    override func viewDidLoad() {
        //print("\(className) \(#function) - \(self.view.frame)")
        //print("\(className) \(#function) - \(graphView.frame)")
        //print("\(className) \(#function) - \(view.window!.frame)")
        
        let line1 = dragLine(orientation: .horizontal, handlePos: .left, maxAbsoluteValue: 100, parentFrame: view.frame)
        let line2 = dragLine(orientation: .horizontal, handlePos: .left, maxAbsoluteValue: 100, parentFrame: view.frame)
        let line3 = dragLine(orientation: .vertical, handlePos: .bottom, maxAbsoluteValue: 20, parentFrame: view.frame)
        line1.intValue = 20
        line1.lineColor = NSColor.systemPink
        line2.intValue = 80
        line2.lineColor = NSColor.systemBlue
        line3.intValue = 10
        line3.lineColor = NSColor.systemGreen
        (view as! graphView).dragLineArray.append(line1)
        (view as! graphView).dragLineArray.append(line2)
        (view as! graphView).dragLineArray.append(line3)
    }
    
    override func viewWillAppear() {
        view.window?.delegate = self
    }
    
    override func viewWillLayout() {
    }
}
