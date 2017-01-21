//
//  ResultCell.swift
//  ChimeraPad
//
//  Created by Wayne Rittimann, Jr. on 1/20/17.
//  Copyright © 2017 Wayne Rittimann, Jr. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {

    @IBOutlet weak var player1HandScore: UILabel!
    @IBOutlet weak var player1ScoreLabel: UILabel!
    @IBOutlet weak var player2ScoreLabel: UILabel!
    @IBOutlet weak var player2HandScore: UILabel!
    @IBOutlet weak var player3ScoreLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var player3HandScore: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
