//
//  MainTimeLine.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase

class MainTimeLine: UITableViewController {

    let newsRef = FIRDatabase.database().reference().child("News")
    var model : [New] = []
    var modelSelec = New()
    let cellIdentier = "POSTSCELL"
    var handle : FIRAuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // incluir eventos analiticas
        FIRAnalytics.setScreenName("MainTimeLine Controller", screenClass: "MainTimeLine")
        
        // anonuymous signin
        makeAnonymousLogin()
        
        //addRecordinPosts()

        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            print("El mail del usuario logueado es \(String(describing: user?.email))")
            self.getUserInfo(user)
        })
        
        model = []
        
        newsRef.observe(FIRDataEventType.childAdded, with: {(snap) in
            for myNewfb in snap.children {
                let myNew = New(snap: myNewfb as? FIRDataSnapshot)
                if myNew.publish == "true" {
                    self.model.append(myNew)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
        }

    }
    
    func hadleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.endRefreshing()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentier, for: indexPath)

        cell.textLabel?.text = model[indexPath.row].title

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        modelSelec = model[indexPath.row]
        
        performSegue(withIdentifier: "ShowRatingPost", sender: indexPath)

    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowRatingPost" {
            let vc = segue.destination as! PostReview
            // aqui pasamos el item selecionado
            vc.model = modelSelec
        }
    }

    // MARK: - Utils
    
    
    fileprivate func makeAnonymousLogin() {
        makeLogout()
        
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let _ = error {
                print("Aqui error para anonimo: \(error?.localizedDescription)")
                return
            }
            print("Login usuario anonimo: \(user?.uid)")
        })
    }
    
    // make logout from account
    fileprivate func makeLogout() {
        if let _ = FIRAuth.auth()?.currentUser {
            do {
                // sign out anonymous
                try FIRAuth.auth()?.signOut()
                
                // sign out google provider
                //GIDSignIn.sharedInstance().signOut()
            } catch let error {
                print(error)
            }
        }
    }
    
    func getUserInfo(_ user: FIRUser!) {
        if let _ = user, !user.isAnonymous {
            let uid = user.uid
            print(uid)
            
            let userDisplay = user.displayName
            self.title = userDisplay
    
            //if let picProfile = user.photoURL as URL! {
                // sincronizar con la vista
            //    self.urlPhoto = picProfile
            //}
        }
    }
    
    func addRecordinPosts() {
        
        let key = newsRef.child("new").childByAutoId().key
        
        let new = ["title": "Noticia 1", "desc" : "Desc noticia 1", "author": "autor n1"]
        
        let recordInFB = ["\(key)" : new]
        
        newsRef.child("new").updateChildValues(recordInFB)
    }
}
