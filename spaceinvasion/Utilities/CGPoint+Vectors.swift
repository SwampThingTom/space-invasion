//
//  CGPoint+Vectors.swift
//  spaceinvasion
//
//  Adapted from raywenderlich.com.
//
//  Copyright (c) 2015 Razeware LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func + (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x + right.width, y: left.y + right.height)
}

func + (left: CGSize, right: CGPoint) -> CGPoint {
    return CGPoint(x: right.x + left.width, y: right.y + left.height)
}

func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

func += (inout left: CGPoint, right: CGSize) {
    left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func - (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x - right.width, y: left.y - right.height)
}

func - (left: CGSize, right: CGPoint) -> CGPoint {
    return CGPoint(x: right.x - left.width, y: right.y - left.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func -= (inout left: CGPoint, right: CGPoint) {
    left = left - right
}

func -= (inout left: CGPoint, right: CGSize) {
    left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func * (left: CGPoint, right: CGSize) -> CGPoint {
    return CGPoint(x: left.x * right.width, y: left.y * right.height)
}

func * (left: CGSize, right: CGPoint) -> CGPoint {
    return CGPoint(x: right.x * left.width, y: right.y * left.height)
}

func * (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}

func *= (inout left: CGPoint, right: CGPoint) {
    left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (inout point: CGPoint, scalar: CGFloat) {
    point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (inout left: CGPoint, right: CGPoint) {
    left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (inout point: CGPoint, scalar: CGFloat) {
    point = point / scalar
}

extension CGPoint {
    
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
}

let π = CGFloat(M_PI)

func shortestAngleBetween(angle1: CGFloat,
    angle2: CGFloat) -> CGFloat {
        let twoπ = π * 2.0
        var angle = (angle2 - angle1) % twoπ
        if (angle >= π) {
            angle = angle - twoπ
        }
        if (angle <= -π) {
            angle = angle + twoπ
        }
        return angle
}
