//
//  ReceiptsTableViewCell.swift
//  Receipts++
//
//  Created by Daniel Mathews on 2015-03-21.
//  Copyright (c) 2015 com.theplayapp. All rights reserved.
//

import UIKit

class ReceiptsTableViewCell: UITableViewCell {

    @IBOutlet weak var receiptNote: UILabel!
    @IBOutlet weak var receiptAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
