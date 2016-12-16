//
//  TalksListViewController.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/29/16.
//  Copyright (c) 2016 Global Logic. All rights reserved.
//

import UIKit
import GLCommons

protocol TalkTimesDelegate: class {
    
    /// Tells to delagets a time slot section has been selected
    ///
    /// - parameter sectionIndex: The section index
    /// - parameter isBreakSlot:  The time slot section is break time
    func didSelect(sectionIndex: Int, isBreakSlot: Bool)
    
    
    /// Tells to delegate a user selects a log out option
    func didTapLogOut()
}

class TalkTimesVC: UIViewController, TalkProtocol {

    
    weak var delegate: TalkTimesDelegate?    
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: Object lifecycle
    var vm = TalksVM()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI();
    }

    func updateUI() {
        self.tableView.reloadData()
    }

    func setupUI() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let post =  UIBarButtonItem.init(title: NSLocalizedString("talk_log_out", comment: ""), style: .plain, target: self, action: #selector(logOutAction))
        
        var attr = [NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        if #available(iOS 8.2, *) {
            attr = [NSFontAttributeName:  UIFont.systemFont(ofSize: 17, weight:UIFontWeightMedium)]
        }
        
        post.setTitleTextAttributes(attr, for: .normal)
        self.navigationItem.rightBarButtonItem = post        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.setStatusBarColor(UIColor(colorHex: Color.red.default))
    }
    
    func logOutAction(){
        self.delegate?.didTapLogOut()
    }

}

extension TalkTimesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{

        if vm.config.areTalksAvailable {
            return 60.0
        }
        
        return 521.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard vm.config.areTalksAvailable else { return }
        
        let slot = self.vm.sections[indexPath.row]
        self.delegate?.didSelect(sectionIndex: indexPath.row, isBreakSlot: slot.isBreak)
        if slot.isBreak {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
}

extension TalkTimesVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        if !vm.config.areTalksAvailable {
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyContentCell") as? EmptyContentCell
            emptyCell?.setStartDateTitle(vm.config.startDateString)
            return emptyCell!;
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell") as? TimeCell;
        
        if (cell == nil){
            return UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier:"Cell");
        }else{
            cell?.configure(vm.sections[indexPath.row])
        }
        
        return cell!;
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if vm.config.areTalksAvailable {
            return vm.sections.count
        }
        
        return 1;
    }    
}


class TimeCell : UITableViewCell  {
    
    @IBOutlet var arrowImage: UIImageView!
    @IBOutlet var clockImage: UIImageView!
    @IBOutlet private weak var timeLB: UILabel!
    @IBOutlet private weak var TalksLB: UILabel!
    
    var isBreak = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.timeLB.textColor = UIColor(colorHex: Color.gray.dark)
        self.TalksLB.textColor = UIColor(colorHex: Color.black.light)
    }
    
    func configure(_ section: TalkListSection) {
        timeLB.text = section.dateString
        TalksLB.text = "\(section.talks.count) \(NSLocalizedString("talk_talks", comment: ""))"
        
        if section.isBreak {
            self.isBreak = true
            TalksLB.text = NSLocalizedString("talk_break_time", comment: "")
            TalksLB.font = UIFont(name: "Helvetica-Light", size: 16.0)
            timeLB.font = UIFont(name: "Helvetica-Light", size: 16.0)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = UIColor.white
        self.isBreak  = false
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if isBreak {
            return
        }
        
        self.backgroundColor = selected ? UIColor(colorHex: Color.blue.default) : UIColor.white
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        
        if isBreak {
            return
        }
        
        if highlighted {
            timeLB.textColor = UIColor.white
            TalksLB.textColor = UIColor.white
        } else {
            timeLB.textColor = UIColor.black
            TalksLB.textColor = UIColor.black
        }
        
        self.backgroundColor = highlighted ? UIColor(colorHex: Color.blue.default) : UIColor.white
    }
}

class EmptyContentCell: UITableViewCell {
    
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var subTitleLB: UILabel!
    @IBOutlet weak var textLB: UILabel!
    
   
    override func awakeFromNib() {
        super.awakeFromNib();
        titleLB.text = "\(NSLocalizedString("talk_empty_content_title", comment: "")) ";
        subTitleLB.text = NSLocalizedString("talk_empty_content_subtitle", comment: "")
        textLB.text = NSLocalizedString("talk_empty_content_text", comment: "")
        
        titleLB.textColor = UIColor(colorHex: Color.gray.dark)
        subTitleLB.textColor = UIColor(colorHex: Color.gray.default)
        textLB.textColor = UIColor(colorHex: Color.gray.default)
        
    }
    
    func setStartDateTitle(_ start: String) {
        titleLB.text = "\(NSLocalizedString("talk_empty_content_title", comment: "")) \(start)!";
    }
}
