//
//  DetailsViewController.swift
//  Demo
//
//  Created by Sergei Mikhan on 7/9/18.
//  Copyright © 2018 Sergei Mikhan. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.landscape
  }
}

class FullscreenViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let frame = view.bounds
    view.subviews.forEach {
      $0.frame = frame
    }
  }

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask.all
  }
}
