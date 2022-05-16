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
        
        let v = view as! graphView
        
        let vert1 = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: 30, parentFrame: view.frame)
        let vert2 = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: 30, parentFrame: view.frame)
        let vert3 = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: 30, parentFrame: view.frame)
        let stop1v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: 30, parentFrame: view.frame)
        let stop2v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: 30, parentFrame: view.frame)
        let stop3v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: 30, parentFrame: view.frame)
        vert1.intValue = 3
        vert2.intValue = 8
        vert3.intValue = 12
        stop1v.intValue = 17
        stop2v.intValue = 22
        stop3v.intValue = 27
        vert1.maxValueDragLine = vert2
        vert2.minValueDragLine = vert1
        vert2.maxValueDragLine = vert3
        vert3.minValueDragLine = vert2
        vert1.toolTip = "vert1"
        vert2.toolTip = "vert2"
        vert3.toolTip = "vert3"
        
        let horMax = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 1.0, maxAbsoluteValue: 100, parentFrame: view.frame)
        let horMin = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 1.0, maxAbsoluteValue: 100, parentFrame: view.frame)
        let start1 = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let start2 = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let start3 = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        horMin.intValue = 15
        start1.intValue = 30
        start2.intValue = 60
        start3.intValue = 80
        horMax.intValue = 90
        horMin.maxValueDragLine = start1
        start1.minValueDragLine = horMin
        start1.maxValueDragLine = start2
        start2.minValueDragLine = start1
        start2.maxValueDragLine = start3
        start3.minValueDragLine = start2
        start3.maxValueDragLine = horMax
        horMax.minValueDragLine = start3
        horMin.lineColor = NSColor.systemRed
        horMax.lineColor = NSColor.systemRed
        start1.lineColor = NSColor.systemGreen
        start2.lineColor = NSColor.systemGreen
        start3.lineColor = NSColor.systemGreen
        let stop1 = dragLine(orientation: .horizontal, origin: .right, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let stop2 = dragLine(orientation: .horizontal, origin: .right, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let stop3 = dragLine(orientation: .horizontal, origin: .right, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        stop1.intValue = 60
        stop2.intValue = 70
        stop3.intValue = 80
        stop1.lineColor = NSColor.systemBlue
        stop2.lineColor = NSColor.systemBlue
        stop3.lineColor = NSColor.systemBlue
        
        
        horMin.toolTip = "Min Speed"
        horMax.toolTip = "Max Speed"
        v.dragLineArray.append(vert1)
        v.dragLineArray.append(vert2)
        v.dragLineArray.append(vert3)
        v.dragLineArray.append(stop1v)
        v.dragLineArray.append(stop2v)
        v.dragLineArray.append(stop3v)
        v.dragLineArray.append(horMin)
        v.dragLineArray.append(start1)
        v.dragLineArray.append(start2)
        v.dragLineArray.append(start3)
        v.dragLineArray.append(stop1)
        v.dragLineArray.append(stop2)
        v.dragLineArray.append(stop3)
        v.dragLineArray.append(horMax)

        //print("\(className) \(#function): \((view as! graphView).dragLineArray.count)")
        
        let i1 = intersection(dragLine1: vert1, dragLine2: start2)
        let i2 = intersection(dragLine1: vert2, dragLine2: start3)
        let i3 = intersection(dragLine1: vert3, dragLine2: horMax)
        v.intersectionArray.append(i1)
        v.intersectionArray.append(i2)
        v.intersectionArray.append(i3)
    }
    
    override func viewWillAppear() {
        view.window?.delegate = self
    }
    
    override func viewWillLayout() {
    }
}
