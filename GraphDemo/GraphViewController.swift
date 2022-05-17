//
//  GraphViewController.swift
//  GraphDemo
//
//  Created by Erwin Bejsta on 15/5/2022.
//

import Foundation

import AppKit

class graphViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet var startStepsPoputton: NSPopUpButton!
    @IBOutlet var stopStepsPoputton: NSPopUpButton!
    @objc dynamic var startSteps = Int(3)
    @objc dynamic var stopSteps = Int(3)
    @IBOutlet var infoTextField:NSTextField!
    
    var kvoDragLineToken: NSKeyValueObservation?
    var kvoDraggedValueToken:  NSKeyValueObservation?
    
    override func viewDidLoad() {
        //print("\(className) \(#function) - \(self.view.frame)")
        //print("\(className) \(#function) - \(graphView.frame)")
        //print("\(className) \(#function) - \(view.window!.frame)")
        
        startStepsPoputton.selectItem(withTag: startSteps)
        stopStepsPoputton.selectItem(withTag: stopSteps)
        
        // observe line dragging
        if let v = view as? graphView {
            kvoDragLineToken = v.observe(\.observableDragLineIndex, options: .new) { (gView, change) in
                if let index = change.newValue {
                    if index == nil {
                        self.infoTextField.isHidden = true
                    } else {
                        self.infoTextField.isHidden = false
                        self.infoTextField.stringValue = String("\(gView.dragLineArray[Int(truncating: index!)].toolTip): \(gView.dragLineArray[Int(truncating: index!)].intValue)")
                    }
                }
            }
            
            kvoDraggedValueToken = v.observe(\.observableDraggedValue, options: .new) { (gView, change) in
                if let dlIndex = gView.draggedLineIndex {
                    self.infoTextField.stringValue = String("\(gView.dragLineArray[dlIndex].toolTip): \(gView.dragLineArray[dlIndex].intValue)")
                }
            }
        }
        setup()
    }
    
    deinit {
        kvoDragLineToken?.invalidate()
    }
    
    override func viewWillAppear() {
        view.window?.delegate = self
    }
    
    override func viewWillLayout() {
    }
    
    @IBAction func startStepsChanged(_ sender: NSPopUpButton) {
        startSteps = sender.selectedTag()
        setup()
    }
    
    @IBAction func stopStepsChanged(_ sender: NSPopUpButton) {
        stopSteps = sender.selectedTag()
        setup()
    }
    
    // MARK: - Functional Implementation
    
    func setup () {
        let v = view as! graphView
        let timeScale = Int(20)
        let horLengthFactor = 0.45
        
        var startLinesV: Array<dragLine> = []
        var stopLinesV: Array<dragLine> = []
        var startLinesH: Array<dragLine> = []
        var stopLinesH: Array<dragLine> = []
        var intersections: Array<intersection> = []
        
        v.dragLineArray.removeAll()
        
        let rightV = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame)
        let leftV = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame)
        leftV.intValue = 0
        rightV.intValue = timeScale
        leftV.isHidden = true
        rightV.isHidden = true
        
        let horMax = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 1.0, axisMax: 100, parentFrame: view.frame)
        let horMin = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 1.0, axisMax: 100, parentFrame: view.frame)
        horMin.intValue = 15
        horMax.intValue = 90
        horMin.lineColor = NSColor.systemRed
        horMax.lineColor = NSColor.systemRed
        horMin.toolTip = "Min Power"
        horMax.toolTip = "Max Power"
        
        /*
        horMin.maxValueDragLine = startLinesH[0]
        horMax.minValueDragLine = startLinesH[2]
        */
        
        startLinesV.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
        startLinesV[0].intValue = 2
        startLinesV[0].maxValue = Int(Double(timeScale) * horLengthFactor)
        startLinesV[0].toolTip = "Start Time 1"
        
        startLinesH.append( dragLine(orientation: .horizontal, origin: .left, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
        startLinesH[0].intValue = 30
        startLinesH[0].toolTip = "Start Power 1"
        startLinesH[0].lineColor = NSColor.systemGreen
        startLinesH[0].minValueDragLine = horMin
        intersections.append( intersection(dragLine1: leftV, dragLine2: startLinesH[0]) )
        intersections.append( intersection(dragLine1: startLinesV[0], dragLine2: horMax) )
        
        if startSteps > 1 {
            startLinesV.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
            startLinesV[1].intValue = 4
            startLinesV[1].maxValue = startLinesV[0].maxValue
            startLinesV[1].toolTip = "Start Time 2"
            startLinesV[0].maxValueDragLine = startLinesV[1]
            startLinesV[1].minValueDragLine = startLinesV[0]
            startLinesH.append( dragLine(orientation: .horizontal, origin: .left, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
            startLinesH[1].intValue = 60
            startLinesH[1].toolTip = "Start Power 2"
            startLinesH[1].lineColor = NSColor.systemGreen
            startLinesH[0].maxValueDragLine = startLinesH[1]
            startLinesH[1].minValueDragLine = startLinesH[0]
            intersections.remove(at: intersections.count-1)
            intersections.append( intersection(dragLine1: startLinesV[0], dragLine2: startLinesH[1]) )
            intersections.append( intersection(dragLine1: startLinesV[1], dragLine2: horMax))
        }
        
        if startSteps > 2 {
            startLinesV.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
            startLinesV[2].intValue = 6
            startLinesV[2].maxValue = startLinesV[1].maxValue
            startLinesV[2].toolTip = "start time 3"
            startLinesV[1].maxValueDragLine = startLinesV[2]
            startLinesV[2].minValueDragLine = startLinesV[1]
            startLinesH.append( dragLine(orientation: .horizontal, origin: .left, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
            startLinesH[2].intValue = 80
            startLinesH[2].toolTip = "Start Power 3"
            startLinesH[2].lineColor = NSColor.systemGreen
            startLinesH[1].maxValueDragLine = startLinesH[2]
            startLinesH[2].minValueDragLine = startLinesH[1]
            startLinesH[2].maxValueDragLine = horMax
            intersections.remove(at: intersections.count-1)
            intersections.append( intersection(dragLine1: startLinesV[1], dragLine2: startLinesH[2]) )
            intersections.append( intersection(dragLine1: startLinesV[2], dragLine2: horMax) )
        }
        
        stopLinesV.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
        stopLinesV[0].intValue = timeScale - 6
        stopLinesV[0].minValue = timeScale - Int(Double(timeScale) * horLengthFactor)
        stopLinesV[0].toolTip = "Stop Time 1"
        stopLinesH.append( dragLine(orientation: .horizontal, origin: .right, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
        stopLinesH[0].intValue = 80
        stopLinesH[0].toolTip = "Stop Power 1"
        stopLinesH[0].lineColor = NSColor.systemBlue
        stopLinesH[0].maxValueDragLine = horMax
        intersections.append( intersection(dragLine1: stopLinesV[0], dragLine2: horMax) )
        intersections.append( intersection(dragLine1: rightV, dragLine2: stopLinesH[0]) )
        
        if stopSteps > 1 {
            stopLinesV.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
            stopLinesV[1].intValue = timeScale - 4
            stopLinesV[1].minValue = stopLinesV[0].minValue
            stopLinesV[1].toolTip = "Stop Time 2"
            stopLinesV[0].maxValueDragLine = stopLinesV[1]
            stopLinesV[1].minValueDragLine = stopLinesV[0]
            stopLinesH.append( dragLine(orientation: .horizontal, origin: .right, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
            stopLinesH[1].intValue = 60
            stopLinesH[1].toolTip = "Stop Power 2"
            stopLinesH[1].lineColor = NSColor.systemBlue
            stopLinesH[0].minValueDragLine = stopLinesH[1]
            stopLinesH[1].maxValueDragLine = stopLinesH[0]
            intersections.remove(at: intersections.count-1)
            intersections.append( intersection(dragLine1: stopLinesV[1], dragLine2: stopLinesH[0]) )
            intersections.append( intersection(dragLine1: rightV, dragLine2: stopLinesH[1]) )
        }
        
        if stopSteps > 2 {
            stopLinesV.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
            stopLinesV[2].intValue = timeScale - 2
            stopLinesV[2].minValue = stopLinesV[1].minValue
            stopLinesV[2].toolTip = "Stop Time 3"
            stopLinesV[1].maxValueDragLine = stopLinesV[2]
            stopLinesV[2].minValueDragLine = stopLinesV[1]
            stopLinesH.append( dragLine(orientation: .horizontal, origin: .right, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
            stopLinesH[2].intValue = 30
            stopLinesH[2].toolTip = "Stop Power 3"
            stopLinesH[2].lineColor = NSColor.systemBlue
            stopLinesH[1].minValueDragLine = stopLinesH[2]
            stopLinesH[2].maxValueDragLine = stopLinesH[1]
            stopLinesH[2].minValueDragLine = horMin
            intersections.remove(at: intersections.count-1)
            intersections.append( intersection(dragLine1: stopLinesV[2], dragLine2: stopLinesH[1]) )
            intersections.append( intersection(dragLine1: rightV, dragLine2: stopLinesH[2]) )
        }

        v.dragLineArray += startLinesV
        v.dragLineArray += stopLinesV
        v.dragLineArray += startLinesH
        v.dragLineArray += stopLinesH
        v.dragLineArray.append(horMin)
        v.dragLineArray.append(horMax)
        v.dragLineArray.append(leftV)
        v.dragLineArray.append(rightV)

        v.intersectionArray.removeAll()
        v.intersectionArray += intersections

        v.needsDisplay = true
        v.invalidateCursor()
    }
}
