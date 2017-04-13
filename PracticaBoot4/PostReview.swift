//
//  PostReview.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase

class PostReview: UIViewController {
    
    var model = New()
    
    let newsRef = FIRDatabase.database().reference().child("News")

    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var imagePost: UIImageView!
    @IBOutlet weak var postTxt: UITextField!
    @IBOutlet weak var titleTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        titleTxt.text = model.title
        postTxt.text = model.desc
        rateSlider.setValue(Float(model.rating), animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rateAction(_ sender: Any) {
        print("\((sender as! UISlider).value)")
    
    }

    @IBAction func ratePost(_ sender: Any) {
        // Codigo para valorar el post
        let key = model.key
        
        let new = ["title": model.title,
                   "desc" : model.desc,
                   "author": model.author,
                   "publish": model.publish,
                   "date": model.date,
                   "rating": Double(rateSlider.value)
            ] as [String : Any]
        
        let recordInFB = ["\(key)" : new]
        
        self.newsRef.child("new").updateChildValues(recordInFB)
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
