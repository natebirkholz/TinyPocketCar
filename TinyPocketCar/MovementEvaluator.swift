//
//  MovementEvaluator.swift
//  TinyPocketCar
//
//  Created by Nathan Birkholz on 5/26/17.
//  Copyright © 2017 natebirkholz. All rights reserved.
//

import Foundation
import CoreMotion

protocol MovementEvaluatorDelegate: class {
    func updateLabel(_ value: Double)
}

class MovementEvaluator {
    private var rotationEvents = [CMRotationRate]()
    private var rotationDeltas = [Double]()
    private var accelerationEvents = [CMAcceleration]()
    private var accelerationDeltas = [Double]()

    let motionManager = CMMotionManager()
    var lastAccel: CMAcceleration = CMAcceleration()
    var lastRotation: CMRotationRate = CMRotationRate()

    weak var delegate: MovementEvaluatorDelegate?

    init() {
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
    }

    func addRotationEvent(_ event: CMRotationRate) {
        rotationEvents.insert(event, at: 0)
        if rotationEvents.count == 11 { rotationEvents.remove(at: 10) }
    }

    func addRotationDelta(_ delta: Double) {
        rotationDeltas.insert(delta, at: 0)
        if rotationDeltas.count == 11 { rotationDeltas.remove(at: 10) }
    }

    func addAccelerationEvent(_ event: CMAcceleration) {
        
    }

    func evaluateMovement() -> MovementEvaluation {
        if let deviceMotion = motionManager.deviceMotion, let gyroData = motionManager.gyroData {
            var builder = EvaluationBuilder()

            // Get the *total* movement of the device. We want to know if the device is *primarily*
            // rotating side to side (z axis) and / or is primarily moving back and forth (y axis)
            let delta = deviceMotion.userAcceleration.deltaFromSigned(lastAccel)

            let diffX = deviceMotion.userAcceleration.x + lastAccel.x
            let diffy = deviceMotion.userAcceleration.y + lastAccel.y
            let diffz = deviceMotion.userAcceleration.z + lastAccel.z

            let absx = abs(diffX)
            let absy = abs(diffy)
            let absz = abs(diffz)

            lastAccel = deviceMotion.userAcceleration

            let deltaR = deviceMotion.rotationRate.deltaFrom(lastRotation)

            let diffXR = gyroData.rotationRate.x + lastRotation.x
            let diffyR = gyroData.rotationRate.y + lastRotation.y
            let diffzR = gyroData.rotationRate.z + lastRotation.z

            let absxR = abs(diffXR)
            let absyR = abs(diffyR)
            let abszR = abs(diffzR)

            lastRotation = gyroData.rotationRate

            if deltaR > 0.1 {
                let sorted = [absxR, absyR, abszR].sorted()
                if sorted.last! == abszR {
                    if abszR >= 2.5 {
                        builder.didTurn = true
                    }
                }
            }

            delegate?.updateLabel(abszR)

            if delta > 0.2 {
                let sorted = [absx, absy, absz].sorted()
                if sorted.last! == absy {
                    builder.didRev = true
                }
            } else if delta < -0.6 {
                let sorted = [absx, absy, absz].sorted()
                if sorted.last! == absy {
                    builder.didCrash = true
                }
            } else if delta < -0.2 {
                let sorted = [absx, absy, absz].sorted()
                if sorted.last! == absy {
                    builder.didBrake = true
                }
            }
            return builder.build()
        } else {
            return .none
        }
    }
}

enum MovementEvaluation {
    case none
    case forward
    case forwardFast
    case backward
    case backwardFast
    case changedDirection
    case brake
    case crash
    case turn
}

fileprivate struct EvaluationBuilder {
    var didMoveForward = false
    var didMoveBackward = false
    var didChangeDirection = false
    var didBrake = false
    var didCrash = false
    var didRev = false
    var didTurn = false

    func build() -> MovementEvaluation {
        if didCrash {
            return .crash
        } else if didTurn {
            return .turn
        } else if didBrake {
            return .brake
        } else if didMoveForward && didRev{
            return .forwardFast
        } else if didMoveBackward && didRev {
            return .backwardFast
        } else if didMoveForward {
            return .forward
        } else if didMoveBackward {
            return .backward
        } else if didChangeDirection {
            return .changedDirection
        } else {
            return .none
        }
    }
}

