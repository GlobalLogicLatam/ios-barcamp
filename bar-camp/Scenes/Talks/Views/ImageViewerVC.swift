//
//  ImageViewerVC.swift
//  bar-camp
//
//  Created by Carlos David Rios Vertel on 10/26/16.
//  Copyright © 2016 Global Logic. All rights reserved.
//

import UIKit

class ImageViewerVC: UIViewController, Customizable {

    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI(){
        if let img = image {
            self.imageView.image = img
            self.imageView.contentMode = UIViewContentMode.scaleAspectFit
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeAction))
    }
    
    func updateUI(){}

    //MARK: Action
    @IBAction func closeAction() {
        self.dismiss(animated: true, completion: nil)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImageViewerVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView;
    }
    
}
