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
    @IBOutlet var infoTextField:NSTextField!
    
    @objc dynamic var startSteps = Int(3)
    @objc dynamic var stopSteps = Int(3)
    
    var kvoDragLineToken: NSKeyValueObservation?
    var kvoDraggedValueToken: NSKeyValueObservation?
    //var kvoValueChangeToken: NSKeyValueObservation?
    
    var startTimeLines: Array<dragLine> = []
    var stopTimeLines: Array<dragLine> = []
    var startPowerLines: Array<dragLine> = []
    var stopPowerLines: Array<dragLine> = []
    var intersections: Array<intersection> = []
    var horMin: dragLine?
    var horMax: dragLine?
    
    var startTime: Array<Int> = [1, 1, 2]
    var stopTime: Array<Int> = [2, 1, 1]
    var startPower: Array<Int> = [30, 50, 80]
    var stopPower: Array<Int> = [80, 60, 20]
    var minPower = Int(15)
    var maxPower = Int(95)
    
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
                        self.ruleCheck()
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
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.onGraphValueHasChanged(notification:)), name: .graphHasChangedValue, object: nil)
        
        }
        setup()
    }
    
    deinit {
        kvoDragLineToken?.invalidate()
        kvoDraggedValueToken?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear() {
        //view.window?.delegate = self
        (view as! graphView).userInteraction = true
    }
    
    override func viewWillLayout() {
        //print("\(className) \(#function)")
        setup()
    }
    
    // MARK: - IBActions
    
    @IBAction func saveButtonAction(_ sender:NSButton){
        //
    }
    
    @IBAction func abortButtonAction(_ sender:NSButton) {
        close()
    }
    
    @IBAction func startStepsChanged(_ sender: NSPopUpButton) {
        startSteps = sender.selectedTag()
        switch startSteps {
        case 1:
            startTime[2] = 0
            startTime[1] = 0
            break
        case 2:
            startTime[2] = 0
            if startTime[1] == 0 { startTime[1] = 1 }
            break
        case 3:
            if startTime[1] == 0 { startTime[1] = 1 }
            if startTime[2] == 0 { startTime[2] = 1}
            break
        default:
            break
        }
        setup()
    }
    
    @IBAction func stopStepsChanged(_ sender: NSPopUpButton) {
        stopSteps = sender.selectedTag()
        switch stopSteps {
        case 1:
            stopTime[2] = 0
            stopTime[1] = 0
            break
        case 2:
            stopTime[2] = 0
            if stopTime[1] == 0 { stopTime[1] = 1}
            break
        case 3:
            if stopTime[1] == 0 { stopTime[1] = 1}
            if stopTime[2] == 0 { stopTime[2] = 1}
            break
        default:
            break
        }
        setup()
    }
    
    // MARK: - Functional Implementation
    
    /**
     * Received of View notification for graph value changes
     */
    @objc func onGraphValueHasChanged(notification: Notification) {
        //print("\(className) \(#function)")
        if let value = notification.userInfo?["index"] {
            let index = value as! NSNumber
            applyNewValue(index.intValue)
        }
    }
    
    private func applyNewValue(_ dragLineIndex: Int) {
        let line = (view as! graphView).dragLineArray[dragLineIndex]
        //print("\(className) \(#function) - \(line.toolTip) = \(line.intValue)")
        let startTimeRange = NSMakeRange(0, 3)
        let stopTimeRange = NSMakeRange(3, 3)
        let startPowerRange = NSMakeRange(6, 3)
        let stopPowerRange = NSMakeRange(9, 3)
        
        if startTimeRange.contains(dragLineIndex) {
            startTime[dragLineIndex] = line.intValue
        }
        if stopTimeRange.contains(dragLineIndex) {
            stopTime[dragLineIndex - stopTimeRange.location] = line.intValue
            
        }
        if startPowerRange.contains(dragLineIndex) {
            startPower[dragLineIndex - startPowerRange.location] = line.intValue
        }
        if stopPowerRange.contains(dragLineIndex) {
            stopPower[dragLineIndex - stopPowerRange.location] = line.intValue
        }
    }
    
    /**
     * applies extra rules which are not contained within drag lines
     */
    func ruleCheck() {
        //print("\(className) \(#function)")
        //print("\(className) \(#function) - \(stopPowerLines[0].intValue) \(horMax?.intValue)")
        if let maxValue = horMax?.intValue {
            if stopPowerLines[0].intValue > maxValue {
                horMax?.intValue = stopPowerLines[0].intValue + 1
                view.needsDisplay = true
                //print("\(className) \(#function) - changed to \(horMax?.intValue)")
            }
        }
        
        /*
        if let minValue = horMin?.intValue {
            if stopPowerLines[3].intValue < minValue {
                horMin?.intValue = stopPowerLines[3].intValue - 1
            }
        }
         */
    }
    
    /**
     * Dynamic calculation of time scale as a factor of times already in use to give enough space to expand these times
     */
    func calculateTimescale() -> Int {
        var totalTime = Int(0)
        for t in startTime {
            totalTime += t
        }
        for t in stopTime {
            totalTime += t
        }
        var total = Float(totalTime)
        total = (total * 2.5)
        return Int(total)
    }
    
    func setup() {
        let v = view as! graphView
        let timeScale = calculateTimescale()
        let horLengthFactor = 0.45
        
        startTimeLines.removeAll()
        stopTimeLines.removeAll()
        startPowerLines.removeAll()
        stopPowerLines.removeAll()
        intersections.removeAll()
        
        v.dragLineArray.removeAll()
        v.intersectionArray.removeAll()
        
        let rightV = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame)
        let leftV = dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame)
        leftV.intValue = 0
        rightV.intValue = timeScale
        leftV.isHidden = true
        rightV.isHidden = true
        
        horMax = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 1.0, axisMax: 100, parentFrame: view.frame)
        horMin = dragLine(orientation: .horizontal, origin: .left, lengthFactor: 1.0, axisMax: 100, parentFrame: view.frame)
        horMin!.intValue = minPower
        horMax!.intValue = maxPower
        horMin!.lineColor = NSColor.systemRed
        horMax!.lineColor = NSColor.systemRed
        horMin!.toolTip = "Min Power"
        horMax!.toolTip = "Max Power"
        
        /*
        horMin.maxValueDragLine = startPowerLines[0]
        horMax.minValueDragLine = startPowerLines[2]
        */
        
        startTimeLines.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
        startTimeLines[0].intValue = startTime[0]
        startTimeLines[0].maxValue = Int(Double(timeScale) * horLengthFactor)
        startTimeLines[0].toolTip = "Start Time 1"
        
        startPowerLines.append( dragLine(orientation: .horizontal, origin: .left, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
        startPowerLines[0].intValue = startPower[0]
        startPowerLines[0].toolTip = "Start Power 1"
        startPowerLines[0].lineColor = NSColor.systemGreen
        startPowerLines[0].minValueDragLine = horMin
        intersections.append( intersection(dragLine1: leftV, dragLine2: startPowerLines[0]) )
        intersections.append( intersection(dragLine1: startTimeLines[0], dragLine2: horMax!) )
        
        if startSteps > 1 {
            startTimeLines.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
            startTimeLines[1].intValue = startTime[1] + startTime[0]
            startTimeLines[1].maxValue = startTimeLines[0].maxValue
            startTimeLines[1].toolTip = "Start Time 2"
            startTimeLines[0].maxValueDragLine = startTimeLines[1]
            startTimeLines[1].minValueDragLine = startTimeLines[0]
            startPowerLines.append( dragLine(orientation: .horizontal, origin: .left, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
            startPowerLines[1].intValue = startPower[1]
            startPowerLines[1].toolTip = "Start Power 2"
            startPowerLines[1].lineColor = NSColor.systemGreen
            startPowerLines[0].maxValueDragLine = startPowerLines[1]
            startPowerLines[1].minValueDragLine = startPowerLines[0]
            intersections.remove(at: intersections.count-1)
            intersections.append( intersection(dragLine1: startTimeLines[0], dragLine2: startPowerLines[1]) )
            intersections.append( intersection(dragLine1: startTimeLines[1], dragLine2: horMax!))
        }
        
        if startSteps > 2 {
            startTimeLines.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
            startTimeLines[2].intValue = startTime[2] + startTime[1] + startTime[0]
            startTimeLines[2].maxValue = startTimeLines[1].maxValue
            startTimeLines[2].toolTip = "Start time 3"
            startTimeLines[1].maxValueDragLine = startTimeLines[2]
            startTimeLines[2].minValueDragLine = startTimeLines[1]
            startPowerLines.append( dragLine(orientation: .horizontal, origin: .left, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
            startPowerLines[2].intValue = startPower[2]
            startPowerLines[2].toolTip = "Start Power 3"
            startPowerLines[2].lineColor = NSColor.systemGreen
            startPowerLines[1].maxValueDragLine = startPowerLines[2]
            startPowerLines[2].minValueDragLine = startPowerLines[1]
            startPowerLines[2].maxValueDragLine = horMax
            intersections.remove(at: intersections.count-1)
            intersections.append( intersection(dragLine1: startTimeLines[1], dragLine2: startPowerLines[2]) )
            intersections.append( intersection(dragLine1: startTimeLines[2], dragLine2: horMax!) )
        }
        
        stopTimeLines.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
        stopTimeLines[0].intValue = timeScale - (stopTime[0] + stopTime[1] + stopTime[2])
        stopTimeLines[0].minValue = timeScale - Int(Double(timeScale) * horLengthFactor)
        stopTimeLines[0].toolTip = "Stop Time 1"
        stopPowerLines.append( dragLine(orientation: .horizontal, origin: .right, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
        stopPowerLines[0].intValue = stopPower[0]
        stopPowerLines[0].toolTip = "Stop Power 1"
        stopPowerLines[0].lineColor = NSColor.systemBlue
        stopPowerLines[0].maxValueDragLine = horMax
        intersections.append( intersection(dragLine1: stopTimeLines[0], dragLine2: horMax!) )
        intersections.append( intersection(dragLine1: rightV, dragLine2: stopPowerLines[0]) )
        
        if stopSteps > 1 {
            stopTimeLines.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
            stopTimeLines[1].intValue = timeScale - (stopTime[1] + stopTime[2])
            stopTimeLines[1].minValue = stopTimeLines[0].minValue
            stopTimeLines[1].toolTip = "Stop Time 2"
            stopTimeLines[0].maxValueDragLine = stopTimeLines[1]
            stopTimeLines[1].minValueDragLine = stopTimeLines[0]
            stopPowerLines.append( dragLine(orientation: .horizontal, origin: .right, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
            stopPowerLines[1].intValue = stopPower[1]
            stopPowerLines[1].toolTip = "Stop Power 2"
            stopPowerLines[1].lineColor = NSColor.systemBlue
            stopPowerLines[0].minValueDragLine = stopPowerLines[1]
            stopPowerLines[1].maxValueDragLine = stopPowerLines[0]
            intersections.remove(at: intersections.count-1)
            intersections.append( intersection(dragLine1: stopTimeLines[1], dragLine2: stopPowerLines[0]) )
            intersections.append( intersection(dragLine1: rightV, dragLine2: stopPowerLines[1]) )
        }
        
        if stopSteps > 2 {
            stopTimeLines.append( dragLine(orientation: .vertical, origin: .bottom, lengthFactor: 1.0, axisMax: timeScale, parentFrame: view.frame) )
            stopTimeLines[2].intValue = timeScale - (stopTime[2])
            stopTimeLines[2].minValue = stopTimeLines[1].minValue
            stopTimeLines[2].toolTip = "Stop Time 3"
            stopTimeLines[1].maxValueDragLine = stopTimeLines[2]
            stopTimeLines[2].minValueDragLine = stopTimeLines[1]
            stopPowerLines.append( dragLine(orientation: .horizontal, origin: .right, lengthFactor: horLengthFactor, axisMax: 100, parentFrame: view.frame) )
            stopPowerLines[2].intValue = stopPower[2]
            stopPowerLines[2].toolTip = "Stop Power 3"
            stopPowerLines[2].lineColor = NSColor.systemBlue
            stopPowerLines[1].minValueDragLine = stopPowerLines[2]
            stopPowerLines[2].maxValueDragLine = stopPowerLines[1]
            stopPowerLines[2].minValueDragLine = horMin
            intersections.remove(at: intersections.count-1)
            intersections.append( intersection(dragLine1: stopTimeLines[2], dragLine2: stopPowerLines[1]) )
            intersections.append( intersection(dragLine1: rightV, dragLine2: stopPowerLines[2]) )
        }

        v.dragLineArray += startTimeLines
        v.dragLineArray += stopTimeLines
        v.dragLineArray += startPowerLines
        v.dragLineArray += stopPowerLines
        v.dragLineArray.append(horMin!)
        v.dragLineArray.append(horMax!)
        v.dragLineArray.append(leftV)
        v.dragLineArray.append(rightV)

        v.intersectionArray += intersections

        v.needsDisplay = true
        v.invalidateCursor()
    }
}
