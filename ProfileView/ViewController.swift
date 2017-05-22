//
//  ViewController.swift
//  ProfileView
//
//  Created by User on 5/8/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //in SortCell, when cell is clicked.
    enum State {
        case male
        case female
        case id
        case ageAsceding
        case ageDesceding
        case nameAsceding
        case nameDesceding
        case clear
        case delete
    }
    var state = State.clear
    
    @IBOutlet weak var profileTable: UITableView!
    @IBOutlet weak var sortTable: UITableView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var add: Bool = false
    
    //Firebase initialize
    var profiles: [Profile] = [Profile]()
    var firebase: FIRDatabaseReference!
    var sortArray: [String] = ["Male", "Femal","id", "Age-ascend", "Age-descend", "Name-ascend", "Name-descend", "default", "Delete"]
    var flag: Bool = true
    var first: Bool = true
    
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    var number: Int = Int()
    
    //Sort Arrays.
    var idArray: [Profile] = [Profile]()
    var nameArray: [Profile] = [Profile]()
    var nameArray1: [Profile] = [Profile]()
    var ageArray: [Profile] = [Profile]()
    var ageArray1: [Profile] = [Profile]()
    var maleArray: [Profile] = [Profile]()
    var femalArray: [Profile] = [Profile]()
    
    //initialization String.
    var maleString: String? = nil
    var femaleString: String? = nil
    var maleString1: String? = nil
    var femaleString1: String? = nil
    var redString: String? = nil
    var blueString: String? = nil
    var greenString: String? = nil
    var yellowString: String? = nil
    var grownString: String? = nil
    var brownString: String? = nil
    var orangeString: String? = nil
    var whiteString: String? = nil
    var empty: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        // Hide UserTable
        self.sortTable.isHidden = true
        self.sortTable.layer.cornerRadius = 8.0
        self.sortTable.register(UITableViewCell.self, forCellReuseIdentifier: "sort")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        state = .clear
        self.DownloadingFromFirebase()
    }
    
    func DownloadingFromFirebase() {
        self.addButton.isEnabled = false
        self.sortButton.isEnabled = false
        
        self.progressBarDisplayer(msg: "Downloading Profile", true)
        //Downloading from Firebase.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        firebase = FIRDatabase.database().reference()
        
        firebase.child("profile").observe(.value, with: { snapshot in
            self.profiles.removeAll()
            self.maleArray.removeAll()
            self.femalArray.removeAll()
            self.ageArray.removeAll()
            self.ageArray1.removeAll()
            self.nameArray.removeAll()
            self.nameArray1.removeAll()
            self.idArray.removeAll()
            
            for item in snapshot.children {
                let child = item as! FIRDataSnapshot
                let dict = child.value as! NSDictionary
                
                let profile = Profile(dictionary: dict)
                self.profiles.append(profile)
            }
            
            //Sort ID.
            var idSort = [Int]()
            for item in self.profiles {
                if let num = Int(item.id) {
                    idSort.append(num)
                }
                
            }
            idSort = idSort.sorted() {$0 < $1 }//descending
            for item1 in 0 ..< idSort.count {
                for item2 in 0 ..< idSort.count {
                    if idSort[item1] == Int(self.profiles[item2].id) {
                        self.idArray.append(self.profiles[item2])
                    }
                }
            }
            print("id count is \(self.idArray.count)")
            
            //Sort Name.- asceding
            var nameSort = [String]()
            for item in self.profiles {
                nameSort.append(item.name)
            }
            nameSort = nameSort.sorted() { $0 < $1 }//ascending
            for item1 in 0 ..< nameSort.count {
                for item2 in 0 ..< nameSort.count {
                    if nameSort[item1] == self.profiles[item2].name {
                        self.nameArray.append(self.profiles[item2])
                    }
                }
            }
            
            //Sort Name. - desceding.
            var nameSort1 = [String]()
            for item in self.profiles {
                nameSort1.append(item.name)
            }
            nameSort1 = nameSort1.sorted() { $0 > $1 }//ascending
            for item1 in 0 ..< nameSort1.count {
                for item2 in 0 ..< nameSort1.count {
                    if nameSort1[item1] == self.profiles[item2].name {
                        self.nameArray1.append(self.profiles[item2])
                    }
                }
            }
            
            
            //Sort Age. - asceding
            var ageSort = [Int]()
            for item in self.profiles {
                if let num = Int(item.age) {
                    ageSort.append(num)
                }
                
            }
            ageSort = ageSort.sorted() {$0 < $1 }
            for item1 in 0 ..< ageSort.count {
                for item2 in 0 ..< ageSort.count {
                    if ageSort[item1] == Int(self.profiles[item2].age) {
                        self.ageArray.append(self.profiles[item2])
                    }
                }
            }
            
            //Sort Age. - desceding.
            var ageSort1 = [Int]()
            for item in self.profiles {
                if let num = Int(item.age) {
                    ageSort1.append(num)
                }
                
            }
            ageSort1 = ageSort1.sorted() {$0 > $1 }
            for item1 in 0 ..< ageSort1.count {
                for item2 in 0 ..< ageSort1.count {
                    if ageSort1[item1] == Int(self.profiles[item2].age) {
                        self.ageArray1.append(self.profiles[item2])
                    }
                }
            }
            
            
            //Sort Male or Female.
            self.maleArray = [Profile]()
            self.femalArray = [Profile]()
            for item in self.profiles {
                print("gender is \(item.gender)")
                self.maleString = "  Male"
                self.femaleString = "  Female"
                if item.gender == self.maleString! {
                    self.maleArray.append(item)
                }
                if item.gender == self.femaleString! {
                    self.femalArray.append(item)
                    print("item.gender is \(item.gender)")
                }
            }
            
            self.profileTable.reloadData()
            self.messageFrame.removeFromSuperview()
            self.addButton.isEnabled = true
            self.sortButton.isEnabled = true
        })
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //showing progressView
    func progressBarDisplayer(msg:String, _ indicator:Bool ) {
        print(msg)
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 245, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.white
        if self.add == false {
            messageFrame = UIView(frame: CGRect(x: view.frame.midX - 100, y: view.frame.midY - 25 , width: 215, height: 50))
        }else {
            messageFrame = UIView(frame: CGRect(x: view.frame.midX - 100, y: view.frame.midY - 25 , width: 150, height: 50))
        }
        
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.5)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        if self.add == false {
            view.addSubview(messageFrame)
        }else {
            self.profileTable.addSubview(messageFrame)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //segue method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "profile1" {
            //self.progressBarDisplayer(msg: "Loading...", true)
            let profile = segue.destination as! ProfileViewController
            profile.edit = false
            profile.ProfileArray = self.profiles
        }else if segue.identifier == "profile2" {
            
            let profile = segue.destination as! ProfileViewController
            switch state {
            case .male :
                profile.Profiles = maleArray[self.number]
                profile.edit = true
                profile.selectID = maleArray[self.number].id
            case .female :
                profile.Profiles = femalArray[self.number]
                profile.edit = true
                profile.selectID = femalArray[self.number].id
            case .id:
                profile.Profiles = idArray[self.number]
                profile.edit = true
                profile.selectID = idArray[self.number].id
            case .ageAsceding :
                profile.Profiles = ageArray[self.number]
                profile.edit = true
                profile.selectID = ageArray[self.number].id
            case .ageDesceding :
                profile.Profiles = ageArray1[self.number]
                profile.edit = true
                profile.selectID = ageArray1[self.number].id
            case .nameAsceding :
                profile.Profiles = nameArray[self.number]
                profile.edit = true
                profile.selectID = nameArray[self.number].id
            case .nameDesceding :
                profile.Profiles = nameArray1[self.number]
                profile.edit = true
                profile.selectID = nameArray1[self.number].id
            case .clear :
                profile.Profiles = idArray[self.number]
                profile.edit = true
                profile.selectID = idArray[self.number].id
                
            case .delete :
                break
            }
        }
        
    }
    
    //Add Profile
    @IBAction func AddProfile(_ sender: UIBarButtonItem) {
        self.add = true
        self.progressBarDisplayer(msg: "Loading...", true)
        self.performSegue(withIdentifier: "profile1", sender: self)
        messageFrame.removeFromSuperview()
        self.add = false
    }
    
    //click sortButon for sort tableView
    @IBAction func SortProfile(_ sender: UIBarButtonItem) {
        if flag {
            self.flag = false
            UIView.transition(with: self.sortTable, duration: 0.5, options: .transitionCurlDown, animations: { self.sortTable.isHidden = false }, completion: nil)
        } else {
            self.flag = true
            UIView.transition(with: self.sortTable, duration: 0.5, options: .transitionCurlUp, animations: { self.sortTable.isHidden = true }, completion: nil)
        }
    }
    
    //making circle image
    func CircleImage(profileImage: UIImageView) {
        // Circle images
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.layer.borderWidth = 0.5
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.clipsToBounds = true
        
    }
    
    //tableview delegate method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == profileTable {
            switch state {
            case .male :
                return maleArray.count
                
            case .female :
                return femalArray.count
            case .id:
                return idArray.count
                
            case .ageAsceding :
                return ageArray.count
                
            case .ageDesceding :
                return ageArray1.count
                
            case .nameAsceding :
                return nameArray.count
                
            case .nameDesceding :
                return nameArray1.count
                
            case .clear :
                return idArray.count
                
            case .delete :
                return 0
            }
        }else {
            return sortArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == profileTable {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "profile", for: indexPath) as! ProfileCellTableViewCell
            var profile: Profile = Profile()
            switch state {
            case .male :
                profile = maleArray[indexPath.row]
            case .female :
                profile = femalArray[indexPath.row]
            case .id:
                profile = idArray[indexPath.row]
            case .ageAsceding :
                profile = ageArray[indexPath.row]
            case .ageDesceding :
                profile = ageArray1[indexPath.row]
            case .nameAsceding :
                profile = nameArray[indexPath.row]
            case .nameDesceding :
                profile = nameArray1[indexPath.row]
            case .clear :
                profile = idArray[indexPath.row]
            case .delete :
                break
            }
            
            cell.profileImage.image = profile.image
            self.CircleImage(profileImage: cell.profileImage!)
            
            cell.roundView.backgroundColor = UIColor.clear
            
            cell.ID.text! = profile.id
            cell.Name.text! = profile.name
            cell.Age.text! = profile.age
            cell.Gender.text! = profile.gender
            cell.hobby.text! = profile.hobby
            
            //Default cell background Color.
            self.maleString1 = "  Male"
            self.femaleString1 = "  Female"
            self.empty = ""
            
            if cell.Gender.text == self.maleString1 {
                cell.backgroundColor = UIColor.blue
            }
            if cell.Gender.text == self.femaleString1 {
                cell.backgroundColor = UIColor.green
            }
            print("Profile.bgColor is\(profile.bgColor)")
            
            //initialize string.      //["Red","Blue", "Green", "Yellow", "Grown", "Brown", "Orange", "White"]
            self.blueString = "  Blue"
            self.brownString = "  Brown"
            self.redString = "  Red"
            self.greenString = "  Green"
            self.grownString = "  Grown"
            self.orangeString = "  Orange"
            self.yellowString = "  Yellow"
            self.whiteString = "  White"
            if profile.bgColor == self.redString {
                cell.backgroundColor = UIColor.red
            }else if profile.bgColor == self.blueString {
                cell.backgroundColor = UIColor.blue
            }else if profile.bgColor == self.greenString {
                cell.backgroundColor = UIColor.green
            }else if profile.bgColor == self.yellowString {
                cell.backgroundColor = UIColor.yellow
            }else if profile.bgColor == self.orangeString {
                cell.backgroundColor = UIColor.orange
            }else if profile.bgColor == self.whiteString {
                cell.backgroundColor = UIColor.white
            }else if profile.bgColor == self.brownString {
                cell.backgroundColor = UIColor.brown
            }
            return cell
        }else {
            // SortTable configure.
            let cell = tableView.dequeueReusableCell(withIdentifier: "sort", for: indexPath)
            
            cell.textLabel?.text = sortArray[indexPath.row]
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.layer.backgroundColor = UIColor.clear.cgColor
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.add = true
        self.progressBarDisplayer(msg: "Loading...", true)
        if tableView == self.sortTable {
            
            if indexPath.row == 0 {
                state = .male
                self.profileTable.reloadData()
                
            }else if indexPath.row == 1 {
                state = .female
                self.profileTable.reloadData()
            }else if indexPath.row == 2 {
                state = .id
                self.profileTable.reloadData()
            }else if indexPath.row == 3 {
                state = .ageAsceding
                self.profileTable.reloadData()
            }else if indexPath.row == 4 {
                state = .ageDesceding
                self.profileTable.reloadData()
            }else if indexPath.row == 5 {
                state = .nameAsceding
                self.profileTable.reloadData()
            }else if indexPath.row == 6 {
                state = .nameDesceding
                self.profileTable.reloadData()
            }
            else if indexPath.row == 7 {
                state = .clear
                self.profileTable.reloadData()
            }else if indexPath.row == 8 {
                state = .delete
                for item in profiles {
                    firebase.child("profile").child(item.id).removeValue()
                }
                self.profiles.removeAll()
                self.maleArray.removeAll()
                self.femalArray.removeAll()
                self.ageArray.removeAll()
                self.nameArray.removeAll()
                self.idArray.removeAll()
                self.profileTable.reloadData()
                
            }
            self.flag = true
            UIView.transition(with: self.sortTable, duration: 0.5, options: .transitionCurlUp, animations: { self.sortTable.isHidden = true }, completion: nil)
            
        }else {
            
            let indexPath = tableView.indexPathForSelectedRow
            self.number = (indexPath?.row)!
            self.performSegue(withIdentifier: "profile2", sender: self)
            
        }
        messageFrame.removeFromSuperview()
        self.add = false
    }
}


