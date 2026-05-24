//
//  PhotoDetailsViewController.swift
//  tumblr
//
//  Created by Gerard Recinto on 2/9/17.
//  Copyright © 2017 Gerard Recinto. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    var photoUrlString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        let photoUrl = URL(string: photoUrlString)
        photo.loadImage(from: photoUrl!)
        // Do any additional setup after loading the view.
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
