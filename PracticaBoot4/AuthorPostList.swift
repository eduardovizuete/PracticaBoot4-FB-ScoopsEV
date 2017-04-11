//
//  AuthorPostList.swift
//  PracticaBoot4
//
//  Created by Juan Antonio Martin Noguera on 23/03/2017.
//  Copyright © 2017 COM. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AuthorPostList: UITableViewController {

    let cellIdentifier = "POSTAUTOR"
    
    //var model = ["test1", "test2"]
    var model : [New] = []
    
    let newsRef = FIRDatabase.database().reference().child("News")
    
    var handle : FIRAuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // autenticacion con email
        showUserLoginDialog(actionCmd: login, userAction: .toLogin)
        
        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            print("El mail del usuario logueado es \(String(describing: user?.email))")
        })
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = model[indexPath.row].title
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let publish = UITableViewRowAction(style: .normal, title: "Publicar") { (action, indexPath) in
            // Codigo para publicar el post
        }
        publish.backgroundColor = UIColor.green
        let deleteRow = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            // codigo para eliminar
        }
        return [publish, deleteRow]
    }

   
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: Metodo para capturar las credenciales del usuario
    
    enum ActionUser: String {
        case toLogin = "Login with email"
        case toSignIn = "Registrar nuevo usuario"
    }
    
    typealias actionUserCmd = (_ : String, _ : String) -> Void
    
    func showUserLoginDialog(actionCmd: @escaping actionUserCmd, userAction: ActionUser) {
        
        let alertController = UIAlertController(title: "FireBase Practica", message: userAction.rawValue, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: userAction.rawValue,
                                                style: .default, handler: { (action) in
                                                    let eMailTxt = (alertController.textFields?[0])! as UITextField
                                                    let passTxt = (alertController.textFields?[1])! as UITextField
                                                    
                                                    if (eMailTxt.text?.isEmpty)!, (passTxt.text?.isEmpty)! {
                                                        // no continuar y lanzar error
                                                        
                                                    } else {
                                                        actionCmd(eMailTxt.text!,
                                                                  passTxt.text!)
                                                    }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        
        alertController.addTextField { (txtField) in
            txtField.placeholder = "Por favor escriba su email"
            txtField.textAlignment = .natural
        }
        
        alertController.addTextField { (txtField) in
            txtField.placeholder = "su password"
            txtField.textAlignment = .natural
            txtField.isSecureTextEntry = true
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func login(_ name: String, andPass pass: String) {
        FIRAuth.auth()?.signIn(withEmail: name, password: pass, completion: { (user, error) in
            
            if let _ = error {
                print("tenemos un error -> \(String(describing: user?.email))")
                
                FIRAuth.auth()?.createUser(withEmail: name, password: pass, completion: { (user, error) in
                    if let _ = error {
                        print("tenemos un error -> \(String(describing: user?.email)) \(error?.localizedDescription)")
                        return
                    }
                    
                    print("\(String(describing: user))")
                })
                
                return
            }
            print("user: \(String(describing: user?.email!))")
        })
        
        model = []
        
        newsRef.observe(FIRDataEventType.childAdded, with: {(snap) in
            for myNewfb in snap.children {
                let myNew = New(snap: myNewfb as? FIRDataSnapshot)
                if myNew.author == name {
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

}
