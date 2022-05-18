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

enum dragLineOrigin:Int {
    case left = 0
    case right
    case top
    case bottom
}

let dashedLinePattern: [CGFloat] = [5.0, 5.0]
let minClickPathWidth = Float(8)
let defaultMarkerSize = CGFloat(8)

public func clamp<T>(_ value: T, minValue: T, maxValue: T) -> T where T : Comparable {
    return min(max(value, minValue), maxValue)
}

/**
 * defines the intersection between two dragLines
 */
struct intersection {
    var dragLine1: dragLine
    var dragLine2: dragLine
    var markerSize = CGSize(width: defaultMarkerSize, height: defaultMarkerSize)
    var fillColor = NSColor.textColor
    
    // intersection is hidden if one of the dragLines is hidden
    var isHidden: Bool {
        if dragLine1.isHidden || dragLine2.isHidden {return true}
        return false
    }
    
    // the intersection point
    var point: CGPoint? {
        if dragLine1.orientation == dragLine2.orientation { return nil }
        if dragLine1.orientation == .horizontal {
            return CGPoint(x: dragLine2.viewPosition, y: dragLine1.viewPosition)
        } else {
            return CGPoint(x: dragLine1.viewPosition, y: dragLine2.viewPosition)
        }
    }
    
    var nodePath: NSBezierPath? {
        get {
            let path = NSBezierPath()
            if var pt = self.point {
                pt.x = pt.x - markerSize.width/2
                pt.y = pt.y - markerSize.height/2
                path.appendOval(in: NSRect(origin: pt, size: markerSize) )
                return path
            }
            return nil
        }
    }
}
// MARK: -
/**
 * definition for a vertical or horizontal line which represents a value
 * the line can be dragged up/down or left/right to change the value
 */
class dragLine: NSObject {
    // requried for init
    let orientation: dragLineOrientation
    let origin: dragLineOrigin
    var axisMax: Int                // axis max value
    var lengthFactor: Double       // 1.0 = 100%
    
    // not required for init
    var axisMin = Int(0)        // axis min value
    var minValue = Int(0)
    var maxValue = Int(0)
    var minValueDragLine: dragLine?
    var maxValueDragLine: dragLine?
    var lineColor = NSColor.systemGray
    var handleColor =  NSColor.textColor
    
    var valueName = String("")
    var toolTip = String("")
    var viewPosition = CGFloat(0)   // the vertical/horizontal position in view coordinates
    var linePath = NSBezierPath()
    var handlePath = NSBezierPath()
    var clickPath = NSBezierPath()
    var isHidden: Bool = false
    
    var cursor: NSCursor {
        get {
            if orientation == .horizontal {
                return NSCursor.resizeUpDown
            } else {
                return NSCursor.resizeLeftRight
            }
        }
    }
    
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
            let oldValue = _intValue
            // range clamping
            let tmpValue = clamp(newValue, minValue: minValue, maxValue: maxValue)
            _intValue = clamp(tmpValue, minValue: axisMin, maxValue: axisMax)
            // dynamc limit for min value if required
            if let minDL = minValueDragLine {
                if newValue <= minDL.intValue {
                    _intValue = oldValue
                }
            }
            // dynamic limit max value if requried
            if let maxDL = maxValueDragLine {
                if newValue >= maxDL.intValue {
                    _intValue = oldValue
                }
            }
            calculatePaths()
        }
    }
    
    var clickPathWidth: CGFloat {
        get {
            //if pointsPerUnit < (minClickPathWidth/2) {
                return CGFloat( minClickPathWidth )
            //} else {
            //    return CGFloat(pointsPerUnit * 2)
            //}
        }
    }
    
    var pointsPerUnit: Float {
        get {
            var retVal = Float(0)
            if orientation == .horizontal {
                retVal = Float(parentFrame.height) / Float(axisMax)
            } else {
                retVal = Float(parentFrame.width) / Float(axisMax)
            }
            return retVal
        }
    }
    
    init(orientation:dragLineOrientation, origin:dragLineOrigin, lengthFactor:Double, axisMax:Int, parentFrame: NSRect) {
        self.orientation = orientation
        self.origin = origin
        self.lengthFactor = lengthFactor
        self.axisMax = axisMax
        self.maxValue = axisMax
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
        var lineStart = NSPoint()
        var lineFinish = NSPoint()
        viewPosition = CGFloat( Float(intValue) * pointsPerUnit )  // update the line positoion
        linePath.removeAllPoints()
        clickPath.removeAllPoints()
        linePath.setLineDash(dashedLinePattern, count: 2, phase: 0.0)
        if orientation == .horizontal {
            if origin == .left { // horizontal left
                lineStart = NSPoint(x: CGFloat(0), y: viewPosition)
                lineFinish = NSPoint(x: parentFrame.width * lengthFactor, y: viewPosition)
            } else {    // horizontal right
                lineStart = NSPoint(x: parentFrame.width - (parentFrame.width * lengthFactor), y: viewPosition)
                lineFinish = NSPoint(x: parentFrame.width, y: viewPosition)
            }
            linePath.move(to: lineStart)
            linePath.line(to: lineFinish)
            clickPath.appendRect(NSRect(x: lineStart.x, y: viewPosition-(clickPathWidth/2), width: parentFrame.width * lengthFactor, height: clickPathWidth) )
            //clickPath.appendRect(NSRect(x: CGFloat(0), y: viewPosition-(clickPathWidth/2), width: parentFrame.width, height: clickPathWidth))
            //print("\(className) \(#function) - \(toolTip) \(linePath)")
        } else {
            if origin == .bottom { // vertical bottom
                lineStart = NSPoint(x: viewPosition, y: CGFloat(0))
                lineFinish = NSPoint(x: viewPosition, y: parentFrame.height * lengthFactor)
            } else {    // vertical top
                lineStart = NSPoint(x: viewPosition, y: parentFrame.height-(parentFrame.height * lengthFactor))
                lineFinish = NSPoint(x: viewPosition, y: parentFrame.height)
            }
            linePath.move(to: lineStart)
            linePath.line(to: lineFinish)
            clickPath.appendRect(NSRect(x: viewPosition-(clickPathWidth/2), y:lineStart.y , width: clickPathWidth, height: parentFrame.height * lengthFactor))
            //print("\(className) \(#function) - \(toolTip) \(linePath)")
        }
    }
    
    // this function delivers the tooltip to NSView
    override var description: String {
        get {
            return toolTip
        }
    }
}


// MARK: -
class graphView: NSView {
    
    var userInteraction = true
    var draggedObject = draggedObjectEnum.none
    var dragLineArray: Array<dragLine> = []
    var intersectionArray: Array<intersection> = []
    @objc dynamic var observableDragLineIndex: NSNumber?
    @objc dynamic var observableDraggedValue = NSNumber(value: 0)
    
    var _draggedLineIndex: Int?
    var draggedLineIndex: Int? {
        get {
            return _draggedLineIndex
        }
        set (newValue) {
            _draggedLineIndex = newValue
            if let i = _draggedLineIndex {
                observableDragLineIndex = NSNumber(value: i)
            } else {
                observableDragLineIndex = nil
            }
        }
    }
    
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
        if !userInteraction {
            super.mouseDown(with: event)
            return
        }
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
    }
    
    override func mouseUp(with event: NSEvent) {
        //print("\(className) \(#function) - ")
        if !userInteraction {
            super.mouseDown(with: event)
            return
        }
        draggedLineIndex =  nil
        self.window?.invalidateCursorRects(for: self)   // will invoke resterCursorRects
    }
    
    override func mouseDragged(with event: NSEvent) {
        //print("\(className) \(#function)")
        if !userInteraction {
            super.mouseDown(with: event)
            return
        }
        let locationInView = superview!.convert(event.locationInWindow, to: self)
        // do we have a valid drage line index?
        guard let draggedIndex = draggedLineIndex else { return }
        // calculate new value
        dragLineArray[draggedIndex].intValue = dragLineArray[draggedIndex].intValueForPosition(locationInView)
        observableDraggedValue = NSNumber(value: dragLineArray[draggedIndex].intValue)
        needsDisplay = true
        invalidateCursor()
        //print("\(className) \(#function) - \(dragLineArray[draggedIndex].intValue)")
    }
    
    // MARK: - Mouse tracking
    
    func invalidateCursor() {
        self.window?.invalidateCursorRects(for: self)   // will invoke resetCursorRects
    }
    
    /**
     * invoked by the system when cursor rects need updating
     * While not dragging the cursor changes when in the click rectangle around line
     * During drag operation the rectangle is expanded to the whole parent frame to prevent
     * the cursor from reverting back to an arrow even when outside the click rectangle
     * which occurs when the gap between int values on the axis scale exceeeds the click rectangle
     */
    override func resetCursorRects() {
        //print("\(className) \(#function)")
        if !userInteraction {
            super.resetCursorRects()
            return
        }
        var draggedLine: dragLine?      // not nil during drag operation
        var cursorRect = NSRect()
        
        //
        if let dlIdx = draggedLineIndex {
            draggedLine = dragLineArray[dlIdx]
        }
        
        for dragLine in dragLineArray {
            if !dragLine.clickPath.isEmpty && !dragLine.isHidden {
                cursorRect = dragLine.clickPath.bounds
                if let dl = draggedLine {
                    if dragLine == dl {
                        // prevent cursor change while dragging is active
                        cursorRect = dragLine.parentFrame
                    }
                }
                self.addCursorRect(cursorRect, cursor: dragLine.cursor)
                self.addToolTip(dragLine.clickPath.bounds, owner: dragLine, userData: nil)
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
        print("\(className) \(#function)")
        for dragLine in dragLineArray {
            dragLine.parentFrame = self.frame
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let borderPath = NSBezierPath() //
        let linePath = NSBezierPath()
        
        // draw border
        borderPath.appendRect(dirtyRect)
        NSColor.textColor.setStroke()
        borderPath.stroke()
                
        // draw all lines and handles
        for dragLine in dragLineArray {
            if !dragLine.isHidden {
                dragLine.lineColor.setStroke()
                dragLine.linePath.stroke()
                dragLine.handleColor.setStroke()
                dragLine.handlePath.stroke()
            }
        }
        
        // draw all intersections
        for intersection in intersectionArray {
            if let nodePath = intersection.nodePath {
                if !intersection.isHidden {
                    intersection.fillColor.setFill()
                    nodePath.fill()
                }
            }
        }
        
        // draw line between intersections
        linePath.removeAllPoints()
        
        for intersection in intersectionArray {
            if let pt = intersection.point {
                if linePath.isEmpty {
                    linePath.move(to: pt)
                } else {
                    linePath.line(to: pt)
                }
            }
            NSColor.textColor.setStroke()
            linePath.stroke()
            
        }
    }
    
}


