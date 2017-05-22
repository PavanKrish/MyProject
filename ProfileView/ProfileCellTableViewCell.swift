//
//  ProfileCellTableViewCell.swift
//  ProfileView
//
//  Created by User on 5/17/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit

class ProfileCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var ID: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Age: UILabel!
    @IBOutlet weak var Gender: UILabel!
    @IBOutlet weak var roundView: UIView!
    @IBOutlet weak var hobby: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
