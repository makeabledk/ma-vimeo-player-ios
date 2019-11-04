//
//  PlayerViewExtensions.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 01/10/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit


protocol AutoHidingView {}
extension AutoHidingView {
    func interactionStart() {
        NotificationCenter.default.post(PlayerView.controlsInteractionBeganNotification)
    }

    func interactionEnded() {
        NotificationCenter.default.post(PlayerView.controlsInteractionEndedNotification)
    }    
}

public class PlayerViewButton: UIButton, AutoHidingView {
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interactionEnded()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        interactionStart()
    }
}

public class PlayerViewSlider: UISlider, AutoHidingView {
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        interactionEnded()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        interactionStart()
    }
}

/// Protocol to define UI for custom controls to be shown over a given player
public protocol ControlsContainerProtocol: UIView {
    /// Play/pause button. isSelected will be change based player.state. Set icons accordingly.
    var playButton: PlayerViewButton! { get }
    
    /// Label to present current time on video.
    var timeLabel: UILabel! { get }
    
    /// Button to display the player in fullscreen mode. Selection state of the button will change, to either default or selected, based on current mode (i.e. fullscreen or not).
    var fullscreenButton: PlayerViewButton? { get }
    
    /// Button to notify the playerDelegate with, that the player should be dismissed.
    var dismissButton: PlayerViewButton? { get }
    
    /// Button to skip backward in video. Amount skipped is controlled by the playerView.
    var skipBackward: PlayerViewButton! { get }
    /// Button to skip forward in video. Amount skipped is controlled by the playerView.
    var skipForward: PlayerViewButton! { get }
    /// Button to press for next video to play.
    var nextVideoButton: PlayerViewButton! { get }
    
    /// Button to open subtitle menu.
    var subtitleButton: PlayerViewButton! { get }

    /// Slider to show progress in video time. Default minimum and maximum value must be retained. isContinuous should be true for continuous winding in player.
    var slider: PlayerViewSlider! { get }
    
    /// Color to indicate on the slider, how much time have buffered for the video.
    var bufferedTimeColor: CGColor! { get }
    
    /// Called on controlsContainer to signal it should update the timer label.
    /// - Parameter duration: Full duration of the video playing.
    /// - Parameter currentTime: Current time of the video playing.
    func timerLabelShouldBeUpdated(duration: TimeInterval, currentTime: TimeInterval)
    
    /// Notifies the controls view that it's size have changed.
    func viewLayoutHaveChanged()
    
}

public protocol PlayerViewDelegate: AnyObject {
    
    /// Asks the delegate for the UIViewController to present animations over.
    func shouldPresentInFullscreenOver() -> UIViewController
    
    /// Asks the delegate for the view in which the player is contained.
    func containerViewForPlayer() -> UIView
     
    /// Will notify the delegate that playing time have update it's current time.
    ///
    /// The delegate is notified of this update to prevent loss of progress on the video, in case of crashes and bugs.
    ///
    /// - Parameters:
    ///   - id: ID of the video currently playing.
    ///   - time: Timestamp, at which, the video is currently playing.
    ///   - duration: Timestamp for the full duration of the video.
    func timeStampUpdatedByIntevalOnVideo(withID id: String, newCurrentTime time: Double, duration: Double)
    
    /// Will notify the delegate that the 'dismissButton' have been pressed.
    func shouldDismissPlayer()
    
    /// Will notify the delegate that the player will proceed with playing next video provided by the datasource.
    /// - Parameter oldID: ID of the video that ended playing.
    /// - Parameter id: ID of the video set to play next.
    func playingNextVideoInQueue(finishedVideoID oldID: String?, nextID id: String)
}

extension PlayerViewDelegate {
    
    func shouldDismissPlayer() {}
    
    func playingNextVideoInQueue(finishedVideoID oldID: String?, nextID id: String) {}
}

public protocol PlayerViewDataSource: AnyObject {
    /// Asks dataSource for the Vimeo ID of the next video that should be played next.
    ///
    /// Will be called when the remaining time of current video playing, is equal or less than, the given 'nextVideoHeadsUpAmount'. HeadsUpAmount is by default 0.0.
    ///
    /// - Parameter id: ID of the video currently playing.
    /// - Returns: ID for next video to player and point at which the video should skip to at start. If nil, PlayerView will notify it's delegate that it should close.
    func willFinishPlayingVideo(withID id: String) -> (id: String, startPoint: Double)?
}




