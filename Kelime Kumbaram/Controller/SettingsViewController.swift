//
//  SettingsViewController.swift
//  Twenty Three
//
//  Created by ibrahim uysal on 13.03.2022.
//

import UIKit
import AVFoundation
import CoreData

class SettingsViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var playSoundView: UIView!
    @IBOutlet weak var fontView: UIView!
    @IBOutlet weak var appSoundView: UIView!
    @IBOutlet weak var appSoundText: UILabel!
    @IBOutlet weak var soundSpeedView: UIView!
    @IBOutlet weak var x2view: UIView!
    
    @IBOutlet weak var x2text: UILabel!
    @IBOutlet weak var x2time: UILabel!
    @IBOutlet weak var settingsText: UILabel!
    @IBOutlet weak var wordSoundText: UILabel!
    @IBOutlet weak var soundSpeedText: UILabel!
    @IBOutlet weak var sizeText: UILabel!
    
    @IBOutlet weak var switchWordSound: UISwitch!
    @IBOutlet weak var switchAppSound: UISwitch!
    
    @IBOutlet weak var textSegmentedControl: UISegmentedControl!
    @IBOutlet weak var soundSpeedSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var x2button: UIButton!
    @IBOutlet weak var soundSpeedButton: UIButton!
    
    @IBOutlet weak var viewConstraint: NSLayoutConstraint!
    
    //MARK: - Variable
    
    var selectedSpeed = 0.0
    var onViewWillDisappear: (()->())?
    var soundImageName = ""
    var soundImageSize = 30
    var textSize : CGFloat = 0.0
    
    static let synth = AVSpeechSynthesizer()
    
    let hours = ["00:00 - 01:00",
                 "01:00 - 02:00",
                 "02:00 - 03:00",
                 "03:00 - 04:00",
                 "04:00 - 05:00",
                 "05:00 - 06:00",
                 "06:00 - 07:00",
                 "07:00 - 08:00",
                 "08:00 - 09:00",
                 "09:00 - 10:00",
                 "10:00 - 11:00",
                 "11:00 - 12:00",
                 "12:00 - 13:00",
                 "13:00 - 14:00",
                 "14:00 - 15:00",
                 "15:00 - 16:00",
                 "16:00 - 17:00",
                 "17:00 - 18:00",
                 "18:00 - 19:00",
                 "19:00 - 20:00",
                 "20:00 - 21:00",
                 "21:00 - 22:00",
                 "22:00 - 23:00",
                 "23:00 - 00:00"]
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        assignSoundImageName()
        updateTextSize()
        setupCornerRadius()
        setupDefaults()
        setupButton(soundSpeedButton)
    }
    
    //MARK: - prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goPicker" {
            if segue.destination is X2ViewController {
                (segue.destination as? X2ViewController)?.onViewWillDisappear = { (id) -> Void in
                    self.x2time.text = self.hours[id]
                    self.onViewWillDisappear?()// trigger function in ViewController
                }
            }
        }
    }
    
    //MARK: - IBAction

    @IBAction func wordSoundChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "playSound")
            changeViewState(soundSpeedView, alpha: 1, isUserInteraction: true)
        } else {
            UserDefaults.standard.set(1, forKey: "playSound")
            changeViewState(soundSpeedView, alpha: 0.6, isUserInteraction: false)
        }
    }
    
    @IBAction func appSoundChanged(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set(0, forKey: "playAppSound")
        } else {
            UserDefaults.standard.set(1, forKey: "playAppSound")
        }
    }
    
    @IBAction func soundSpeedChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(0.3, forKey: "soundSpeed")
            selectedSpeed = 0.3
            break
        case 1:
            UserDefaults.standard.set(0.5, forKey: "soundSpeed")
            selectedSpeed = 0.5
            break
        case 2:
            UserDefaults.standard.set(0.7, forKey: "soundSpeed")
            selectedSpeed = 0.7
            break
        default: break
        }
        soundSpeedButton.flash()
        playSound()
    }
    
    
    @IBAction func speakerButtonPressed(_ sender: UIButton) {
        soundSpeedButton.flash()
        playSound()
    }
    
    @IBAction func textSizeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UserDefaults.standard.set(9, forKey: "textSize")
            break
        case 1:
            UserDefaults.standard.set(11, forKey: "textSize")
            break
        case 2:
            UserDefaults.standard.set(13, forKey: "textSize")
            break
        case 3:
            UserDefaults.standard.set(15, forKey: "textSize")
            break
        case 4:
            UserDefaults.standard.set(17, forKey: "textSize")
            break
        case 5:
            UserDefaults.standard.set(19, forKey: "textSize")
            break
        default:
            UserDefaults.standard.set(21, forKey: "textSize")
        }
        updateTextSize()
    }
    
    @IBAction func topViewPressed(_ sender: UIButton) {
        dismissView()
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        dismissView()
    }
    
    //MARK: - Other Functions
    
    func assignSoundImageName(){
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            soundImageName = "soundBlack"
            break
        case .dark:
            soundImageName = "soundLeft"
            break
        default: break
        }
    }
    
    func setupButton(_ button: UIButton){
        button.setImage(UIGraphicsImageRenderer(size: CGSize(width: soundImageSize, height: soundImageSize)).image { _ in
            UIImage(named: soundImageName)?.draw(in: CGRect(x: 0, y: 0, width: soundImageSize, height: soundImageSize)) }, for: .normal)
    }
    
    func setupCornerRadius(){
        playSoundView.layer.cornerRadius = 8
        fontView.layer.cornerRadius = 8
        x2view.layer.cornerRadius = 8
        appSoundView.layer.cornerRadius = 8
        soundSpeedView.layer.cornerRadius = 8
        
        settingsView.clipsToBounds = true
        settingsView.layer.cornerRadius = 16
        settingsView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    func setupDefaults(){
        
        if UserDefaults.standard.integer(forKey: "playSound") == 1 {
            switchWordSound.isOn = false
            changeViewState(soundSpeedView, alpha: 0.6, isUserInteraction: false)
        } else {
            switchWordSound.isOn = true
            changeViewState(soundSpeedView, alpha: 1, isUserInteraction: true)
        }
        
        if UserDefaults.standard.integer(forKey: "playAppSound") == 1 {
            switchAppSound.isOn = false
        } else {
            switchAppSound.isOn = true
        }
        
        if UserDefaults.standard.integer(forKey: "textSize") == 0 {
            UserDefaults.standard.set(15, forKey: "textSize")
            UserDefaults.standard.set(0.3, forKey: "soundSpeed")
        }
        
        x2time.text = hours[UserDefaults.standard.integer(forKey: "userSelectedHour")]
        
        selectedSpeed = UserDefaults.standard.double(forKey: "soundSpeed")
        switch selectedSpeed {
        case 0.3:
            soundSpeedSegmentedControl.selectedSegmentIndex = 0
            break
        case 0.5:
            soundSpeedSegmentedControl.selectedSegmentIndex = 1
            break
        case 0.7:
            soundSpeedSegmentedControl.selectedSegmentIndex = 2
            break
        default: break
        }
        
        switch UserDefaults.standard.integer(forKey: "textSize") {
        case 9:
            textSegmentedControl.selectedSegmentIndex = 0
            break
        case 11:
            textSegmentedControl.selectedSegmentIndex = 1
            break
        case 13:
            textSegmentedControl.selectedSegmentIndex = 2
            break
        case 15:
            textSegmentedControl.selectedSegmentIndex = 3
            break
        case 17:
            textSegmentedControl.selectedSegmentIndex = 4
            break
        case 19:
            textSegmentedControl.selectedSegmentIndex = 5
            break
        case 21:
            textSegmentedControl.selectedSegmentIndex = 6
            break
        default: break
        }
    }

    func updateTextSize(){
        
        textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))
        
        updateLabelTextSize(settingsText)
        updateLabelTextSize(wordSoundText)
        updateLabelTextSize(sizeText)
        updateLabelTextSize(x2text)
        updateLabelTextSize(x2time)
        updateLabelTextSize(appSoundText)
        updateLabelTextSize(soundSpeedText)
  
        updateSegmentedControlTextSize(textSegmentedControl)
        updateSegmentedControlTextSize(soundSpeedSegmentedControl)
    }
    
    func updateSegmentedControlTextSize(_ segmentedControl: UISegmentedControl){
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(named: "cellTextColor")!, .font: UIFont.systemFont(ofSize: textSize),], for: .normal)
    }
    
    func updateLabelTextSize(_ label: UILabel){
        label.font = label.font.withSize(textSize)
    }
    
    func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func playSound(){
        let u = AVSpeechUtterance(string: "how are you?")
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        u.rate = Float(selectedSpeed)
        SettingsViewController.synth.speak(u)
    }
    
    func changeViewState(_ uiview: UIView, alpha a: CGFloat, isUserInteraction bool: Bool){
        
        UIView.transition(with: uiview, duration: 0.4,
                          options: (a < 1 ? .transitionFlipFromTop : .transitionFlipFromBottom),
                          animations: {
            uiview.isUserInteractionEnabled = bool
            uiview.alpha = a
        })
        
    }
    
    override func updateViewConstraints() {
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 16.0)
        super.updateViewConstraints()
    }

}
