//
//  TalkCell.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/28/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import Foundation
import  UIKit


protocol TalkCellDelegate: class {
    func didTapExpand(inCell: UITableViewCell)
    func didTapImage(inCell: UITableViewCell)
}

class TalkCell: UITableViewCell {
    
    weak var delegate: TalkCellDelegate?
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var roomNameLB: UILabel!
    @IBOutlet weak var speakerNameLB: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var delayedLB: UILabel!
    @IBOutlet weak var photoBT: UIButton!
    @IBOutlet weak var separatorLB: UIView!
    
    @IBOutlet weak var delayedBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var photoBTTopMargin: NSLayoutConstraint!
    @IBOutlet weak var photoBTHeight: NSLayoutConstraint!
    
    private var _expanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.photoBT?.contentMode = .scaleAspectFit
        self.titleLB.textColor = UIColor(colorHex: Color.black.default)
        self.roomNameLB.textColor = UIColor(colorHex: Color.black.light)
        self.speakerNameLB.textColor = UIColor(colorHex: Color.black.light)
        self.desc?.textColor = UIColor(colorHex: Color.black.light)
        self.delayedLB.textColor = UIColor(colorHex: Color.yellow.default)
        self.separatorLB.backgroundColor = UIColor.groupTableViewBackground
        self.separatorLB.isHidden = false
        
        self.delayedLB.text = NSLocalizedString("talk_delayed", comment: "")
        
    }
    
    
    func configure(_ data: TalkVM, image: UIImage?) {
        self.titleLB.text = data.name
        self.roomNameLB.text = data.roomName
        self.speakerNameLB.text = data.speakerName + (data.twitterId.isEmpty ? "" : " (\(data.formattedTwId))")

        setDelayedHidden(!data.delayed)
        setTalkImage(image)
        self.desc?.text = data.desc

    }
    
    func setTalkImage(_ image: UIImage?) {
        
        //valid image and expanded cell
        if let mg = image, let _ = photoBT {
            let rimg = ResizeImage(image: mg, targetSize: CGSize.init(width: 325, height: 140))
            photoBT.setImage(rimg, for: .normal)
            
        } else {
            //reduce margin in expanded cell
            photoBTTopMargin?.constant = 0
            photoBTHeight?.constant = 0
        }
    }
    
    func setDelayedHidden(_ hidden: Bool){
        delayedLB.isHidden = hidden
        delayedBottomMargin.constant = hidden ? 0 : 24
    }
    
    @IBAction func expandAction(sender: UIButton) {
        self.delegate?.didTapExpand(inCell: self)
    }
    
    @IBAction func displayPhoto(sender: UIButton) {
        self.delegate?.didTapImage(inCell: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delayedLB.isHidden = true
        photoBT?.setImage(nil, for: .normal)
        setDelayedHidden(true)
        photoBTTopMargin?.constant = 20
        photoBTHeight?.constant = 140
        
    }
    
    class func estimateHeight(_ cellModel: TalkCM) -> CGFloat {
        
        if cellModel.expanded {
            if let url = cellModel.talk.photo, !url.isEmpty {
                return 388.0
            } else {
                return 228.0
            }
        } else {
            return 170.0
        }
        
    }
}
