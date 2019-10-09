//
//  VideoCell.swift
//  Demo
//
//  Created by Sergei Mikhan on 8/21/18.
//  Copyright © 2018 Sergei Mikhan. All rights reserved.
//

import Astrolabe
import Dioptra
import RxSwift

class ManualLayoutView: UIView {

  override open class var requiresConstraintBasedLayout: Bool {
    return false
  }
}

class VideoCell: CollectionViewCell, Reusable {

  let disposeBag = DisposeBag()

  weak var landscapeViewController: UIViewController?
  weak var fullscreenViewController: UIViewController?

  //typealias Player = VideoPlayerView<YTVideoPlaybackView, VideoPlayerControlsView>
  //typealias Player = VideoPlayerView<DMVideoPlaybackView, VideoPlayerControlsView>
  //typealias Player = VideoPlayerView<BCVideoPlaybackView, VideoPlayerControlsView>
  typealias Player = VideoPlayerView<AVVideoPlaybackView, VideoPlayerControlsView>

  let player = Player(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width - 48,
                                    height: (UIScreen.main.bounds.width - 48) * 9.0 / 16.0))
  let playerContainer = ManualLayoutView(frame: CGRect(x: 22.0, y: 44.0,
                                         width: UIScreen.main.bounds.width - 48,
                                         height: (UIScreen.main.bounds.width - 48) * 9.0 / 16.0))

  override func setup() {
    super.setup()

    playerContainer.translatesAutoresizingMaskIntoConstraints = true

    contentView.addSubview(playerContainer)
    playerContainer.addSubview(player)

    player.playbackView.viewModel.input = .content(stream: "http://psg75.c-cast-cdn.tv/8E0071723758EE5CDD1CA0544FE4FF53/8E0071723758EE5CDD1CA0544FE4FF53.mp4")
//    player.playbackView.viewModel.servicePolicyKey = "BCpkADawqM1W-vUOMe6RSA3pA6Vw-VWUNn5rL0lzQabvrI63-VjS93gVUugDlmBpHIxP16X8TSe5LSKM415UHeMBmxl7pqcwVY_AZ4yKFwIpZPvXE34TpXEYYcmulxJQAOvHbv2dpfq-S_cm"
//    player.playbackView.viewModel.accountID = "3636334163001"
//    player.playbackView.viewModel.input = .content(stream: "3666678807001")
    player.playbackView.viewModel.muted = true
    player.controlsView.fullscreenButton.setTitle("Full", for: .normal)
    player.controlsView.errorLabel.text = "Error"
    player.controlsView.viewModel.fullscreen.subscribe(onNext: { [weak self] in
      self?.handleFullscreen()
    }).disposed(by: disposeBag)

    player.playbackView.viewModel.playerState.asObservable().subscribe(onNext: { [weak self] playerState in
      switch playerState {
      case .ready:
        self?.player.playbackView.viewModel.state.onNext(PlaybackState.playing)
      default: break
      }
    }).disposed(by: disposeBag)

    NotificationCenter.default.rx.notification(UIDevice.orientationDidChangeNotification, object: nil)
      .map { _ in return UIDevice.current.orientation }
      .distinctUntilChanged()
      .filter { [weak self] _ in self?.fullscreenViewController == nil }
      .filter { $0.isLandscape || $0.isPortrait }
      .filter({ [weak self] _ -> Bool in
        guard let detailsViewController = self?.landscapeViewController else { return true }
        return !(detailsViewController.isBeingPresented || detailsViewController.isBeingDismissed)
      }).subscribe(onNext: { [weak self] orientation in
        if self?.landscapeViewController != nil && orientation.isPortrait {
          self?.landscapeViewController?.dismiss(animated: true)
        } else if orientation.isLandscape && self?.landscapeViewController == nil {
          self?.toLandscape()
        }
      }).disposed(by: disposeBag)
  }

  typealias TransitionableViewController = UIViewController & Transitionable

  fileprivate func toLandscape() {
    guard let container = containerViewController as? TransitionableViewController else {
      return
    }
    let detailsViewController = LandscapeViewController()
    self.landscapeViewController = detailsViewController
    container.present(modal: detailsViewController,
            method: TransitionMethod.landscape(presentingView: self.player))
  }

  fileprivate func handleFullscreen() {
    guard let container = containerViewController as? TransitionableViewController else {
      return
    }
    if let fullscreenViewController = fullscreenViewController {
      fullscreenViewController.dismiss(animated: true)
    } else if let landscapeViewController = landscapeViewController {
      landscapeViewController.dismiss(animated: true)
    } else {
      let detailsViewController = FullscreenViewController()
      self.fullscreenViewController = detailsViewController
      container.present(modal: detailsViewController,
                        method: TransitionMethod.fullscreen(presentingView: self.player))
    }
  }

  override func willDisplay() {
    super.willDisplay()
    guard let containerView = containerView else { return }
    if player.detached {
      player.attach(to: playerContainer, with: playerContainer.bounds, overView: containerView)
    }
  }

  override func endDisplay() {
    super.endDisplay()
    guard let containerViewController = containerViewController else { return }
    let frame = CGRect(x: 20.0, y: 20.0, width: 120.0, height: 120.0 * 9.0 / 16.0)
    player.detach(to: containerViewController.view, with: frame)
  }

  typealias Data = Void
  static func size(for data: Data, containerSize: CGSize) -> CGSize {
    return CGSize(width: containerSize.width, height: containerSize.width * 9.0 / 16.0)
  }
}
