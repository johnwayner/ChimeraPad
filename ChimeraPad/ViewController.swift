//
//  ViewController.swift
//  ChimeraPad
//
//  Created by Wayne Rittimann, Jr. on 1/20/17.
//  Copyright © 2017 Wayne Rittimann, Jr. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var chimeraSelectSegment: UISegmentedControl!
    @IBOutlet weak var bidSelectSegment: UISegmentedControl!
    
    @IBOutlet weak var bonusStepper: UIStepper!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var bidMadeSwitch: UISwitch!
    
    @IBOutlet weak var player1CardValueLabel: UILabel!
    @IBOutlet weak var player1CardValueStepper: UIStepper!
    @IBOutlet weak var player1HandScoreLabel: UILabel!
    
    
    @IBOutlet weak var player2CardValueLabel: UILabel!
    @IBOutlet weak var player2CardValueStepper: UIStepper!
    @IBOutlet weak var player2HandScoreLabel: UILabel!
    
    @IBOutlet weak var player3CardValueLabel: UILabel!
    @IBOutlet weak var player3CardValueStepper: UIStepper!
    @IBOutlet weak var player3HandScoreLabel: UILabel!
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var player1CardPlayedSwitch: UISwitch!
    @IBOutlet weak var player2CardPlayedSwitch: UISwitch!
    @IBOutlet weak var player3CardPlayedSwitch: UISwitch!
    
    
    struct HandResult {
        var gameScores = [0, 0, 0];
        var scores = [0, 0, 0];
        var chimeraIdx = UISegmentedControlNoSegment;
        var bidIdx = UISegmentedControlNoSegment;
        var bonusCount = 0;
        var bidMade = false;
        var cardPlayed = [false, false, false];
        var cardValues = [0, 0, 0];
    }
    
    var results : [HandResult] = [];
    var currentResult = HandResult();
    var savedResult : HandResult? = nil;
    var editingIdx = -1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func calcAndUpdateScore() {
        currentResult = updateResult(currentResult);
        displayResult(result: currentResult);
    }
    
    func updateResult(_ resultX : HandResult) -> HandResult {
        var result = resultX;
        result.scores = [0, 0, 0];
        let bids = [20, 30, 40];
    
        let chimeraIdx = result.chimeraIdx;
        
        if(chimeraIdx >= 0 && result.bidIdx >= 0) {
            
            let bid = bids[result.bidIdx];
        
            if(result.bidMade) {
                let anyNoPlay = result.cardPlayed.reduce(false, {$0 || !$1});
            
                var bonuses = result.bonusCount;
                if(anyNoPlay) {
                    bonuses += 1;
                }
            
                result.scores[chimeraIdx] +=
                    (2 * bid) +
                    (25 * bonuses);
            
            } else {
                for i in 0...2 {
                    if i == chimeraIdx {
                        result.scores[i] -= bid;
                    } else {
                        result.scores[i] += 20;
                    }
                }
            }
        
            for i in 0...2 {
                result.scores[i] += result.cardValues[i];
            }
        }
        
        return result;
    }
    
    func displayResult(result: HandResult) {
        self.chimeraSelectSegment.selectedSegmentIndex = result.chimeraIdx;
        self.bidSelectSegment.selectedSegmentIndex = result.bidIdx;
        self.bonusStepper.value = Double(result.bonusCount);
        self.bonusLabel.text = "\(result.bonusCount)";
        self.bidMadeSwitch.setOn(result.bidMade, animated: true);
        self.player1CardPlayedSwitch.setOn(result.cardPlayed[0], animated: true);
        self.player2CardPlayedSwitch.setOn(result.cardPlayed[1], animated: true);
        self.player3CardPlayedSwitch.setOn(result.cardPlayed[2], animated: true);
        self.player1CardValueStepper.value = Double(result.cardValues[0]);
        self.player1CardValueLabel.text = "\(result.cardValues[0])";

        self.player2CardValueStepper.value = Double(result.cardValues[1]);
        self.player2CardValueLabel.text = "\(result.cardValues[1])";

        self.player3CardValueStepper.value = Double(result.cardValues[2]);
        self.player3CardValueLabel.text = "\(result.cardValues[2])";
        
        if(currentResult.cardValues.reduce(0, {$0+$1}) > 60) {
            self.player1CardValueLabel.textColor = UIColor.red;
            self.player2CardValueLabel.textColor = UIColor.red;
            self.player3CardValueLabel.textColor = UIColor.red;
        } else {
            self.player1CardValueLabel.textColor = UIColor.black;
            self.player2CardValueLabel.textColor = UIColor.black;
            self.player3CardValueLabel.textColor = UIColor.black;
        }
        
        self.player1HandScoreLabel.text = "\(result.scores[0])";
        self.player2HandScoreLabel.text = "\(result.scores[1])";
        self.player3HandScoreLabel.text = "\(result.scores[2])";
    }
    
    func doClear() {
        if(self.savedResult == nil) {
            self.currentResult = HandResult();
        } else {
            self.historyTableView.deselectRow(at: IndexPath(row: self.editingIdx, section: 0), animated: true);
            self.editingIdx = -1;
            self.currentResult = self.savedResult!;
            self.savedResult = nil;
        }
        
        self.calcAndUpdateScore();
    }

    @IBAction func onClear(_ sender: UIButton) {
        let refreshAlert = UIAlertController( title: "Confirm", message: (self.savedResult == nil ? "Clear current hand?" : "Cancel Edit?"), preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.doClear();
        }));
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }));
        
        present(refreshAlert, animated: true, completion: nil);
        
    }
    @IBAction func onScore(_ sender: UIButton) {
        calcAndUpdateScore();
        
        if(savedResult == nil) {
        
            let prevResultIdx = results.count-1;
        
            let prevScores = prevResultIdx >= 0 ? results[prevResultIdx].gameScores : [0,0,0];
        
            for i in 0...2 {
                currentResult.gameScores[i] = prevScores[i] + currentResult.scores[i];
            }
            
            results.append(currentResult);
            currentResult = HandResult();

        } else {
            results[editingIdx] = currentResult;
            
            for i in 0..<results.count {
                let prevResultIdx = i - 1;
                let prevScores = prevResultIdx >= 0 ? results[prevResultIdx].gameScores : [0,0,0];
                
                for p in 0...2 {
                    results[i].gameScores[p] = prevScores[p] + results[i].scores[p];
                }
            }
       
            self.historyTableView.deselectRow(at: IndexPath(row: editingIdx, section: 0), animated: true);
            editingIdx = -1;
            currentResult = savedResult!;
            savedResult = nil;
        }
        
        calcAndUpdateScore();
        self.historyTableView.reloadData();
        self.historyTableView.scrollToRow(at: IndexPath(row: results.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true);
    }
    @IBAction func onNewGame(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "New Game", message: "All data will be lost.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.results = [];
            self.doClear();
            self.historyTableView.reloadData();

        }));
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }));
        
        present(refreshAlert, animated: true, completion: nil);
    }
    @IBAction func onChimeraPicked(_ sender: UISegmentedControl) {
        currentResult.chimeraIdx = sender.selectedSegmentIndex;
        currentResult.cardPlayed = [false, false, false];
        currentResult.cardPlayed[currentResult.chimeraIdx] = true;
        calcAndUpdateScore();
    }
    @IBAction func onBidPicked(_ sender: UISegmentedControl) {
        currentResult.bidIdx = sender.selectedSegmentIndex;
        calcAndUpdateScore();
    }
    @IBAction func onBidMadeSet(_ sender: UISwitch) {
        currentResult.bidMade = sender.isOn;
        calcAndUpdateScore();
    }
    @IBAction func onBonusStepped(_ sender: UIStepper) {
        currentResult.bonusCount = Int(sender.value);
        calcAndUpdateScore();
    }
    @IBAction func onPlayer1CardScoreStepped(_ sender: UIStepper) {
        currentResult.cardValues[0] = Int(sender.value);
        calcAndUpdateScore();
    }
    @IBAction func onPlayer2CardScoreStepped(_ sender: UIStepper) {
        currentResult.cardValues[1] = Int(sender.value);
        calcAndUpdateScore();
    }
    @IBAction func onPlayer3CardScoreStepped(_ sender: UIStepper) {
        currentResult.cardValues[2] = Int(sender.value);
        calcAndUpdateScore();
    }
    @IBAction func onPlayer1CardPlayed(_ sender: UISwitch) {
        currentResult.cardPlayed[0] = sender.isOn;
        calcAndUpdateScore();
    }
    @IBAction func onPlayer2CardPlayed(_ sender: UISwitch) {
        currentResult.cardPlayed[1] = sender.isOn;
        calcAndUpdateScore();
    }
    @IBAction func onPlayer3CardPlayed(_ sender: UISwitch) {
        currentResult.cardPlayed[2] = sender.isOn;
        calcAndUpdateScore();
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count;
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = results[indexPath.row];
        let cellIdentifier = "ResultCell";
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ResultCell  else {
            fatalError("The dequeued cell is not an instance of ResultCell.")
        }
        
        cell.player1ScoreLabel.text = "\(result.gameScores[0])";
        cell.player2ScoreLabel.text = "\(result.gameScores[1])";
        cell.player3ScoreLabel.text = "\(result.gameScores[2])";
        
        cell.player1HandScore.text = "\(result.scores[0])";
        cell.player2HandScore.text = "\(result.scores[1])";
        cell.player3HandScore.text = "\(result.scores[2])";
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        savedResult = currentResult;
        currentResult = results[indexPath.row];
        editingIdx = indexPath.row;
        calcAndUpdateScore();
    }
    
}

