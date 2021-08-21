//
//  MovieCell.swift
//  MovieProject
//
//  Created by Abdullah Coban on 25.07.2021.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var favoriteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        favoriteBtn.alpha = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
