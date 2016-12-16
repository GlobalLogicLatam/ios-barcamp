//
//  TalkAddVC.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/3/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import UIKit
import GLCommons
import Photos


protocol TalkAddDelegate: class {
    
    /// Tells to delegate a new talk is gonna be created
    ///
    /// - parameter talk:      The talk data
    /// - parameter imageData: The talk image
    func didTryCreate(talk: TalkVM, imageData: Data?)
    
    /// Tells to delegate a talk is gonna be edited
    ///
    /// - parameter talk:      The talk data
    /// - parameter imageData: The talk image
    func didTryEdit(talk: TalkVM, imageData: Data?)
}

class TalkAddVC: UIViewController, TalkProtocol {

    var vm = TalksVM()
    
    weak var delegate: TalkAddDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickerView: UIPickerView!
    weak var roomNameTF: UITextField?
    
    var imageData: Data?
    
    var source: [CellModel]!
    var rNames = [String]()
    var editTalk: TalkVM!
    
    
    let toolbar = KeyboardToolbar.defaultToolbar()
    let validator = FormValidator<E>()
    
    // MARK: Controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.toolbar.mainScrollView = self.tableView
        self.updateUI();
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: TalkProtocol
    
    func setupUI(){
        self.automaticallyAdjustsScrollViewInsets = false
        self.title = "\(NSLocalizedString("talk_register", comment: "")) \(self.vm.currentSection!.dateString)"
        self.setupSaveButton();
        self.setupCellDataSource()
        self.setupFormValidator()
    }
    
    func setupCellDataSource() {
        //Cells data source initilization
        self.source = [
            CellModel(id:"simpleCell",
                      type: .name,
                      name: NSLocalizedString("talk_talk_name", comment: ""),
                      value: "",
                      placeHolder: NSLocalizedString("talk_talk_name", comment: ""),
                      height: 62.0),
            CellModel(id:"simpleCell",
                      type: .speaker,
                      name: NSLocalizedString("talk_speaker_name", comment: ""),
                      value: "",
                      placeHolder: NSLocalizedString("talk_speaker_name", comment: ""),
                      height: 62.0),
            CellModel(id:"simpleCell",
                      type: .twitterId,
                      name: "Twitter",
                      value: "",
                      placeHolder: NSLocalizedString("talk_speaker_twitter", comment: ""),
                      height: 62.0),
            CellModel(id:"simpleCell",
                      type: .room,
                      name: NSLocalizedString("talk_room", comment: ""),
                      value: "",
                      placeHolder: NSLocalizedString("talk_room", comment: ""),
                      height: 77.0),
            CellModel(id:"simpleCell",
                      type: .description,
                      name: NSLocalizedString("talk_description", comment: ""),
                      value: "",
                      placeHolder: NSLocalizedString("talk_description", comment: ""),
                      height: 72.0),
            CellModel(id:"photoCell",
                      type: .photo,
                      name: NSLocalizedString("talk_load_photo", comment: ""),
                      value: "",
                      placeHolder: "",
                      height: 170.0),
        ]
    }
    
    func setupFormValidator() {
        self.validator.didFind = { errors in
            for error in errors {
                let tf = error.transformedField?.fieldInfo as? UITextField
                tf?.addError(error.description)
            }
        }
        
        self.validator.didRemove = { errors in
            for error in errors {
                let tf = error.transformedField?.fieldInfo as? UITextField
                tf?.removeError()
            }
        }
    }
    
    func setupSaveButton() {
        
        let saveTitle = NSLocalizedString("talk_save", comment: "")
        let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        let item: UIBarButtonItem = UIBarButtonItem(title: saveTitle, style: .plain, target: self, action: self.vm.editingTalk ? #selector(editAction) : #selector(saveAction))
        item.setTitleTextAttributes(attr, for: .normal)
        self.navigationItem.rightBarButtonItem = item
    }
    
    
    func updateUI(){

        //Verifies whether the current talk has changed or not and the updates the ui
        if self.vm.editingTalk, let talk = self.vm.currentTalk, talk != self.editTalk {
            self.editTalk = talk
            self.source[0].value = talk.name
            self.source[1].value = talk.speakerName
            self.source[2].value = talk.twitterId
            self.source[3].value = talk.roomName
            self.source[4].value = talk.desc
            
            self.tableView.reloadData()
        }
        
        //Verifies whether the rooms list has changed or not and then updates the current list
        if  self.vm.config.rooms != self.rNames {
            self.rNames = self.vm.config.rooms
            
            var index = 0
            
            if let name = self.editTalk?.roomName, let idx = self.rNames.index(of: name) {
                index = idx
            }
            
            self.pickerView.selectRow(index, inComponent: 0, animated: false)
            self.pickerView(self.pickerView, didSelectRow: index, inComponent: 0)
        }
        
    }

    // MARK: Controller Actions

    func saveAction() {
        if self.validator.validateAllFields() {
            
            let name = self.validator.model[CellModel.CellType.name.rawValue] as? String
            let speaker = self.validator.model[CellModel.CellType.speaker.rawValue] as? String
            let twitterId = self.validator.model[CellModel.CellType.twitterId.rawValue] as? String
            let room = self.validator.model[CellModel.CellType.room.rawValue] as? String
            let desc = self.validator.model[CellModel.CellType.description.rawValue] as? String
            let time = self.vm.currentSection?.timestamp
            
            let talk = TalkVM(name: name ?? "",
                            timestamp: time!,
                            speakerName: speaker ?? "",
                            twitterId: twitterId ?? "",
                            roomName: room ?? "",
                            desc: desc ?? "",
                            delayed: false,
                            photo: nil)
            
            if vm.isRoomAvailable(room ?? "") {
                self.delegate?.didTryCreate(talk: talk, imageData: self.imageData)
            } else {
                showRoomUnavailableMessage()
            }
        }
    }
    
    func editAction() {
        
        if self.validator.validateAllFields() {
            if self.vm.editingTalk, let _talk = self.editTalk {
                
                let name = self.validator.model[CellModel.CellType.name.rawValue] as? String
                let speaker = self.validator.model[CellModel.CellType.speaker.rawValue] as? String
                let twitterId = self.validator.model[CellModel.CellType.twitterId.rawValue] as? String
                let room = self.validator.model[CellModel.CellType.room.rawValue] as? String
                let desc = self.validator.model[CellModel.CellType.description.rawValue] as? String
                let time = self.vm.currentSection?.timestamp
                
                let talk = TalkVM(id: _talk.id!,
                                  name: name ?? "",
                                  timestamp: time!,
                                  speakerName: speaker ?? "",
                                  twitterId: twitterId ?? "",
                                  roomName: room ?? "",
                                  desc: desc ?? "",
                                  delayed: _talk.delayed,
                                  photo: _talk.photo)

                if vm.isRoomAvailable(room ?? "") {
                    self.delegate?.didTryEdit(talk: talk, imageData: self.imageData)
                } else {
                    showRoomUnavailableMessage()
                }
            }
        }
    }
    
    func showRoomUnavailableMessage(){
        let alert = UIAlertController(title: NSLocalizedString("talk_room_unavailable_title", comment: ""),
                                      message: NSLocalizedString("talk_room_unavailable_subtitle", comment: ""), preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: NSLocalizedString("done", comment: ""), style: .default) { (action) in
        }
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
    
    }
    
    
    //TODO: Move this implementation to router class
    var picker: UIImagePickerController!
    func didTapAddPhoto(source: UIImagePickerControllerSourceType) {
        picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        self.present(picker, animated: true, completion:nil)
    }
}

// MARK: UITableViewDelegate

extension TalkAddVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return self.source[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let simple = cell as? SimpleCell {
            self.toolbar.removeField(simple.textTF)
            self.validator.disconnectUIControl(simple.textTF)
        }
    }
    
    
}

// MARK: UITableViewDataSource

extension TalkAddVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = self.source[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: model.id);
        
        if (cell == nil){
            return UITableViewCell(style:UITableViewCellStyle.value1, reuseIdentifier:"Cell");
        }else{
            self.configure(model: model, cell: cell!, indexPath: indexPath)
        }
        
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.source.count;
    }
    
    func configure(model: CellModel, cell: UITableViewCell, indexPath: IndexPath) {
        
        if let simple = cell as? SimpleCell {
            simple.titleLB.text = model.name
            simple.textTF.placeholder = model.placeHolder
            
            //Set the room picker list
            if model.type == .room {
                simple.textTF.inputView = self.pickerView
                self.roomNameTF = simple.textTF
            }
            
            //Set the validator value input value
            simple.textTF.text = self.validator.model[model.type.rawValue] as? String
            
            var validators = [FieldRule]()            
            
            //Twitter id and description are optional fields, so we skip to apply validation for them
            if model.type != .description && model.type != .twitterId {
                let eVal = NonEmptyValidator<E>()
                eVal.format = { return NSLocalizedString("talk_field_required", comment: "") }
                
                validators = [eVal]
            }
            
            
            simple.titleLB.isHidden = model.type == .room ? false : true
            
            //Form 
            let field = FormField(name: model.type.rawValue, fieldRules: validators, fieldInfo: simple.textTF)
            self.validator.connectUIControl(simple.textTF, field: field)
            self.toolbar.addField(simple.textTF, index: indexPath.row)
            
            //We clear the values after the initial loading
            if self.vm.editingTalk, let val = model.value {
                simple.textTF.text = val
                self.source[indexPath.row].value = nil
            }
            

        } else if let photo = cell as? PhotoCell {
            photo.delegate = self
        }
    }
}

// MARK: UIPickerViewDelegate & UIPickerViewDataSource

extension TalkAddVC: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.rNames[row]
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.roomNameTF?.text = self.rNames[row]
    }
}

extension TalkAddVC: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.rNames.count
    }
}

// MARK: PhotoCellDelegate

extension TalkAddVC: PhotoCellDelegate {

    func didTapLibrary(){
        self.didTapAddPhoto(source: .photoLibrary)
    }
    
    func didTapCamera(){
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            self.didTapAddPhoto(source: .camera)
        } else {
            self.showError(msg: NSLocalizedString("talk_camera_unavailable", comment: ""))
        }        
    }
}

// MARK: UIImagePickerControllerDelegate


extension TalkAddVC: UIImagePickerControllerDelegate {
 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        self.imageData = nil
        
        if #available(iOS 8.0, *), let referenceURL = info[UIImagePickerControllerReferenceURL] {
            
            let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceURL as! URL], options: nil)
            if let asset = assets.firstObject {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                
                manager.requestImage(for: asset, targetSize: CGSize.init(width: 1024, height: 768), contentMode: .aspectFit, options: option, resultHandler: { [weak self] (image: UIImage?, result:[AnyHashable : Any]?) in
                    if let img = image {
                        self?.imageData = UIImageJPEGRepresentation(img, 0.8)
                    }
                })
                
            }
            
            
        } else {
            guard let image = info[UIImagePickerControllerOriginalImage] as! UIImage? else { return }
            if let resImg = ResizeImage(image: image, targetSize: CGSize.init(width: 1024, height: 768)) {
                self.imageData = UIImageJPEGRepresentation(resImg, 0.8)
            }
        }

        picker.dismiss(animated: true, completion:nil)
        
    }
}

extension TalkAddVC: UINavigationControllerDelegate {
    
}



struct CellModel {
    
    enum CellType: String, CustomStringConvertible {
        case name = "name"
        case twitterId = "twitterId"
        case speaker = "speaker"
        case room = "room"
        case description = "description"
        case photo = "photo"
        
        public var description: String {
            get { return self.rawValue }
        }
    }
    
    let id: String
    let type: CellType
    let name: String
    var value: String?
    let placeHolder: String
    let height: CGFloat
}



class SimpleCell: UITableViewCell {

    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var textTF: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLB.textColor = UIColor(colorHex: Color.black.default)
        self.textTF.textColor = UIColor(colorHex: Color.black.light)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textTF.inputView = nil

    }
    
}

protocol PhotoCellDelegate: class {
    func didTapLibrary()
    func didTapCamera()
}
class PhotoCell: UITableViewCell {
    
    weak var delegate: PhotoCellDelegate?
    
    @IBOutlet weak var libraryBT: UIButton!
    @IBOutlet weak var cameraBT: UIButton!
    @IBOutlet weak var loadPhotoLB: UILabel!
    @IBOutlet weak var oLB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.loadPhotoLB.textColor = UIColor(colorHex: Color.black.default)
        self.oLB.textColor = UIColor(colorHex: Color.black.default)
    }
    
    @IBAction func cameraAction(sender: UIButton) {
        self.delegate?.didTapCamera()
    }

    @IBAction func libraryAction(sender: UIButton) {
        self.delegate?.didTapLibrary()
    }
    
}
