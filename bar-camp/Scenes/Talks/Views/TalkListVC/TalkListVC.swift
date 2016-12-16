//
//  TalkListVC.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 9/30/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import UIKit

protocol TalkListDelegate: class {
    
    /// Tells to delegate add talk option was selected
    func didTapAddTalk()
    
    /// Tells to delegate a edit talk option was selected
    ///
    /// - parameter index: The talk index
    func didTapEditTalk(_ index: Int)
    
    /// Tells to delegate delayed talk option was selected
    ///
    /// - parameter index:   The talk index
    /// - parameter delayed: The talk delayed current status
    func didTapDelayTalk(_ index: Int, delayed: Bool)
    
    /// Tells to delegate a delete talk option was selected
    ///
    /// - parameter index: The talk index
    func didTapDeleteTalk(_ index: Int)
    
    
    /// Tells to delegate a show image option was selected
    ///
    /// - parameter index: The talk index
    func didTapImage(_ index: Int)
    
    
    /// Tells to delegate a image was requested for download
    ///
    /// - parameter url: The image url
    func didFetchImage(url: String)
}

class TalkListVC: UIViewController, TalkProtocol {

    var vm = TalksVM()
    var source = [TalkCM]()
    
    weak var delegate: TalkListDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI();
    }

    
    func setupUI(){
        self.automaticallyAdjustsScrollViewInsets = false
        if self.vm.isAdmin {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(toAddTalk))
        }
        self.tableView.register(UINib.init(nibName: "TalkCell", bundle: nil), forCellReuseIdentifier: "talkCell")
        self.tableView.register(UINib.init(nibName: "TalkCellExpanded", bundle: nil), forCellReuseIdentifier: "talkCellExpanded")
        self.tableView.register(UINib.init(nibName: "EmptyTalksCell", bundle: nil), forCellReuseIdentifier: "emptyTalksCell")
        
    }
    
    func updateUI(){
        self.source = self.vm.currentSection!.talks.map{TalkCM(talk: $0)}
        self.title = "\(NSLocalizedString("talk_for_time", comment: "")) \(self.vm.currentSection!.dateString)"
        self.tableView.reloadData()
    }
    
    func toAddTalk() {
                
        if vm.isSectionFull() {
            showFullSlotMessage()
        } else {
            self.delegate?.didTapAddTalk()
        }
        
    }
    
    func showFullSlotMessage() {
        let alert = UIAlertController(title: NSLocalizedString("talk_fullsection_title", comment: ""),
                                      message: NSLocalizedString("talk_fullsection_subtitle", comment: ""), preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .default) { (action) in
        }
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func fetchImage(url: String?) {
        if let _url = url, _url.hasPrefix("gs://") {
            self.delegate?.didFetchImage(url: _url)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TalkListVC: UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        guard self.source.count != 0 else { return 300 } // empty cell
        
        
        var item = self.source[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.expanded ? "talkCellExpanded" : "talkCell") as? TalkCell;
        cell?.configure(item.talk, image: self.vm.image(url: item.talk.photo))
        cell?.layoutIfNeeded()
        
        return cell?.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height ?? UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if !self.vm.isAdmin || self.source.count == 0{
            return []
        }
        
        
        let edit = UITableViewRowAction.init(style: .normal,  title: NSLocalizedString("talk_edit", comment: ""), handler: { [unowned self] (action: UITableViewRowAction, indexPath: IndexPath) in
            self.delegate?.didTapEditTalk(indexPath.row)
        })
        
        let delete = UITableViewRowAction.init(style: .default,  title: NSLocalizedString("talk_delete", comment: ""), handler: { [unowned self] (action: UITableViewRowAction, indexPath: IndexPath) in
            
                let alert = UIAlertController(title: NSLocalizedString("talk_delete_title", comment: ""), message: NSLocalizedString("talk_delete_confirmation", comment: ""), preferredStyle: .actionSheet)
                
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("talk_delete_cancel", comment: ""), style: .cancel) { (action) in
                }
                alert.addAction(cancelAction)
                
                let OKAction = UIAlertAction(title: NSLocalizedString("talk_delete_accept", comment: ""), style: .default) { (action) in
                    self.delegate?.didTapDeleteTalk(indexPath.row)
                }
                alert.addAction(OKAction)
            
                self.present(alert, animated: true) {}
            
            })
        
        
        let talk = self.vm.currentSection!.talks[indexPath.row]
        let delay = UITableViewRowAction.init(style: talk.delayed ? .normal : .default,  title: NSLocalizedString(talk.delayed ? "talk_ontime" : "talk_delayed", comment: "").capitalized,
                                              handler: { [unowned self] (action: UITableViewRowAction, indexPath: IndexPath) in
            self.delegate?.didTapDelayTalk(indexPath.row, delayed: !talk.delayed)
            })
        
        delete.backgroundColor = UIColor(colorHex: Color.red.default)
        edit.backgroundColor = UIColor(colorHex: Color.blue.default)
        delay.backgroundColor = UIColor(colorHex: talk.delayed ? Color.green.default : Color.yellow.default)
        
        return [delete, edit, delay]
    }
}

extension TalkListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.source.count != 0 else { return tableView.dequeueReusableCell(withIdentifier: "emptyTalksCell")!}

        
        var item = self.source[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.expanded ? "talkCellExpanded" : "talkCell") as? TalkCell;
        
        if (cell == nil){
            return UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier:"Cell");
        }else{
            let talk = self.vm.currentSection!.talks[indexPath.row]
            cell?.configure(talk, image: self.vm.image(url: talk.photo))
            cell?.delegate = self
        }
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard self.source.count != 0 else { return 1}
        return self.source.count;
    }
}

extension TalkListVC: TalkCellDelegate {
    
    func didTapExpand(inCell: UITableViewCell) {
        if let indexPath = self.tableView.indexPath(for: inCell) {
            
            var item = self.source[indexPath.row]
            let talk = self.vm.currentSection!.talks[indexPath.row]
            
            item.expanded = !item.expanded
            
            //fix weird aimation when laying out
            //http://stackoverflow.com/questions/30168504/weird-animation-behaviour-while-using-autolayout-in-xib
            let c: UITableViewCell? = tableView.cellForRow(at: indexPath)
            c?.layoutIfNeeded()
            
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            self.fetchImage(url: talk.photo)
        }
    }
    
    func didTapImage(inCell: UITableViewCell) {
        if let indexPath = self.tableView.indexPath(for: inCell) {
            self.delegate?.didTapImage(indexPath.row)
        }
    }
    
}




struct TalkCM {
    let talk: TalkVM
    static var expandedIds = Set<String>()
    
    var expanded: Bool {
        get { return TalkCM.expandedIds.contains(self.talk.id)}
        set(newValue){
            if newValue { TalkCM.expandedIds.insert(self.talk.id) } else { TalkCM.expandedIds.remove(self.talk.id) }
        }
    }
    
}
