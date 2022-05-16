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
        let timeScale = Int(20)
        
        let rightV = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: timeScale, parentFrame: view.frame)
        let leftV = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: timeScale, parentFrame: view.frame)
        leftV.intValue = 0
        rightV.intValue = timeScale
        leftV.isHidden = true
        rightV.isHidden = true
        let start1v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: timeScale, parentFrame: view.frame)
        let start2v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: timeScale, parentFrame: view.frame)
        let start3v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: timeScale, parentFrame: view.frame)
        let stop1v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: timeScale, parentFrame: view.frame)
        let stop2v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: timeScale, parentFrame: view.frame)
        let stop3v = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, maxAbsoluteValue: timeScale, parentFrame: view.frame)
        start1v.intValue = 2
        start2v.intValue = 4
        start3v.intValue = 6
        stop1v.intValue = timeScale - 6
        stop2v.intValue = timeScale - 4
        stop3v.intValue = timeScale - 2
        start1v.maxValueDragLine = start2v
        start2v.minValueDragLine = start1v
        start2v.maxValueDragLine = start3v
        start3v.minValueDragLine = start2v
        start1v.toolTip = "start1v"
        start2v.toolTip = "start2v"
        start3v.toolTip = "start3v"
        
        let horMax = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 1.0, maxAbsoluteValue: 100, parentFrame: view.frame)
        let horMin = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 1.0, maxAbsoluteValue: 100, parentFrame: view.frame)
        let start1 = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let start2 = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let start3 = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let stop1 = dragLine(orientation: .horizontal, origin: .right, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let stop2 = dragLine(orientation: .horizontal, origin: .right, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        let stop3 = dragLine(orientation: .horizontal, origin: .right, lengthFactor: 0.45, maxAbsoluteValue: 100, parentFrame: view.frame)
        
        horMin.intValue = 15
        horMax.intValue = 90
        start1.intValue = 30
        start2.intValue = 60
        start3.intValue = 80
        stop1.intValue = 80
        stop2.intValue = 60
        stop3.intValue = 30
        
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
        stop1.lineColor = NSColor.systemBlue
        stop2.lineColor = NSColor.systemBlue
        stop3.lineColor = NSColor.systemBlue
        horMin.toolTip = "Min Speed"
        horMax.toolTip = "Max Speed"
        v.dragLineArray.append(start1v)
        v.dragLineArray.append(start2v)
        v.dragLineArray.append(start3v)
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
        v.dragLineArray.append(leftV)
        v.dragLineArray.append(rightV)

        //print("\(className) \(#function): \((view as! graphView).dragLineArray.count)")
        let i1 = intersection(dragLine1: leftV, dragLine2: start1)
        let i2 = intersection(dragLine1: start1v, dragLine2: start2)
        let i3 = intersection(dragLine1: start2v, dragLine2: start3)
        let i4 = intersection(dragLine1: start3v, dragLine2: horMax)
        let i5 = intersection(dragLine1: stop1v, dragLine2: horMax)
        let i6 = intersection(dragLine1: stop2v, dragLine2: stop1)
        let i7 = intersection(dragLine1: stop3v, dragLine2: stop2)
        let i8 = intersection(dragLine1: rightV, dragLine2: stop3)
        v.intersectionArray.append(i1)
        v.intersectionArray.append(i2)
        v.intersectionArray.append(i3)
        v.intersectionArray.append(i4)
        v.intersectionArray.append(i5)
        v.intersectionArray.append(i6)
        v.intersectionArray.append(i7)
        v.intersectionArray.append(i8)
    }
    
    override func viewWillAppear() {
        view.window?.delegate = self
    }
    
    override func viewWillLayout() {
    }
}
