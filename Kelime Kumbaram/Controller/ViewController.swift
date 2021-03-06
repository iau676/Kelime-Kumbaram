//
//  ViewController.swift
//  23
//
//  Created by ibrahim uysal on 2.12.2021.
//

import UIKit
import AVFoundation
import CoreData
import UserNotifications

class ViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var levelStackView: UIStackView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var x2view: UIView!
    @IBOutlet weak var x2button: UIButton!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - Variables
    
    var wordBrain = WordBrain()
    var itemArray = [Item]()
    let cp = CircularProgressView(frame: CGRect(x: 10.0, y: 10.0, width: 100.0, height: 100.0))
    let notificationCenter = UNUserNotificationCenter.current()
    
    var goAddPage = 0
    var progressValue:Float = 0.0
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        fixSoundProblemForRealDevice()
        setupFirstLaunch()
        getHour()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        setupCircularProgress()
        check2xTime()
        setupButtons()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        cp.center =  CGPoint(x: super.view.center.x, y:  levelView.center.y)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goSettings" {
            if segue.destination is SettingsViewController {
                (segue.destination as? SettingsViewController)?.onViewWillDisappear = {
                    self.check2xTime()
                }
            }
        }
        
        if segue.identifier == "goWords" {
            let destinationVC = segue.destination as! WordsViewController
            destinationVC.goAddPage = goAddPage
        }
    }
   
    //MARK: - IBAction
    
    @IBAction func greenButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set(1, forKey: "startPressed")
        UserDefaults.standard.set("blue", forKey: "whichButton")
        goAddPage = 1
        greenButton.pulstate()
        viewDidLayoutSubviews()
        goAfter100Milliseconds(identifier: "goWords")
    }
    
    @IBAction func blueButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set("blue", forKey: "whichButton")
        goAddPage = 0
        blueButton.pulstate()
        goAfter100Milliseconds(identifier: "goWords")
    }
    
    @IBAction func yellowButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set("yellow", forKey: "whichButton")
        yellowButton.pulstate()
        goAfter100Milliseconds(identifier: "goHardWords")
    }

    @IBAction func setNotificationFirstTime(_ sender: UIButton) {
        //works after any button pressed
        if UserDefaults.standard.integer(forKey: "setNotificationFirstTime") == 0 {
            setNotification()
            UserDefaults.standard.set(1, forKey: "setNotificationFirstTime")
            print("SET NOT??F??CAT??ON<<")
        }
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "goSettings", sender: self)
    }
    
    //MARK: - Objc Functions
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        let vc = CustomModalViewController()
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
    
    @objc func appendDefaultWords() {
        let defaultWordsCount = wordBrain.defaultWords.count
        
        for index in 0..<defaultWordsCount {
            _ = index // noneed
            wordBrain.addNewWord(english: "\(wordBrain.defaultWords[index].eng)", meaning: "\(wordBrain.defaultWords[index].tr)")
        }
        UserDefaults.standard.set(defaultWordsCount, forKey: "userWordCount")
        wordBrain.saveWord()
     }
    
    //MARK: - Other Functions

    func setupFirstLaunch(){
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (permissionGranted, error) in
            if(!permissionGranted){
                print("Permission Denied")
            }
        }
        
        //version 2.0.1
        if UserDefaults.standard.object(forKey: "2xTime") == nil {
            let calendar = Calendar.current
            let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date())
            UserDefaults.standard.set(twoDaysAgo, forKey: "2xTime")
            UserDefaults.standard.set(23, forKey: "userSelectedHour")
            UserDefaults.standard.set("empty", forKey: "lastEditLabel")
            UserDefaults.standard.set(10, forKey: "pointForMyWords")
            UserDefaults.standard.set(15, forKey: "textSize")
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(appendDefaultWords), userInfo: nil, repeats: false)
        }
    }
    
    func goAfter100Milliseconds(identifier: String){
        let when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when){
            self.performSegue(withIdentifier: identifier, sender: self)
        }
    }
    
    func setupButtons(){
        blueButton.backgroundColor = UIColor(red: 0.11, green: 0.73, blue: 0.92, alpha: 1.00)
        greenButton.backgroundColor = UIColor(red: 0.09, green: 0.75, blue: 0.55, alpha: 1.00)
        yellowButton.backgroundColor = UIColor(red: 1.00, green: 0.75, blue: 0.28, alpha: 1.00)
        
        setupButtonShadow(greenButton, shadowColor: UIColor(red: 0.07, green: 0.60, blue: 0.44, alpha: 1.00))
        setupButtonShadow(blueButton, shadowColor: UIColor(red: 0.07, green: 0.60, blue: 0.75, alpha: 1.00))
        setupButtonShadow(yellowButton, shadowColor: UIColor(red: 1.00, green: 0.66, blue: 0.03, alpha: 1.00))

        greenButton.setButtonCornerRadius(15)
        blueButton.setButtonCornerRadius(15)
        yellowButton.setButtonCornerRadius(15)
 
        greenButton.setImage(imageRenderer(imageName: "new", width: 35, height: 35), for: .normal)
        blueButton.setImage(imageRenderer(imageName: "bank", width: 40, height: 40), for: .normal)
        yellowButton.setImage(imageRenderer(imageName: "hard", width: 35, height: 35), for: .normal)
        settingsButton.setImage(imageRenderer(imageName: "settingsImage", width: 23, height: 23), for: .normal)
    }
    
    func setupButtonShadow(_ button: UIButton, shadowColor: UIColor){
        button.layer.shadowColor = shadowColor.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0.0
        button.layer.masksToBounds = false
    }
    
    func setupNavigationBar(){
        // back button color
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.00)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.00)]
    
        //delete navigation bar background
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func setupCircularProgress(){
        progressValue = wordBrain.calculateLevel()
        levelLabel.text = UserDefaults.standard.string(forKey: "level")
        
        cp.trackColor = UIColor.white
        cp.progressColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 1.0)
        self.view.addSubview(cp)
        cp.setProgressWithAnimation(duration: 1.0, value: progressValue)
        
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        cp.addGestureRecognizer(gesture)
    }

    func setNotification(){
            
            DispatchQueue.main.async
            {
                let title = "2x Saati ????"
                let message = "Bir saat boyunca her do??ru cevap i??in 2x puan kazanacaks??n??z!"
                
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    
                    let date = DateComponents(hour: 23, minute: 44)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
                    let id = UUID().uuidString
                    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
                    
                    self.notificationCenter.removeAllPendingNotificationRequests()
                    
                    self.notificationCenter.add(request) { (error) in
                        if(error != nil)
                        {
                            print("Error " + error.debugDescription)
                            return
                        }
                    }
                    
                    print("id>>\(id)")
                    print("selected new date")
            }
    }
    
    func check2xTime(){
        if UserDefaults.standard.integer(forKey: "lastHour") == UserDefaults.standard.integer(forKey: "userSelectedHour") {
            x2view.isHidden = false
            x2button.pulstatex2()
        } else {
            x2view.isHidden = true
        }
    }
    
    func getHour() {
        UserDefaults.standard.set(Calendar.current.component(.hour, from: Date()), forKey: "lastHour")
        UserDefaults.standard.synchronize()
    }
    
    func imageRenderer(imageName: String, width: CGFloat, height: CGFloat) -> UIImage {
       return UIGraphicsImageRenderer(size: CGSize(width: width, height: height)).image { _ in
            UIImage(named: imageName)?.draw(in: CGRect(x: 0, y: 0, width: width, height: height)) }
    }

    func fixSoundProblemForRealDevice(){
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        } catch {
            assertionFailure("Failed to configure `AVAAudioSession`: \(error.localizedDescription)")
        }
    }

}
