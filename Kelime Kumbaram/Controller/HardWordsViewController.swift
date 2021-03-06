//
//  ViewController.swift
//  23
//
//  Created by ibrahim uysal on 2.12.2021.
//

import UIKit
import CoreData

class HardWordsViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startButton2: UIButton!
    @IBOutlet weak var startButton3: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    
    var wordBrain = WordBrain()
    var HardItemArray: [HardItem] { return wordBrain.hardItemArray }
    var textForLabel = ""
    var userWordCount = ""
    var numberForAlert = 0
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Zor Kelimeler"
        setupTableView()
        setupGradientBackground()
        setupExerciseButtons()
        setupCornerRadius()
        setupNavigationBar()
        numberForAlert = HardItemArray.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        wordBrain.loadHardItemArray()
        showAlert(HardItemArray.count)
        updateView()
        tableView.reloadData()
    }
    
    //MARK: - IBAction

    @IBAction func startPressed(_ sender: UIButton) {
        UserDefaults.standard.set(1, forKey: "startPressed")
        startButton.pulstate()
        check2Items()
    }
    
    @IBAction func start2Pressed(_ sender: UIButton) {
        UserDefaults.standard.set(2, forKey: "startPressed")
        startButton2.pulstate()
        check2Items()
    }
    
    @IBAction func start3Pressed(_ sender: UIButton) {
        UserDefaults.standard.set(3, forKey: "startPressed")
        startButton3.pulstate()
        
        //0 is true, 1 is false
        if UserDefaults.standard.integer(forKey: "playSound") == 0 {
            check2Items()
        } else {
            let alert = UIAlertController(title: "Bu al????t??rmay?? ba??latmak i??in \"Kelime dinle\" ??zelli??ini aktif etmeniz gerekir.", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Tamam", style: .default) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .right:
            self.navigationController?.popToRootViewController(animated: true)
            break
        default: break
        }
    }
    
    //MARK: - Other Functions
    
    func updateView(){
            emptyView.updateViewVisibility(true)
            UIView.transition(with: emptyView, duration: 0.6,
                              options: .transitionCrossDissolve,
                              animations: {
                                let newConstraint2 = self.stackViewConstraint.constraintWithMultiplier(0.2)
                                self.stackViewConstraint.isActive = false
                                self.view.addConstraint(newConstraint2)
                                self.view.layoutIfNeeded()
                                self.stackViewConstraint = newConstraint2
                          })
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WordCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
    }
    
    func setupGradientBackground(){
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor(named: "yellowColor")!.cgColor, UIColor(named: "yellowColorBottom")!.cgColor]
        mainView.layer.insertSublayer(gradient, at: 0)
    }
    
    func setupExerciseButtonImage(_ uibutton: UIButton, imageName: String, width: CGFloat, height: CGFloat){
        uibutton.setImage(imageRenderer(imageName: imageName, width: width+textSize, height: height+textSize), for: .normal)
    }
    
    func setupExerciseButtonShadow(_ uibutton: UIButton){
        uibutton.layer.shadowColor = UIColor(red: 0.16, green: 0.19, blue: 0.28, alpha: 1.00).cgColor
        uibutton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        uibutton.layer.shadowOpacity = 1.0
        uibutton.layer.shadowRadius = 0.0
        uibutton.layer.masksToBounds = false
    }
    
    func setupExerciseButtons(){
        setupExerciseButtonImage(startButton, imageName: "firstStartImage", width: 30, height: 15)
        setupExerciseButtonImage(startButton2, imageName: "secondStartImage", width: 30, height: 15)
        setupExerciseButtonImage(startButton3, imageName: "thirdStartImage", width: 30, height: 15)
        
        setupExerciseButtonShadow(startButton)
        setupExerciseButtonShadow(startButton2)
        setupExerciseButtonShadow(startButton3)
        
        expandButton.isHidden = true
    }
    
    func setupCornerRadius(){
        startButton.setButtonCornerRadius(10)
        startButton2.setButtonCornerRadius(10)
        startButton3.setButtonCornerRadius(10)
        expandButton.setButtonCornerRadius(10)
        tableView.setViewCornerRadius(10)
    }
    
    func setupNavigationBar(){
        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func showAlert(_ hardItemArrayCount: Int){
        if hardItemArrayCount <= 0 {
            let alert = UIAlertController(title: "Burada hen??z bir ??ey yok", message: "Kumbaram sayfas??ndaki al????t??rmalarda bir kelimeyi yanl???? cevaplad??????n??zda o kelime bu sayfaya eklenir. Kelimenin bu sayfadan silinmesi i??in 5 defa do??ru cevaplanmas?? gerekir.", preferredStyle: .alert)
                            
            let action = UIAlertAction(title: "Tamam", style: .default) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func imageRenderer(imageName: String, width: CGFloat, height: CGFloat) -> UIImage{
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: height)).image { _ in
            UIImage(named: imageName)?.draw(in: CGRect(x: 0, y: 0, width: width, height: height)) }
    }
    
    func check2Items() {
        // 2 words required
        if UserDefaults.standard.integer(forKey: "hardWordsCount") < 2 {
            let alert = UIAlertController(title: "En az iki kelime gereklidir", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Tamam", style: .default) { (action) in
                self.navigationController?.popToRootViewController(animated: true)
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            let when = DispatchTime.now() + 0.1
            DispatchQueue.main.asyncAfter(deadline: when){
                self.performSegue(withIdentifier: "goToQuiz", sender: self)
            }
        }
    }
    
}
    //MARK: - Show Words

extension HardWordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HardItemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! WordCell
        updateCellLabelTextSize(cell)
        updateCellLabelTextColor(cell)
        updateCellLabelText(cell, indexPath.row)
        return cell
    }
    
    func updateCellLabelTextSize(_ cell: WordCell){
        cell.updateLabelTextSize(cell.engLabel, textSize)
        cell.updateLabelTextSize(cell.trLabel, textSize)
        cell.updateLabelTextSize(cell.numberLabel, textSize-4)
    }
    
    func updateCellLabelTextColor(_ cell: WordCell){
        cell.numberLabel.textColor = .darkGray
    }
    
    func updateCellLabelText(_ cell: WordCell, _ i: Int){
        cell.engLabel.text = HardItemArray[i].eng
        cell.trLabel.text = HardItemArray[i].tr
    }
    
}

extension HardWordsViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
