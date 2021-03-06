//
//  CardViewController.swift
//  Twenty Three
//
//  Created by ibrahim uysal on 20.03.2022.
//

import UIKit
import CoreData

class CardViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Variables
    
    var wordBrain = WordBrain()
    var quizCoreDataArray = [AddedList]()
    var itemArray: [Item] { return wordBrain.itemArray }
    var cardCounter = 0
    var questionNumber = 0
    var lastPoint = UserDefaults.standard.integer(forKey: "lastPoint")
    var questionENG = ""
    var questionTR = ""
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        wordBrain.loadItemArray()
        updateText()
    }
    
    //MARK: - prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResult" {
            let destinationVC = segue.destination as! ResultViewController
            destinationVC.cardCounter = cardCounter
            //destinationVC.itemArray = itemArray
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        updateText()
        swipeAnimation()
        tableView.reloadData()
    }
    
    //MARK: - Other Functions
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "WordCell", bundle: nil), forCellReuseIdentifier:"ReusableCell")
        tableView.tableFooterView = UIView()
    }
    
    func updateText(){
        questionNumber = Int.random(in: 0..<itemArray.count)
        questionENG = itemArray[questionNumber].eng ?? "empty"
        questionTR = itemArray[questionNumber].tr ?? "empty"
        cardCounter += 1
        lastPoint += 1
        if cardCounter == 4 { //26
            performSegue(withIdentifier: "goToResult", sender: self)
        } else {
            UserDefaults.standard.set(lastPoint, forKey: "lastPoint")
        }
        self.swipeAnimation()
        self.tableView.reloadData()
    }

    func showAlertForAlreadyAdded(){
        let alert = UIAlertController(title: "Zaten mevcut", message: "", preferredStyle: .alert)
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
            self.updateText()
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertForAdded() {
        let alert = UIAlertController(title: "Zor kelimeler sayfas??na eklendi", message: "", preferredStyle: .alert)
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
            self.updateText()
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func imageRenderer(imageName: String) -> UIImage {
        let imageSize = 25
        return UIGraphicsImageRenderer(size: CGSize(width: imageSize, height: imageSize)).image { _ in
            UIImage(named: imageName)?.draw(in: CGRect(x: 0, y: 0, width: imageSize, height: imageSize)) }
    }
    
    func swipeAnimation() {
        tableView.isHidden = true
        UIView.transition(with: tableView, duration: 1.0,
                          options: .transitionCurlUp,
                          animations: {
                            self.tableView.isHidden = false
                      })
    }
    
}

    //MARK: - Show Words

extension CardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! WordCell
        
        cell.engView.isHidden = true
        cell.trLabel.textAlignment = .center
        cell.trView.backgroundColor = UIColor(named: "quizBackground")
        cell.trLabel.textColor = UIColor(named: "d6d6d6")
        cell.trLabel.attributedText = writeAnswerCell(questionENG, questionTR)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height
    }
    
    func writeAnswerCell(_ eng: String, _ tr: String) -> NSMutableAttributedString{
        
        let textSize = CGFloat(UserDefaults.standard.integer(forKey: "textSize"))
        
        let boldFontAttributes = [NSAttributedString.Key.font: UIFont(name: "AvenirNext-Medium", size:textSize+12)]
        let normalFontAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "d6d6d6"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: textSize)]
        
        let english = NSMutableAttributedString(string: "\(eng)\n\n", attributes: boldFontAttributes as [NSAttributedString.Key : Any])
        
        let meaning =  NSMutableAttributedString(string: "\(tr)\n", attributes: normalFontAttributes as [NSAttributedString.Key : Any])
     
        let combination = NSMutableAttributedString()
            
            combination.append(english)
            combination.append(meaning)
        
        return combination
    }
}

    //MARK: - Swipe Cell

extension CardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let addAction = UIContextualAction(style: .normal, title:  "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.showAlertForAdded()
            self.wordBrain.addHardWords(self.questionNumber)
            success(true)
        })
        addAction.image = imageRenderer(imageName: "plus")
        addAction.backgroundColor = UIColor(red: 1.00, green: 0.75, blue: 0.28, alpha: 1.00)
        
        if itemArray[questionNumber].addedHardWords == true {
            showAlertForAlreadyAdded()
            return UISwipeActionsConfiguration()
        }
        
        return UISwipeActionsConfiguration(actions: [addAction])
    }
}
