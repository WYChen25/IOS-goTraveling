//
//  photoTableViewCell.swift
//  goTravelling
//
//  Created by smallchen on 2018/11/30.
//  Copyright © 2018 cn.nju.edu.cn. All rights reserved.
//

import UIKit

class photoTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var photoName: UILabel!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var photoDesc: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
