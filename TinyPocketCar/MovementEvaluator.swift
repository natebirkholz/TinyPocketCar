//
//  MovementEvaluator.swift
//  TinyPocketCar
//
//  Created by Nathan Birkholz on 5/26/17.
//  Copyright © 2017 natebirkholz. All rights reserved.
//

import UIKit
import CoreMotion

protocol MovementEvaluatorDelegate: class {
    func updateLabel(_ value: Double)
}

class MovementEvaluator {
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

    func evaluateMovement() -> MovementEvaluation {
        if let deviceMotion = motionManager.deviceMotion, let deviceRotation = motionManager.gyroData {
            var builder = EvaluationBuilder()

            // Get the *total* rotation of the device. We want to know if the device is *primarily*
            // rotating side to side (z axis)
            let deltaRotation = deviceMotion.rotationRate.deltaFrom(lastRotation)

            let diffxRotation = deviceRotation.rotationRate.x + lastRotation.x
            let diffyRotation = deviceRotation.rotationRate.y + lastRotation.y
            let diffzRotation = deviceRotation.rotationRate.z + lastRotation.z

            let absxRotation = abs(diffxRotation)
            let absyRotation = abs(diffyRotation)
            let abszRotation = abs(diffzRotation)

            lastRotation = deviceRotation.rotationRate

            if deltaRotation > 1 {
                let sorted = [absxRotation, absyRotation, abszRotation].sorted()
                if sorted.last! == abszRotation {
                    if abszRotation >= 2.5 {
                        builder.didTurn = true
                    }
                }
            }

            // Get the *total* movement of the device. We want to know if the device is *primarily*
            // moving forward and back (y axis)
            let deltaMove = deviceMotion.userAcceleration.deltaFromSigned(lastAccel)

            let diffxMove = deviceMotion.userAcceleration.x + lastAccel.x
            let diffyMove = deviceMotion.userAcceleration.y + lastAccel.y
            let diffzMove = deviceMotion.userAcceleration.z + lastAccel.z

            let absxMove = abs(diffxMove)
            let absyMove = abs(diffyMove)
            let abszMove = abs(diffzMove)

            lastAccel = deviceMotion.userAcceleration

            delegate?.updateLabel(abszRotation)

            if deviceMotion.userAcceleration.y > 0.075 {
                builder.didMoveForward = true
            } else if deviceMotion.userAcceleration.y < -0.075 {
                builder.didMoveBackward = true
            }

            if deltaMove > 0.2 {
                let sorted = [absxMove, absyMove, abszMove].sorted()
                if sorted.last! == absyMove {
                    builder.didRev = true
                }
            } else if deltaMove < -0.8 {
                let sorted = [absxMove, absyMove, abszMove].sorted()
                if sorted.last! == absyMove {
                    builder.didCrash = true
                }
            } else if deltaMove < -0.4 {
                let sorted = [absxMove, absyMove, abszMove].sorted()
                if sorted.last! == absyMove {
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
    case brake
    case crash
    case turn
}

fileprivate struct EvaluationBuilder {
    var didMoveForward = false
    var didMoveBackward = false
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
        } else {
            return .none
        }
    }
}

