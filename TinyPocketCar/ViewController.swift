//
//  ViewController.swift
//  TinyPocketCar
//
//  Created by Nathan Birkholz on 5/11/17.
//  Copyright © 2017 natebirkholz. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {

    let motionManager = CMMotionManager()
    var timer: Timer!
    var lastAccel: CMAcceleration = CMAcceleration()
    var lastRotation: CMRotationRate = CMRotationRate()

    var label: UILabel?

    var crashLabel: UILabel?
    var screechLabel: UILabel?
    var brakeLabel: UILabel?
    var revLabel: UILabel?


    var enginePlayer: AVAudioPlayer?
    var screechPlayer: AVAudioPlayer?
    var vroomPlayer: AVAudioPlayer?
    var crashPlayer1: AVAudioPlayer?
    var crashPlayer2: AVAudioPlayer?
    var squealPlayer: AVAudioPlayer?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        makeLabels()

        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()

        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        idle()

    }

    func makeLabels() {
        let labelOne = UILabel()
        labelOne.text = "0"
        labelOne.font = UIFont.systemFont(ofSize: 24)
        labelOne.textColor = UIColor.darkGray
        labelOne.numberOfLines = 1
        labelOne.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelOne.textAlignment = .center
        labelOne.sizeToFit()

        self.view.addSubview(labelOne)
        labelOne.center = self.view.center
        labelOne.frame.origin.y = labelOne.frame.origin.y - 70

        self.label = labelOne

        let labelTwo = UILabel()
        labelTwo.text = "Crash!"
        labelTwo.font = UIFont.systemFont(ofSize: 24)
        labelTwo.textColor = UIColor.darkGray
        labelTwo.numberOfLines = 1
        labelTwo.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelTwo.textAlignment = .center
        labelTwo.sizeToFit()
        labelTwo.alpha = 0

        self.view.addSubview(labelTwo)
        labelTwo.center = self.view.center
        labelTwo.frame.origin.y = labelOne.frame.origin.y - -35

        self.crashLabel = labelTwo

        let labelThree = UILabel()
        labelThree.text = "Screech!"
        labelThree.font = UIFont.systemFont(ofSize: 24)
        labelThree.textColor = UIColor.darkGray
        labelThree.numberOfLines = 1
        labelThree.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelThree.textAlignment = .center
        labelThree.sizeToFit()
        labelThree.alpha = 0

        self.view.addSubview(labelThree)
        labelThree.center = self.view.center

        self.screechLabel = labelThree

        let labelFour = UILabel()
        labelFour.text = "Brake!"
        labelFour.font = UIFont.systemFont(ofSize: 24)
        labelFour.textColor = UIColor.darkGray
        labelFour.numberOfLines = 1
        labelFour.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelFour.textAlignment = .center
        labelFour.sizeToFit()
        labelFour.alpha = 0

        self.view.addSubview(labelFour)
        labelFour.center = self.view.center
        labelFour.frame.origin.y = labelFour.frame.origin.y + 35

        self.brakeLabel = labelFour

        let labelFive = UILabel()
        labelFive.text = "Rev!"
        labelFive.font = UIFont.systemFont(ofSize: 24)
        labelFive.textColor = UIColor.darkGray
        labelFive.numberOfLines = 1
        labelFive.frame = CGRect(x: 0, y: 0, width: 125, height: 30)
        labelFive.textAlignment = .center
        labelFive.sizeToFit()
        labelFive.alpha = 0

        self.view.addSubview(labelFive)
        labelFive.center = self.view.center
        labelFive.frame.origin.y = labelFive.frame.origin.y + 70


        self.revLabel = labelFive
    }

    func update() {
        if let accelerometerData = motionManager.accelerometerData {
            //            print("--> accelerometerData: \(accelerometerData)\n")
        }
        if let gyroData = motionManager.gyroData {
            //            print("--> gyroData: \(gyroData.rotationRate)\n")
        }
        if let magnetometerData = motionManager.magnetometerData {
//                        print("--> magnetometerData: \(magnetometerData)\n")
        }

        if let deviceMotion = motionManager.deviceMotion, let gyroData = motionManager.gyroData {

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
                //                print("--> delta: \(delta), \n\t\tx: \(diffX), y:\(diffy), z: \(diffz)")
                let sorted = [absxR, absyR, abszR].sorted()
                if sorted.last! == absxR {
                    print("\t ROTATED X")
                } else if sorted.last! == absyR {
                    print("\t ROTATED Y")
                } else if sorted.last! == abszR {
                    print("\t ROTATED Z")
                    if abszR >= 2.5 {
                        screech()
                    }
                }

                if abszR >= 2.5 {
                    label?.text = "2.5"
                    label?.backgroundColor = UIColor.red
                } else if abszR >= 1.0 {
                    label?.text = "1.0"
                    label?.backgroundColor = UIColor.yellow
                } else if abszR >= 0.5 {
                    label?.text = "0.5"
                    label?.backgroundColor = UIColor.green
                } else {
                    label?.text = "0.0"
                    label?.backgroundColor = UIColor.clear
                }

            }

            if delta > 0.2 {
                //                print("--> delta: \(delta), \n\t\tx: \(diffX), y:\(diffy), z: \(diffz)")
                let sorted = [absx, absy, absz].sorted()
                if sorted.last! == absx {
                    //                    print("\t MOVED X")
                } else if sorted.last! == absy {
                    print("\t MOVED Y")
                    vroom()
                } else if sorted.last! == absz {
                    //                    print("\t MOVED Z")
                }
            } else if delta < -0.6 {
                let sorted = [absx, absy, absz].sorted()
                if sorted.last! == absy {
                    print("\t CRASHED Y")
                    crash()
                }
            } else if delta < -0.2 {
                let sorted = [absx, absy, absz].sorted()
                if sorted.last! == absy {
                    print("\t BRAKED Y")
                    brake()
                }
            }
        }
    }

    func screech() {
        let url = Bundle.main.url(forResource: "TireScreech_01", withExtension: "mp3")!

        if let play = screechPlayer, play.isPlaying { return }

        do {
            screechPlayer = try AVAudioPlayer(contentsOf: url)
            guard let _ = screechPlayer else { return }

            screechLabel?.alpha = 1.0
            UIView.animate(withDuration: 1.0, animations: { self.screechLabel?.alpha = 0 })

            screechPlayer?.prepareToPlay()
            screechPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func vroom() {
        let url = Bundle.main.url(forResource: "MotorRev_04", withExtension: "mp3")!

        if let play = vroomPlayer, play.isPlaying { return }

        do {
            vroomPlayer = try AVAudioPlayer(contentsOf: url)
            guard vroomPlayer != nil else { return }
            revLabel?.alpha = 1.0
            UIView.animate(withDuration: 1.0, animations: { self.revLabel?.alpha = 0 })
            vroomPlayer?.prepareToPlay()
            vroomPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func crash() {
        let url1 = Bundle.main.url(forResource: "Crash_03", withExtension: "mp3")!
        let url2 = Bundle.main.url(forResource: "Crash_04", withExtension: "mp3")!

        if let play1 = crashPlayer1, play1.isPlaying { return }
        if let play2 = crashPlayer2, play2.isPlaying { return }

        do {
            crashPlayer1 = try AVAudioPlayer(contentsOf: url1)
            guard crashPlayer1 != nil else { return }
            crashPlayer2 = try AVAudioPlayer(contentsOf: url2)
            guard crashPlayer2 != nil else { return }

            crashLabel?.alpha = 1.0
            UIView.animate(withDuration: 1.0, animations: {
                self.crashLabel?.alpha = 0
            })

            crashPlayer1?.prepareToPlay()
            crashPlayer2?.prepareToPlay()
            crashPlayer1?.play()
            crashPlayer2?.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    func brake() {
        let url = Bundle.main.url(forResource: "BrakeSqueal_01", withExtension: "mp3")!

        if let play = squealPlayer, play.isPlaying { return }

        do {
            squealPlayer = try AVAudioPlayer(contentsOf: url)
            guard squealPlayer != nil else { return }

            brakeLabel?.alpha = 1.0
            UIView.animate(withDuration: 1.0, animations: { self.brakeLabel?.alpha = 0 })

            squealPlayer?.prepareToPlay()
            squealPlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func idle() {
        let url = Bundle.main.url(forResource: "MotorIdle_lp_01", withExtension: "wav")!

        do {
            enginePlayer = try AVAudioPlayer(contentsOf: url)
            guard enginePlayer != nil else { return }
            enginePlayer?.numberOfLoops = -1
            enginePlayer?.prepareToPlay()
            enginePlayer?.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension CMAcceleration {
    var sum:Double {
        let sumFor = abs(x) + abs(y) + abs(z)
        return sumFor
    }

    func deltaFrom(_ other: CMAcceleration) -> Double {
        let deltaFor = abs(sum - other.sum)
        return deltaFor
    }

    func deltaFromSigned(_ other: CMAcceleration) -> Double {
        let deltaFor = sum - other.sum
        return deltaFor
    }
}

extension CMRotationRate {
    var sum:Double {
        let sumFor = abs(x) + abs(y) + abs(z)
        return sumFor
    }

    func deltaFrom(_ other: CMRotationRate) -> Double {
        let deltaFor = abs(sum - other.sum)
        return deltaFor
    }
}

