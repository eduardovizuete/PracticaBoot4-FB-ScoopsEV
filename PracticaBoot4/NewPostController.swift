//
//  NewPostController.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase

class NewPostController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titlePostTxt: UITextField!
    @IBOutlet weak var textPostTxt: UITextField!
    @IBOutlet weak var imagePost: UIImageView!
    
    var userAuth : String = ""
    let newsRef = FIRDatabase.database().reference().child("News")
    
    var isReadyToPublish: Bool = false
    var imageCaptured: UIImage! {
        didSet {
            imagePost.image = imageCaptured
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        self.present(pushAlertCameraLibrary(), animated: true, completion: nil)
    }
    @IBAction func publishAction(_ sender: Any) {
        isReadyToPublish = (sender as! UISwitch).isOn
    }

    @IBAction func savePostInCloud(_ sender: Any) {
        // preparado para implementar codigo que persita en el cloud 
        
        guard let tit = titlePostTxt.text else {
            return
        }
        
        guard let desc = textPostTxt.text else {
            return
        }
        
        if titlePostTxt.text != "" && textPostTxt.text != "" {
            let key = newsRef.child("new").childByAutoId().key
            
            let new = ["title": tit as String,
                       "desc" : desc as String,
                       "author": userAuth,
                       "publish": "false",
                       "date": NSDate().description,
                       "rating": Double(0)
                ] as [String : Any]
            
            let recordInFB = ["\(key)" : new]
            
            newsRef.child("new").updateChildValues(recordInFB)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - funciones para la camara
    internal func pushAlertCameraLibrary() -> UIAlertController {
        let actionSheet = UIAlertController(title: NSLocalizedString("Selecciona la fuente de la imagen", comment: ""), message: NSLocalizedString("", comment: ""), preferredStyle: .actionSheet)
        
        let libraryBtn = UIAlertAction(title: NSLocalizedString("Usar la libreria", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.photoLibrary)
            
        }
        let cameraBtn = UIAlertAction(title: NSLocalizedString("Usar la camara", comment: ""), style: .default) { (action) in
            self.takePictureFromCameraOrLibrary(.camera)
            
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(libraryBtn)
        actionSheet.addAction(cameraBtn)
        actionSheet.addAction(cancel)
        
        return actionSheet
    }
    
    internal func takePictureFromCameraOrLibrary(_ source: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        switch source {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                picker.sourceType = UIImagePickerControllerSourceType.camera
            } else {
                return
            }
        case .photoLibrary:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        case .savedPhotosAlbum:
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        self.present(picker, animated: true, completion: nil)
    }

}

// MARK: - Delegado del imagepicker
extension NewPostController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageCaptured = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        self.dismiss(animated: false, completion: {
        })
    }
    
}












