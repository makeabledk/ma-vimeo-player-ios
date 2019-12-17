//
//  PlayerViewController.swift
//  POC_NativeVideoPlayer
//
//  Created by Christian Amstrup Petersen on 17/09/2019.
//  Copyright © 2019 Makeable ApS. All rights reserved.
//

import UIKit
import PlayerKit
import SnapKit
import AVKit

class PlayerViewPresenter: UIViewController {
    
    private var playerView: PlayerView?
    
    init(playerView: UIView) {
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(playerView)
        playerView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
    
    init(playerView: PlayerView) {
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(playerView.view)
        self.playerView = playerView
        playerView.view.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        self.addChild(playerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .landscapeRight
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.playerView?.updateControlsLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView = nil
    }
    
}

public class PlayerView: UIViewController {
    
    static let controlsInteractionEndedNotification: Notification = Notification(name: .init("CONTROLS_INTERACTION_ENDED"))
    static let controlsInteractionBeganNotification: Notification = Notification(name: .init("CONTROLS_INTERACTION_BEGAN"))
    // MARK: Required functions
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    // MARK: - Components/Outlets
    /// VIMEO Player object PlayerView is build around. Player is optional as it will not be relocated from memory when dismissed without this property being set to 'nil'.
    var player: RegularPlayer? = RegularPlayer()
    
    private var controlsContainer: ControlsContainerProtocol!
    
    // MARK: - Properties
    public var delegate: PlayerViewDelegate?
    public var dataSource: PlayerViewDataSource?
    
    private var currentVideoID: String?
    private var nextVideoID: String? {
        didSet {
            checkedForNext = true
        }
    }
    
    /// Indicator to whether the datasource have been asked to supply the next video id.
    private var checkedForNext = false
    
    /// Under development
    private var controlFadeDuration: Double = 0.2
    
    private var controlIdleFadeTimer: Double = 7.0
    
    private var idleTimer: Timer?
    
    private var timer: DispatchSourceTimer?
    
    /// Amount, in seconds, in which the player should present the 'nextVideo'-button.
    private var headsUpTimer = 5.0
    /// Interval, in seconds, in which the delegate should be notified of current time playing on the video.
    private var delegateNotifyInterval = 5.0
    
//    private var notTouching = true
    
    /// Timestamp at which the video should start playing.
    private var skipTo = 0.0
    
    /// Timestamp at which the next video should start playing.
    private var nextSkipTo = 0.0
    
    /// Amount, in seconds, in which the player should jump in a skip is requested.
    private var skipInterval = 10.0
    
    /// Latest timestamp that have been saved. Will be parsed to current delegate, to notify about current video progress.
    private var currentTimeWithIntervals = 0.0
    
    /// Indicator on whether the player is currently in fullscreen-mode or not.
    private var isFullScreen = false {
        didSet {
            if self.controlsContainer.fullscreenButton?.isSelected != isFullScreen {
                DispatchQueue.main.async {
                    self.controlsContainer.fullscreenButton?.isSelected = self.isFullScreen
                }
            }
            if isFullScreen {
                self.controlsContainer.dismissButton?.isHidden = true
                self.controlsContainer.dismissButton?.isEnabled = false
            }else{
                self.controlsContainer.dismissButton?.isHidden = false
                self.controlsContainer.dismissButton?.isEnabled = true
            }
        }
    }
    
    /// Indicator on whether the playerView is presenting the subtitlePicker view.
    var isPresenting = false
    
    private var showingUI = true
    
    // MARK: - Fullscreen animation properties
    private var presenterDuration: Double = 0.3
    
    //       private var radian: CGFloat = 1.5708
    private var current = UIDevice.current
    private var inTransition = false
    private var currentOrientation: UIDeviceOrientation = .portrait
    
    private var origionalRoot: UIViewController?
    private var presenter: PlayerViewPresenter?
    private var presenterView: UIView?
    private var testing = true
    
    private var spinner: UIActivityIndicatorView?
    
    // MARK: - Override functions for init
    /// Custom initializer for Vimeo player view.
    ///
    /// IMPORTANT: A delegate and dataSource should be set after this intializer is called.
    ///
    /// - Parameters:
    ///   - customControlsContainer: View that conforms to the 'ControlsContainerProtocol', which will be used as controls for the player. If nil, a default controlsContainer will be supplied.
    ///   - id: ID of the initial video to play.
    ///   - start: TimeStamp (aka. Double) at which the video should start playing.
    ///   - headsUpAmount: Amount of time, in seconds, the video should present 'nextVideo'-button.
    ///   - controlFadeDuration: Duration for the animation, in seconds, to show/hide video controls.
    public init(customControlsContainer controls: ControlsContainerProtocol? = nil, videoID id: String, startPoint start: Double = 0.0, shouldStartPlaying autoPlay: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overCurrentContext
        skipTo = start
        if let controls = controls {
            controlsContainer = controls
        } else {
            controlsContainer = DefaultControlsContainer.instanceFromNib()
        }
        setupUI()
        configurePlayerView(videoID: id, autoPlay)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resignedActive), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startHideTimer), name: PlayerView.controlsInteractionEndedNotification.name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(cancelTimer), name: PlayerView.controlsInteractionBeganNotification.name, object: nil)
    }
    
    // MARK: - Configure functions
    private func configurePlayerView(videoID id: String, _ play: Bool = true) {
        VimeoService.current.requestHLSVideo(withId: id, completion: { url in
            guard let url = url else { return }
            if self.player != nil {
                self.player!.set(AVAsset(url: url))
                self.currentVideoID = id
                self.nextVideoID = nil
                self.checkedForNext = false
                self.hideOrShowNextVideoButton(hide: true)
                
                if play {
                    self.player!.play()
                }
            }
        })
    }
    
    
    /// Sets the amount for how much time remaining of the video, before the 'next video' button will be shown.
    /// - Parameter amount: Amount in seconds.
    public func setHeadsUpTimer(amount: Double) -> PlayerView {
        self.headsUpTimer = amount
        return self
    }
    
    /// Sets the duration of transition to and from fullscreen-animation.
    /// - Parameter amount: Amount in seconds.
    public func setFullscreenAnimationDuration(with amount: Double) -> PlayerView {
        self.presenterDuration = amount
        return self
    }
    
    /// Sets the amount of time, in seconds, the player should skip when skipForward/skipBackward buttons are pressed.
    /// - Parameter amount: Amount in seconds.
    public func setSkipInterval(with amount: Double) -> PlayerView {
        self.skipInterval = amount
        return self
    }
    
    /// Sets the duration of the fade animation when hiding/showing the controls container.
    /// - Parameter amount: Amount in seconds.
    public func setFadeDuration(with amount: Double) -> PlayerView {
        self.controlFadeDuration = amount
        return self
    }
    
    
    /// Sets the amount of time to be passed before the controls will automaticly hide.
    /// - Parameter amount: Amount in seconds.
    public func setControlIdleFadeTimer(with amount: Double) -> PlayerView {
        self.controlIdleFadeTimer = amount
        return self
    }
    
    // MARK: - Public functions
    public func updateControlsLayout() {
        self.controlsContainer.viewLayoutHaveChanged()
    }
    
    
    // MARK: - Private functions
    private func setupUI() {
        view.addSubview(player!.view)
        view.addSubview(controlsContainer)
        
        player!.view.backgroundColor = .black
        
        player!.view.accessibilityIdentifier = "PlayerViewContentView"
        
        player!.view.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        
        controlsContainer.snp.makeConstraints({ make in
            make.edges.equalTo(view.safeAreaInsets)
        })
        
        if spinner == nil {
        spinner = UIActivityIndicatorView(style: .whiteLarge)
            self.view.addSubview(spinner!)
            self.spinner?.snp.makeConstraints({ make in
            make.centerY.centerX.equalToSuperview()
        })
            self.view.bringSubviewToFront(spinner!)
            self.spinner?.isHidden = true
            self.spinner?.hidesWhenStopped = true
            self.spinner?.startAnimating()
        }
        
        player!.delegate = self
        
        controlsContainer.skipBackward.addTarget(self, action: #selector(skipInterval(_:)), for: .touchUpInside)
        controlsContainer.skipForward.addTarget(self, action: #selector(skipInterval(_:)), for: .touchUpInside)
        
        controlsContainer.isUserInteractionEnabled = true
        controlsContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playerTapped)))
        
        
        if let fullscreenButton = controlsContainer.fullscreenButton {
            fullscreenButton.addTarget(self, action: #selector(presentOrExitFullscreenMode(sender:)), for: .touchUpInside)
        }
        
        controlsContainer.playButton.addTarget(self, action: #selector(playOrPause), for: .touchUpInside)
        
        controlsContainer.skipBackward.accessibilityIdentifier = "skipBackward"
        controlsContainer.skipForward.accessibilityIdentifier = "skipForward"
        
        controlsContainer.nextVideoButton.addTarget(self, action: #selector(nextVideo), for: .touchUpInside)
        controlsContainer.nextVideoButton.alpha = 0
        
        controlsContainer.nextVideoButton.isUserInteractionEnabled = false
        
        controlsContainer.slider.addTarget(self, action: #selector(windInPlayer), for: .valueChanged)
        
        controlsContainer.subtitleButton.addTarget(self, action: #selector(changeSubtitle), for: .touchUpInside)
        
        controlsContainer.nextVideoButton.accessibilityIdentifier = "nextVideoButton"
        if controlsContainer.nextVideoButton.superview != controlsContainer {
            controlsContainer.nextVideoButton.superview?.accessibilityIdentifier = "nextVideoButtonContainer"
            controlsContainer.nextVideoButton.superview?.alpha = 0
        }
        
        if let dismissButton = controlsContainer.dismissButton {
            dismissButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        }
    }
    
    private func hideUI(_ hide: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: self.controlFadeDuration, animations: {
                self.controlsContainer.subviews.forEach({ view in
                    if view.accessibilityIdentifier != self.controlsContainer.nextVideoButton.accessibilityIdentifier, view.accessibilityIdentifier != "nextVideoButtonContainer", (view !== self.controlsContainer.dismissButton || view.accessibilityIdentifier != "nextVideoButtonContainer" && self.nextVideoID == nil) {
                        view.isUserInteractionEnabled = !hide
                        view.alpha = hide ? 0 : 1
                    }
                })
            }, completion: { success in
                if success {
                    self.showingUI = !hide
                    if hide {
                        self.timer?.cancel()
                        self.timer = nil
                    } else {
                        self.startHideTimer()
                    }
                }
            })
        }
    }
    
    private func hideOrShowNextVideoButton(hide: Bool) {
        hideUI(true)
        UIView.animate(withDuration: controlFadeDuration, animations: {
            self.controlsContainer.nextVideoButton.isUserInteractionEnabled = !hide
            self.controlsContainer.nextVideoButton.alpha = hide ? 0 : 1
            if self.controlsContainer.nextVideoButton.superview != self.controlsContainer {
                self.controlsContainer.nextVideoButton.superview?.alpha = hide ? 0 : 1
            }
        }, completion: nil)
    }
    
    private func skipIntervalIn(seconds: Double) {
        player!.pause()
        
        player!.seek(to: player!.time + seconds)
        if let player = player, player.time + seconds < player.duration {
            player.play()
        }
    }
    
    private func presentPlayerInFullscreen(rotateLeft left: Bool = true) {
        if !isFullScreen, !isPresenting, !inTransition {
            self.inTransition = true
            guard let root = UIApplication.shared.windows.first?.rootViewController, let parent = delegate?.shouldPresentInFullscreenOver(), let container = delegate?.containerViewForPlayer() else { return }
            origionalRoot = root
            
            let screen = UIScreen.main.bounds
            view.frame = self.view.frame
            
            let view = UIView(frame: container.frame)
            view.addSubview(self.view)
            self.presenterView = view
            parent.view.addSubview(view)
            self.view.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
            })
            
            let multiplier: CGFloat = left ? -1.0 : 1.0
            
            let xMultiplier = ((screen.width / 9) * 16) / view.frame.width
            let xTranslation: CGFloat = 49 // iPhone X translation
//            let xTranslation: CGFloat = 88 // iPhone SE translation
//            let xTranslation: CGFloat = 97.5 // iPhone 8 translation
//            let xTranslation: CGFloat = 106 // iPhone 8 Plus translation
            self.hideUI(true)
            
            let rotater = CGAffineTransform(rotationAngle: (.pi / 2) * multiplier).translatedBy(x: -xTranslation * multiplier, y: view.frame.width * 0.2).scaledBy(x: xMultiplier, y: screen.width/view.frame.height)
            let anchorPoint: CGFloat = left ? 0.8 : 0.2
            
            view.layer.anchorPoint = .init(x: anchorPoint, y: 1)

            view.layer.position = .init(x: view.frame.width * anchorPoint, y: self.view.frame.height + UIApplication.shared.statusBarFrame.height)
            
            UIView.animate(withDuration: presenterDuration + 0.0, animations: {
                view.transform = rotater
            }, completion: {
                _ in
                let presenter = PlayerViewPresenter(playerView: self)
                presenter.addChild(self)
                presenter.view.backgroundColor = .purple
                self.presenter = presenter
                UIApplication.shared.windows.first?.rootViewController = self.presenter
                self.hideUI(false)
                self.isFullScreen = true
                self.inTransition = false
            })
        }
    }
    
    private func dissmissPlayerInFullscreen() {
        if isFullScreen, !isPresenting, !inTransition {
            self.inTransition = true
            
            UIApplication.shared.windows.first?.rootViewController = origionalRoot
            let container = delegate?.containerViewForPlayer()
            self.removeFromParent()
            presenterView?.addSubview(self.view)
            self.view.snp.makeConstraints({ make in
                make.edges.equalToSuperview()
                
            })
            self.hideUI(true)
            
            UIView.animate(withDuration: presenterDuration, animations: {
                self.presenterView?.transform = CGAffineTransform.identity
            }, completion: { _ in
                self.view.removeFromSuperview()
                container?.insertSubview(self.view, at: 0)
                self.view.snp.makeConstraints({ make in
                    make.edges.equalToSuperview()
                })
                self.presenterView?.removeFromSuperview()
                self.hideUI(false)
                self.isFullScreen = false
                self.inTransition = false
            })
        }
    }
    
    // MARK: - ObjC Functions and IBActions
    @objc func orientationChange() {
        if current.orientation.rawValue < 5, !inTransition {
            currentOrientation = current.orientation
            if !isFullScreen, (current.orientation == .landscapeLeft || current.orientation == .landscapeRight) {
                presentPlayerInFullscreen(rotateLeft: current.orientation == .landscapeRight)
            } else if isFullScreen, (current.orientation == .portrait) {
                dissmissPlayerInFullscreen()
            }
        }
    }
    
    @objc func startHideTimer() {
        if !isPresenting, !inTransition, showingUI {
            self.timer?.cancel()
            let queue = DispatchQueue(label: "com.domain.app.timer")
            timer = DispatchSource.makeTimerSource(queue: queue)
            timer!.setEventHandler { [weak self] in
                self?.hideUI(true)
            }
            timer!.schedule(deadline: .now() + controlIdleFadeTimer)
            timer!.resume()
            
        }
    }
    
    @objc func cancelTimer() {
        timer?.cancel()
    }
    
    @objc func changeSubtitle() {
        if !inTransition {
            self.timer?.cancel()
            guard let parent = delegate as? UIViewController else { return }
            self.isPresenting = true
            let vc = SubtitlePickerViewController()
            
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overCurrentContext
            vc.playerDelegate = self
            vc.tableViewItems = player?.availableTextTracks ?? [TextTrackMetadata]()
            vc.selectedItem = player?.selectedTextTrack
            
            if isFullScreen {
                presenter?.present(vc, animated: true, completion: nil)
            } else {
                parent.present(vc, animated: true, completion: nil)
            }
            self.isPresenting = true
        }
    }
    
    @objc public func dismissSelf() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: PlayerView.controlsInteractionBeganNotification.name, object: nil)
        NotificationCenter.default.removeObserver(self, name: PlayerView.controlsInteractionEndedNotification.name, object: nil)
        
        if let id = currentVideoID, let time = player?.time, let duration = player?.duration {
            delegate?.timeStampUpdatedByIntevalOnVideo(withID: id, newCurrentTime: time, duration: duration)
        }
        
        self.player?.pause()
        self.player = nil
        
        delegate?.shouldDismissPlayer()
        if isFullScreen {
            self.dissmissPlayerInFullscreen()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func presentOrExitFullscreenMode(sender: Any) {
        if !isFullScreen, !inTransition {
            UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
        } else if isFullScreen, !inTransition {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    
    @objc func resignedActive() {
        if player!.playing {
            player!.pause()
        }
    }
    
    @objc func playerTapped() {
        if nextVideoID == nil {
            hideUI(showingUI)
        }
    }
    
    @objc func playOrPause() {
        if player!.playing {
            if let currentID = currentVideoID {
                delegate?.timeStampUpdatedByIntevalOnVideo(withID: currentID, newCurrentTime: player!.time, duration: player!.duration)
            }
            player!.pause()
        } else {
            if player!.time == player!.duration {
                player!.seek(to: 0)
            }
            player!.play()
        }
    }
    
    @objc func windInPlayer() {
        let currentTime = (player!.duration / Double(controlsContainer.slider.maximumValue)) * Double(controlsContainer.slider.value)
        player!.seek(to: currentTime)
    }
    
    @objc func nextVideo() {
        guard let nextID = nextVideoID else { return }
        player!.pause()
        self.configurePlayerView(videoID: nextID)
        delegate?.playingNextVideoInQueue(finishedVideoID: currentVideoID, nextID: nextID)
        skipTo = nextSkipTo
        nextSkipTo = 0.0
        currentTimeWithIntervals = 0.0
        hideUI(false)
    }
    
    @objc func skipInterval(_ sender: UIButton) {
        switch sender.accessibilityIdentifier {
        case "skipForward":
            self.skipIntervalIn(seconds: skipInterval)
        case "skipBackward":
            self.skipIntervalIn(seconds: -skipInterval)
        default:
            return
        }
    }
    
    private func renderBufferedTimeImage(duration: TimeInterval, bufferedTime: TimeInterval) -> UIImage? {
        guard let maxImage = controlsContainer.slider.maximumTrackImage(for: .normal) else { return nil }
        
        let size = CGSize(width: controlsContainer.slider.frame.width, height: maxImage.size.height)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(origin: .zero, size: size)
        shapeLayer.cornerRadius = 1.5
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let bufferedTimePercentage = CGFloat(bufferedTime / duration) * size.width
        
        shapeLayer.fillColor = controlsContainer.bufferedTimeColor
        shapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: bufferedTimePercentage, height: size.height)).cgPath
        
        shapeLayer.backgroundColor = controlsContainer.slider.maximumTrackTintColor != nil ?  controlsContainer.slider.maximumTrackTintColor!.cgColor : UIColor.darkGray.cgColor
        let image = renderer.image { context in
            return shapeLayer.render(in: context.cgContext)
        }
        
        return image
    }
}

// MARK: - Extensions PlayerDelegate
extension PlayerView: PlayerDelegate {
    
    public func playerDidUpdateState(player: Player, previousState: PlayerState) {
        switch player.state {
        case .loading:
            self.spinner?.isHidden = false
            self.spinner?.startAnimating()
            break
        case .ready:
            self.spinner?.stopAnimating()
            if skipTo > 0.0 {
                player.seek(to: skipTo)
                if player.playing {
                    skipTo = 0.0
                }
            }
            break
        case .failed:
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    public func playerDidUpdatePlaying(player: Player) {
        DispatchQueue.main.async {
            self.controlsContainer.playButton.isSelected = player.playing
        }
    }
    
    public func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0, let image = renderBufferedTimeImage(duration: player.duration, bufferedTime: player.bufferedTime) else { return }
        controlsContainer.slider.setMaximumTrackImage(image, for: .normal)
        
    }
    
    public func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else { return }
        
        let ratio = player.time / player.duration
        
        if controlsContainer.slider.isHighlighted == false {
            controlsContainer.slider.setValue(Float(ratio), animated: true)
        }
        if controlsContainer.timeLabel.alpha > 0 {
            controlsContainer.timerLabelShouldBeUpdated(duration: player.duration, currentTime: player.time)
        }
        
        if player.time >= currentTimeWithIntervals + delegateNotifyInterval || player.time <= currentTimeWithIntervals - delegateNotifyInterval, let currentVideoID = currentVideoID {
            currentTimeWithIntervals = player.time
            delegate?.timeStampUpdatedByIntevalOnVideo(withID: currentVideoID, newCurrentTime: currentTimeWithIntervals, duration: player.duration)
        }
        
        if player.duration <= player.time {
            if nextVideoID != nil {
                self.nextVideo()
            } else {
                dismissSelf()
            }
        } else if player.duration - headsUpTimer <= player.time, controlsContainer.nextVideoButton.alpha == 0, !checkedForNext {
            guard let dataSource = self.dataSource, let currentVideoID = currentVideoID else { return }
            guard let nextVideoData = dataSource.willFinishPlayingVideo(withID: currentVideoID) else {
                checkedForNext = true
                return
            }
            nextVideoID = nextVideoData.id
            nextSkipTo = nextVideoData.startPoint
            hideOrShowNextVideoButton(hide: false)
        }
    }
}
