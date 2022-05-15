//
//  GraphView.swift
//  GraphDemo
//
//  Created by Erwin Bejsta on 15/5/2022.
//

import Foundation
import AppKit

enum draggedObjectEnum:Int {
    case none = 0
    case minPower
    case maxPower
}

enum dragLineOrientation:Int {
    case horizontal = 0
    case vertical
}

enum dragLineHandlePosition:Int {
    case left = 0
    case right
    case top
    case bottom
}

let dashedLinePattern: [CGFloat] = [5.0, 5.0]
let minClickPathWidth = Float(8)

/**
 * definition for a vertical or horizontal line which represents a value
 * the line can be dragged up/down or left/right to change the value
 */
class dragLine {
    // requried for init
    let orientation: dragLineOrientation
    let handlePosition: dragLineHandlePosition
    var maxValueAbsolute: Int     // max value possible in this graph
    
    // not required for init
    var minValueAbsolute = Int(0)   // min value possible in this graph
    var lineColor = NSColor.textColor
    var handleColor =  NSColor.textColor
    
    var valueName = String("")
    var viewPosition = CGFloat(0)   // the vertical/horizontal position in view coordinates
    var linePath = NSBezierPath()
    var handlePath = NSBezierPath()
    var clickPath = NSBezierPath()

    private var _parentFrame: NSRect
    var parentFrame: NSRect {
        get {
            return _parentFrame
        }
        set (newValue) {
            _parentFrame = newValue
            calculatePaths()
        }
    }
    
    private var _intValue = Int(0)
    var intValue: Int {
        get {
            return _intValue
        }
        set (newValue){
            if newValue <= maxValueAbsolute && newValue >= minValueAbsolute {
                _intValue = newValue
                calculatePaths()
            }
        }
    }
    
    var clickPathWidth: CGFloat {
        get {
            if pointsPerUnit < (minClickPathWidth/2) {
                return CGFloat( minClickPathWidth )
            } else {
                return CGFloat(pointsPerUnit * 2)
            }
        }
    }
    
    var pointsPerUnit: Float {
        get {
            var retVal = Float(0)
            if orientation == .horizontal {
                retVal = Float(parentFrame.height) / Float(maxValueAbsolute)
            } else {
                retVal = Float(parentFrame.width) / Float(maxValueAbsolute)
            }
            return retVal
        }
    }
    
    init(orientation:dragLineOrientation, handlePos:dragLineHandlePosition, maxAbsoluteValue:Int, parentFrame: NSRect) {
        self.orientation = orientation
        self.handlePosition = handlePos
        self.maxValueAbsolute = maxAbsoluteValue
        self._parentFrame = parentFrame
    }
    
    /**
     * calculate the int value for a given position in the parent frame
     * - parameter pos: position in parent frame
     * - returns: int value for pos
     */
    func intValueForPosition(_ pos:NSPoint) -> Int {
        var retVal = Float(0)
        if orientation == .horizontal {
            retVal = Float(pos.y) / pointsPerUnit
        } else {
            retVal = Float(pos.x) / pointsPerUnit
        }
        return Int(retVal)
    }
    
    private func calculatePaths() {
        viewPosition = CGFloat( Float(intValue) * pointsPerUnit )  // update the line positoion
        linePath.removeAllPoints()
        clickPath.removeAllPoints()
        linePath.setLineDash(dashedLinePattern, count: 2, phase: 0.0)
        if orientation == .horizontal {
            linePath.move(to: NSPoint(x: CGFloat(0), y: viewPosition))
            linePath.line(to: NSPoint(x: parentFrame.width, y: viewPosition))
            clickPath.appendRect(NSRect(x: CGFloat(0), y: viewPosition-(clickPathWidth/2), width: parentFrame.width, height: clickPathWidth))
        } else {
            linePath.move(to: NSPoint(x: viewPosition, y: CGFloat(0)))
            linePath.line(to: NSPoint(x: viewPosition, y: parentFrame.height))
            clickPath.appendRect(NSRect(x: viewPosition-(clickPathWidth/2), y:CGFloat(0) , width: clickPathWidth, height: parentFrame.height))
        }
    }
}

class graphView: NSView {
    
    var draggedObject = draggedObjectEnum.none
    var draggedLineIndex: Int?
    var dragLineArray: Array<dragLine> = []
    
    /*
    let maxYunits = CGFloat(100)
    var maxXunits = CGFloat(20)
    var verticalPointsPerUnit = CGFloat(0)
    var horizontalPointsPerUnit = CGFloat(0)
    
    private var _minPower: Int = 0
    var minPower: Int {
        get {
            return _minPower
        }
        set (newValue) {
            if newValue <= 100 && newValue >= 0 {
                _minPower = newValue
            }
        }
    }
    var thePath = NSBezierPath()
    var minPowerClickPath = NSBezierPath()
    */
    // MARK: - Mouse up/down functions
    
    override func mouseDown(with event: NSEvent) {
        //print("\(className) \(#function) \(event.locationInWindow)")
        // mouse location is relative to window, convert to this view
        draggedLineIndex =  nil
        let locationInView = superview!.convert(event.locationInWindow, to: self)
        // iterate trhough dragLines to find which one has been clicked
        for (index, dragLine) in dragLineArray.enumerated() {
            if dragLine.clickPath.contains(locationInView) {
                draggedLineIndex = index
                return
            }
        }
        
        //super.mouseDown(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        //print("\(className) \(#function) - ")
        draggedLineIndex =  nil
    }
    
    override func mouseDragged(with event: NSEvent) {
        //print("\(className) \(#function)")
        let locationInView = superview!.convert(event.locationInWindow, to: self)
        // do we have a valid drage line index?
        guard let draggedIndex = draggedLineIndex else { return }
        // calculate new value
        dragLineArray[draggedIndex].intValue = dragLineArray[draggedIndex].intValueForPosition(locationInView)
        needsDisplay = true
        self.window?.invalidateCursorRects(for: self)   // will invoke resterCursorRects
        //print("\(className) \(#function) - \(dragLineArray[draggedIndex].intValue)")
    }
    
    // MARK: - Mouse tracking
    
    /**
     * invoked by the system when cursor rects need updating
     */
    override func resetCursorRects() {
        //print("\(className) \(#function)")
        for dragLine in dragLineArray {
            if dragLine.orientation == .horizontal {
                self.addCursorRect(dragLine.clickPath.bounds, cursor: .resizeUpDown)
            } else {
                self.addCursorRect(dragLine.clickPath.bounds, cursor: .resizeLeftRight)
            }
        }
    }
    
    /**
     * tracking area generates mouseEntered and mouseExited events
     */
    /*
    override func updateTrackingAreas() {
        print("\(className) \(#function)")
        for area in self.trackingAreas {
            self.removeTrackingArea(area)
        }
        for dragLine in dragLineArray {
            self.addTrackingRect(dragLine.clickPath.bounds, owner: self, userData: nil, assumeInside: false)
        }
        //self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: false)
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("\(className) \(#function)")
        super.mouseExited(with: event)
        if let area = event.trackingArea {
            //Added a pointing hand here
            self.addCursorRect(area.rect, cursor: .pointingHand)
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        print("\(className) \(#function)")
        super.mouseEntered(with: event)
        //Back to the system cursor
        if let area = event.trackingArea  {
            self.removeCursorRect(area.rect, cursor: .pointingHand)
        }
    }
    */
    // MARK: - Drawing functions
    
    /**
     * Performs re-calculation of all values affected when the view size has changed
     */
    func viewSizeChange() {
        for dragLine in dragLineArray {
            dragLine.parentFrame = self.frame
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let borderPath = NSBezierPath() //
        
        // draw border
        borderPath.appendRect(dirtyRect)
        NSColor.textColor.setStroke()
        borderPath.stroke()
                
        // draw all lines and handles
        for dragLine in dragLineArray {
            dragLine.lineColor.setStroke()
            dragLine.linePath.stroke()
            dragLine.handleColor.setStroke()
            dragLine.handlePath.stroke()
        }
    }
    
}


