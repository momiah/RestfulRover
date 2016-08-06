//
//  HardwareUIManager.swift
//  RoverRemote
//
//  Created by Muhammed Miah on 03/08/2016.
//  Copyright © 2016 Muhammed Miah. All rights reserved.
//

import Foundation
import UIKit

class HardwareUIManager : NSObject {
    
    let hardwareManager = HardwareManager()
    
    // View
    var parent : UIView?
    
    // Control UI
    var controlWASD : ControlButtonsWASD?
    var controlJoystick : ControlJoystick?
    var controlSeparate : UIView?
    var controlSeparateList : [String : ControlHardware] = [:]
    
    // Set up regular updates
    var timer : NSTimer? = nil
    
    override init() {
        super.init()
        hardwareManager.restfulHardware.addCallbackFunction(valueUpdateCallback)
        
        // Set up regular hardware updates
        setTimer()
    }
    
    func valueUpdateCallback(hardwareValues : [String : Double]) {
        // Update UI values
        for (hardware_name, hardware_value) in hardwareValues {
            if controlSeparateList[hardware_name] != nil {
                let control = controlSeparateList[hardware_name]!
                control.valueWasUpdated(Int32(hardware_value))
            }
        }
        
        // Remove UI controls if underlying hardware no longer exists
        for (hardware_name, _) in controlSeparateList {
            if hardwareValues[hardware_name] == nil {
                // hardware_name no longer exists on the actual hardware
                controlSeparateList = ControlHardware.removeSingleUIControl(controlSeparateList, hardware_name: hardware_name)
                
                if controlSeparateList.count == 0 {
                    (controlSeparate, controlSeparateList) =  ControlHardware.removeAllUIControls(
                        controlSeparate, controlSeparateList: controlSeparateList)
                }
            }
        }
    }
    
    func clearAllHardware() {
        (controlSeparate, controlSeparateList) =  ControlHardware.removeAllUIControls(
            controlSeparate, controlSeparateList: controlSeparateList)
        
        controlWASD?.removeFromSuperview()
        controlWASD = nil
        
        controlJoystick?.removeFromSuperview()
        controlJoystick = nil
        
        hardwareManager.clearAllHardware()
    }
    
    func updateUI() {
        if parent==nil {
            return
        }
        
        (controlSeparate, controlSeparateList) = ControlHardware.updateUI(hardwareManager,
                                                                          controlSeparate: controlSeparate,
                                                                          controlSeparateList: controlSeparateList,
                                                                          containerView: parent!)
        
        controlWASD = ControlButtonsWASD.updateUI(hardwareManager, controlWASD: controlWASD, containerView: parent!)
        controlJoystick = ControlJoystick.updateUI(hardwareManager, controlJoystick: controlJoystick, containerView: parent!)
    }
    
    func repositionUI() {
        ControlHardware.repositionUI(controlSeparate)
        ControlButtonsWASD.repositionUI(controlWASD)
        ControlJoystick.repositionUI(controlJoystick)
    }
    
    
    func timerFunc() {
        updateUI()
    }
    
    func setTimer() {
        if timer == nil {
            timer = NSTimer.scheduledTimerWithTimeInterval(
                1,
                target: self,
                selector: #selector(timerFunc),
                userInfo: nil,
                repeats: true)
        }
    }
    
    func removeTimer() {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
    
    
    
}