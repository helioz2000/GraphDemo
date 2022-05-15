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
        
        let vert1 = dragLine(orientation: .vertical, handlePos: .bottom, maxAbsoluteValue: 20, parentFrame: view.frame)
        let vert2 = dragLine(orientation: .vertical, handlePos: .bottom, maxAbsoluteValue: 20, parentFrame: view.frame)
        let vert3 = dragLine(orientation: .vertical, handlePos: .bottom, maxAbsoluteValue: 20, parentFrame: view.frame)
        vert1.intValue = 7
        vert2.intValue = 10
        vert3.intValue = 13
        vert1.maxValueDragLine = vert2
        vert2.minValueDragLine = vert1
        vert2.maxValueDragLine = vert3
        vert3.minValueDragLine = vert2
        vert1.toolTip = "vert1"
        vert2.toolTip = "vert2"
        vert3.toolTip = "vert3"
        
        let horMax = dragLine(orientation: .horizontal, handlePos: .left, maxAbsoluteValue: 100, parentFrame: view.frame)
        let horMin = dragLine(orientation: .horizontal, handlePos: .left, maxAbsoluteValue: 100, parentFrame: view.frame)
        let hor1 = dragLine(orientation: .horizontal, handlePos: .left, maxAbsoluteValue: 100, parentFrame: view.frame)
        let hor2 = dragLine(orientation: .horizontal, handlePos: .left, maxAbsoluteValue: 100, parentFrame: view.frame)
        let hor3 = dragLine(orientation: .horizontal, handlePos: .left, maxAbsoluteValue: 100, parentFrame: view.frame)
        horMin.intValue = 15
        hor1.intValue = 25
        hor2.intValue = 40
        hor3.intValue = 60
        horMax.intValue = 90
        horMin.maxValueDragLine = hor1
        hor1.minValueDragLine = horMin
        hor1.maxValueDragLine = hor2
        hor2.minValueDragLine = hor1
        hor2.maxValueDragLine = hor3
        hor3.minValueDragLine = hor2
        hor3.maxValueDragLine = horMax
        horMax.minValueDragLine = hor3
        horMin.lineColor = NSColor.systemRed
        horMax.lineColor = NSColor.systemRed
        hor1.lineColor = NSColor.systemBlue
        hor2.lineColor = NSColor.systemBlue
        hor3.lineColor = NSColor.systemBlue
        horMin.toolTip = "Min Speed"
        horMax.toolTip = "Max Speed"
        v.dragLineArray.append(vert1)
        v.dragLineArray.append(vert2)
        v.dragLineArray.append(vert3)
        v.dragLineArray.append(horMin)
        v.dragLineArray.append(hor1)
        v.dragLineArray.append(hor2)
        v.dragLineArray.append(hor3)
        v.dragLineArray.append(horMax)

        //print("\(className) \(#function): \((view as! graphView).dragLineArray.count)")
        
        let i1 = intersection(dragLine1: vert1, dragLine2: hor2)
        let i2 = intersection(dragLine1: vert2, dragLine2: hor3)
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
