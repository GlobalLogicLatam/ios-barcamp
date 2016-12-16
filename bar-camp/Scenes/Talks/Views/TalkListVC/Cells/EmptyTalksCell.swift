//
//  EmptyTalksCell.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/28/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import UIKit


class EmptyTalksCell: UITableViewCell {
    
    @IBOutlet weak var emptyLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.emptyLB.textColor = UIColor(colorHex: Color.black.default)
    }
}
