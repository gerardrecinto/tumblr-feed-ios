//
//  PhotoDetailsViewController.swift
//  tumblr
//
//  Created by Gerard Recinto on 2/9/17.
//  Copyright © 2017 Gerard Recinto. All rights reserved.
//

import UIKit

@MainActor
class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    var photoUrlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let urlString = photoUrlString, let photoUrl = URL(string: urlString) {
            photo.loadImage(from: photoUrl)
        }
    }

}
