//
//  AddController.swift
//  Twenty Three
//
//  Created by ibrahim uysal on 1.02.2022.
//

import UIKit
import AVFoundation
import CoreData

class AddViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet var firstView: UIView!
    @IBOutlet weak var darkView: UIView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var engTxtField: UITextField!
    @IBOutlet weak var trTxtField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var coinButton: UIButton!
    
    //MARK: - Variables
    
    var wordBrain = WordBrain()
    var itemArray = [Item]()
    var player: AVAudioPlayer!
    var tapGesture = UITapGestureRecognizer()
    var updateWordsPage: (()->())?
    var onViewWillDisappear: (()->())?
    var goEdit = 0
    var editIndex = 0
    var userWordCountInt = 0
    var textForLabel = ""
    var userWordCount = ""
    var userWordCountIntVariable = UserDefaults.standard.integer(forKey: "userWordCount") //fix userdefaults slow problem
    let coinImage = UIImage(named: "coin.png")!
    let emptyImage = UIImage(named: "empty.png")!
    let plusImage = UIImage(named: "plus.png")!
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        setupViews()
        setupButtons()
        setupTxtFields()
        checkEditStatus()
        preventInterrupt()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        onViewWillDisappear?()
    }
    
    //MARK: - prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goNewPoint" {
                let destinationVC = segue.destination as! NewPointViewController
                destinationVC.textForLabel = textForLabel
                destinationVC.userWordCount = userWordCount
            }
    }
    
    //MARK: - IBAction
    
    @IBAction func addButtonPressed(_ sender: Any) {
            if engTxtField.text!.count > 0 && trTxtField.text!.count > 0 {
                playMP3("mario")
                if goEdit == 0 {
                    wordBrain.addNewWord(english: engTxtField.text!, meaning: trTxtField.text!)
                    UserDefaults.standard.set(userWordCountIntVariable+1, forKey: "userWordCount")
                    wordBrain.saveWord()
                    userWordCountIntVariable += 1
                    Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(goNewPoint), userInfo: nil, repeats: false)
                } else {
                    itemArray[editIndex].eng = engTxtField.text!
                    itemArray[editIndex].tr = trTxtField.text!
                    Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(dismissView), userInfo: nil, repeats: false)
                }
                
                updateWordsPage?()
                
                trTxtField.text = ""
                engTxtField.text = ""
                engTxtField.becomeFirstResponder()

                flipCoinButton()
            }
    }
    
    @IBAction func topViewPressed(_ sender: UIButton) {
        checkAction()
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        checkAction()
    }
    
    //MARK: - Objc Functions
    
    @objc func flipButton(){
        coinButton.setBackgroundImage(coinImage, for: .normal)
        UIView.transition(with: coinButton, duration: 0.5, options: .transitionFlipFromTop, animations: nil, completion: nil)
    }

    @objc func deleteButtonBackgroundImage(){
        coinButton.deleteBackgroundImage()
    }
    
    @objc func dismissView(){
        firstView.backgroundColor = UIColor.clear
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func animateDown(){
        coinButton.animateDown()
    }
    
    @objc func goNewPoint(){
        let lastPoint = UserDefaults.standard.integer(forKey: "pointForMyWords")
    
        if userWordCountIntVariable >= 100 {
           let newPoint = userWordCountIntVariable/100*2 + 12
            if newPoint - lastPoint > 0 {
                textForLabel = "You will get +\(newPoint-10) points for each correct answer."
                userWordCount = String(userWordCountIntVariable)
                UserDefaults.standard.set(newPoint, forKey: "pointForMyWords")
                performSegue(withIdentifier: "goNewPoint", sender: self)
            }
        } else {
            var newPoint = 0
            if  userWordCountIntVariable >= 10 {
                if userWordCountIntVariable < 50 {
                    newPoint = 11
                } else {
                    newPoint = 12
                }
                if newPoint - lastPoint > 0 {
                    textForLabel = "You will get +\(newPoint-10) points for each correct answer."
                    userWordCount = String(userWordCountIntVariable)
                    UserDefaults.standard.set(newPoint, forKey: "pointForMyWords")
                    performSegue(withIdentifier: "goNewPoint", sender: self)
                }
            }
        }
    }
    
    //MARK: - Other Functions
    
    func checkAction(){
        if engTxtField.text!.count > 0 || trTxtField.text!.count > 0 {
            let alert = UIAlertController(title: "Your changes could not be saved", message: "", preferredStyle: .alert)

            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            
            let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(action)
            alert.addAction(actionCancel)
            
            if goEdit == 1 {
                if engTxtField.text != UserDefaults.standard.string(forKey: "engEdit") ||
                    trTxtField.text != UserDefaults.standard.string(forKey: "trEdit") {
                    present(alert, animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                present(alert, animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func setupViews(){
        firstView.backgroundColor = UIColor(white: 0.1, alpha: 0.4)
        textView.layer.cornerRadius = 12
    }
    
    func setupButtons(){
        setupButton(button: addButton, buttonTitle: "", image: plusImage, imageSize: 23, cornerRadius: 6)
        coinButton.deleteBackgroundImage()
    }
    
    func setupTxtFields(){
        setupTxtField(txtFld: engTxtField, placeholder: "English")
        setupTxtField(txtFld: trTxtField, placeholder: "Meaning")
        engTxtField.becomeFirstResponder()
    }
    
    func setupButton(button: UIButton, buttonTitle: String, image: UIImage=UIImage(), imageSize: Int=0, cornerRadius: Int){
        button.setTitle(buttonTitle, for: .normal)
        button.setImage(imageRenderer(image: image, imageSize: imageSize), for: .normal)
        button.layer.cornerRadius = CGFloat(cornerRadius)
    }
    
    func setupTxtField(txtFld: UITextField, placeholder: String){
        txtFld.delegate = self
        txtFld.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        )
    }
    
    func flipCoinButton(){
        coinButton.setBackgroundImage(coinImage, for: .normal)
        UIView.transition(with: coinButton, duration: 0.2, options: .transitionFlipFromTop, animations: nil, completion: nil)
        Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(flipButton), userInfo: nil, repeats: false)
        Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(animateDown), userInfo: nil, repeats: false)
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(deleteButtonBackgroundImage), userInfo: nil, repeats: false)
    }
    
    func checkEditStatus() {
        if goEdit == 1 {
            engTxtField.text = UserDefaults.standard.string(forKey: "engEdit")
            trTxtField.text = UserDefaults.standard.string(forKey: "trEdit")
            setupButton(button: addButton, buttonTitle: "Save", image: emptyImage, imageSize: 0, cornerRadius: 6)
        }
    }
    
    func preventInterrupt(){
        // None of our movies should interrupt system music playback.
            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: .mixWithOthers)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if textField == engTxtField {
                trTxtField.becomeFirstResponder()
            } else {
                engTxtField.becomeFirstResponder()
            }
            return true
    }
    
    func imageRenderer(image: UIImage, imageSize: Int) -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
    }
    
    func playMP3(_ soundName: String) {
        if UserDefaults.standard.integer(forKey: "playAppSound") == 0 {
            let url = Bundle.main.url(forResource: "/sounds/\(soundName)", withExtension: "mp3")
            player = try! AVAudioPlayer(contentsOf: url!)
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
             print(error)
            }
            player.play()
        }
    }
}

