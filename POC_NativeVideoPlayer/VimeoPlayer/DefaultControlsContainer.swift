//
//  DefaultControlsContainer.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 30/09/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit

public class DefaultControlsContainer: UIView, ControlsContainerProtocol {
    
    static let nibName = "DefaultControlsContainer"
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak public var dismissButton: PlayerViewButton?
    @IBOutlet weak public var playButton: PlayerViewButton!
    @IBOutlet weak public var timeLabel: UILabel!
    @IBOutlet weak public var fullscreenButton: PlayerViewButton?
    
    @IBOutlet weak public var skipBackward: PlayerViewButton!
    @IBOutlet weak public var skipForward: PlayerViewButton!
    
    @IBOutlet weak var nextVideoButtonContainer: UIView!
    @IBOutlet weak public var nextVideoButton: PlayerViewButton!
    
    @IBOutlet weak public var subtitleButton: PlayerViewButton!
    @IBOutlet weak public var slider: PlayerViewSlider!
    
    private var gradientLayer = CAGradientLayer()
    
    public var bufferedTimeColor: CGColor! = UIColor.lightGray.cgColor
    
    override public func awakeFromNib() {
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.layer.borderWidth = 2
        
        gradientLayer.frame = backgroundView.bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.cgColor]
        backgroundView.layer.addSublayer(gradientLayer)
        backgroundView.backgroundColor = .clear
        
        fullscreenButton?.setImage(Utils.IconImages.ICON_FULLSCREEN.getImage(), for: .normal)
        fullscreenButton?.setImage(Utils.IconImages.ICON_FULLSCREEN_DISMISS.getImage(), for: .selected)
        
        fullscreenButton?.imageView?.contentMode = .scaleAspectFit
//
        let circleImage = slider.thumbImage(for: .normal)
//        let circleImage = UIImage(named: "icon_close")
        slider.setThumbImage(circleImage, for: .normal)
    }
    
    class func instanceFromNib() -> DefaultControlsContainer {
        return UINib(nibName: DefaultControlsContainer.nibName, bundle: Utils.podBundle).instantiate(withOwner: self, options: nil).first as! DefaultControlsContainer
    }
    
    private func stringFromNumber(timeStamp: Double, doubleDigit: Bool = true) -> String? {
        let minutes = floor(timeStamp / 60)
        let seconds = timeStamp.truncatingRemainder(dividingBy: 60)
        
        let timeString = String(format: "\(doubleDigit ? "%02d" : "%d"):%02d", Int(minutes), Int(seconds))
        
        return timeString
    }
    
    public func timerLabelShouldBeUpdated(duration: TimeInterval, currentTime: TimeInterval) {
        let string = NSMutableAttributedString()
        
        let currentTimeString = stringFromNumber(timeStamp: currentTime, doubleDigit: false)! + " / "
        
        let durationTimeString = stringFromNumber(timeStamp: duration, doubleDigit: false)!
        
        let currentTimeAttributed = NSAttributedString(string: currentTimeString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        let durationTimeAttributed = NSAttributedString(string: durationTimeString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray.withAlphaComponent(0.5)])
        
        string.append(currentTimeAttributed)
        string.append(durationTimeAttributed)
        
        timeLabel.attributedText = string
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        gradientLayer.frame = backgroundView.bounds
    }
    
    public func viewLayoutHaveChanged() {
        gradientLayer.frame = backgroundView.bounds
    }
    
}
