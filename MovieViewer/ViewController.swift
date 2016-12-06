//
//  ViewController.swift
//  MovieViewer
//
//  Created by qburst on 05/10/16.
//  Copyright © 2016 qburst. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate {
    
//MARK: Properties
    var movie : Movie? 
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var movieImage: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        movieImage.image = movie?.movieImage
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.movieImage
    }

}

