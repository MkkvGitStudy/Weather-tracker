//
//  MovieTableViewCell.swift
//  MovieViewer
//
//  Created by qburst on 05/10/16.
//  Copyright © 2016 qburst. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {
    
//MARK: Properties
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var movieOverview: UITextView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var movieImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
