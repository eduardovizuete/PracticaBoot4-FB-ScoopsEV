//
//  New.swift
//  PracticaBoot4
//
//  Created by usuario on 4/6/17.
//  Copyright © 2017 COM. All rights reserved.
//

import Foundation
import Firebase

class New: NSObject {
    
    var title       : String
    var desc        : String
    var author      : String
    var publish     : String
    var date        : String
    var refInCloud  : FIRDatabaseReference?
    
    init(title: String, desc: String, author: String, publish: String, date: String) {
        self.title = title
        self.desc = desc
        self.author = author
        self.publish = publish
        self.date = date
        self.refInCloud = nil
    }
    
    init(snap: FIRDataSnapshot?) {
        self.refInCloud = snap?.ref
        desc = (snap?.value as? [String: Any])?["desc"] as! String
        title = (snap?.value as? [String: Any])?["title"] as! String
        author = (snap?.value as? [String: Any])?["author"] as! String
        publish = (snap?.value as? [String: Any])?["publish"] as! String
        date = (snap?.value as? [String: Any])?["date"] as! String
    }
    
    convenience override init() {
        self.init(title: "", desc: "", author: "", publish: "", date: "")
    }
    
}

