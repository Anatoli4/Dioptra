//
//  VideoControls.swift
//  Dioptra
//
//  Created by Sergei Mikhan on 4/3/18.
//  Copyright © 2018 Sergei Mikhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public enum ScreenModeEvent {
  case fullscreen
  case compact
}

public enum SeekEvent {
  case started(progress: Float)
  case value(progress: Float)
  case finished(progress: Float)

  var progress: Float {
    switch self {
    case .started(let progress), .finished(let progress), .value(let progress):
      return progress
    }
  }
}

public enum Visibility {
  case force(visible: Bool)
  case soft(visible: Bool)

  var visible: Bool {
    switch self {
    case .force(let visible), .soft(let visible):
      return visible
    }
  }
}

public enum VisibilityChangeEvent {
  case force(visible: Bool)
  case soft(visible: Bool)
  case acceptSoft
  case softToggle
}

public protocol VideoControls: class {

  // RX inputs/outputs
  var visibilityChange: BehaviorRelay<VisibilityChangeEvent> { get }

  // RX inputs
  var buffer: PublishSubject<Float> { get }
  var progress: PublishSubject<Progress> { get }
  var state: PublishSubject<PlayerState> { get }

  // RX outputs
  var seek: Driver<SeekEvent> { get }
  var screenMode: Driver<ScreenModeEvent> { get }
  var play: Driver<PlaybackState> { get }
  var fullscreen: PublishSubject<Void> { get }
}

public protocol ControlsViewModable {
  associatedtype ViewModel: VideoControls
  var viewModel: ViewModel { get }
}
