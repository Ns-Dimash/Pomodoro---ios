//
//  ViewController.swift
//  CircleProgress
//
//  Created by Dimash Nsanbaev on 2/10/23.
//

import UIKit
import ALProgressView
import SnapKit
import AudioToolbox

class ViewController: UIViewController {
    var cycle = 0
    var cnt = 0
    var timer = Timer()
    var isTimerStarted = false
    var time = 1500
    var count = 0
    var timeTwo = 0
    var prog = 0.0
    var breakRes = 0.0
    lazy var second:Int = {
        return time
    }()
  
    private lazy var progressRing = ALProgressRing()
    
    @objc func showAlert(){
        let alert = UIAlertController(title: "Time" , message: "How long would you like?", preferredStyle: .alert)
        alert.addTextField{field in
            field.placeholder = "Minute"
            field.returnKeyType = .next
            field.keyboardType = .numberPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler: nil))
        alert.addAction(UIAlertAction(title: "Continue", style: .default,handler: { _ in
            guard let fields = alert.textFields,fields.count == 1 else{return}
            let firstT = fields[0]
            guard let first = firstT.text,!first.isEmpty else{
                print("Errorsss")
                return
            }
            self.time = Int(first)!*60
            self.timeTwo = Int(first)!*60
            self.timeLabel.text = "\(Int(first)!):00"
        }))
        
        present(alert,animated: true)
        
    }
    lazy private var total:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "\(count)"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 40)
        return label
    }()
    
    lazy private var timeLabel:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "25:00"
        label.font = UIFont(name: "HelveticaNeue-Light", size: 60)
        return label
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        button.addTarget(self, action: #selector(cancelTap), for: .touchUpInside)
        
        return button
    }()
    
    lazy private var startButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.systemRed,for: .normal)
        button.setTitle("Start", for: .normal)
        button.addTarget(self, action: #selector(startTap), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        return button
    }()
    
    @objc func startTap(){
        cancelButton.isEnabled = true
        cancelButton.alpha = 1.0
        if !isTimerStarted{
            
            startTimer()
            isTimerStarted = true
            startButton.setTitle("Pause", for: .normal)
            startButton.setTitleColor(UIColor.orange, for: .normal)
            
            
        }else {
            timer.invalidate()
            isTimerStarted = false
            startButton.setTitle("Resume", for: .normal)
            startButton.setTitleColor(UIColor.green, for: .normal)
        }
        
    }
    @objc func cancelTap(){
        view.backgroundColor = .black
        prog = 0
        progressRing.setProgress(1, animated: true)
        cancelButton.isEnabled = false
        
        timer.invalidate()
        if timeTwo == 0{
            time = second
            timeLabel.text = "25:00"
        }else{
            time = timeTwo
            timeLabel.text = "\(time/60):00"

        }
        isTimerStarted = false
//        timeLabel.text = "25:00"
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.white, for: .normal)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(progressRing)
        
        view.backgroundColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "hourglass", image: UIImage(systemName: "hourglass"), target: self, action: #selector(showAlert))
        navigationItem.title = "Pomodoro"
        navigationController?.navigationBar.tintColor = .white
        view.addSubview(timeLabel)
        view.addSubview(total)
        view.addSubview(startButton)
        view.addSubview(cancelButton)
        //        showAlert()
        constraint()
        
        
        // MARK: ALProgressRing
        
        // Setup layout
        progressRing.translatesAutoresizingMaskIntoConstraints = false
        progressRing.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressRing.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        // Make sure to set the view size
        progressRing.widthAnchor.constraint(equalToConstant: 250).isActive = true
        progressRing.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
                progressRing.setProgress(1, animated: true)
        
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        time -= 1
        timeLabel.text = formatTime()
        
        
        
        if cycle == 0 || cycle%2 == 0{
            let res:Double = 1/Double(second)
            prog+=res
            progressRing.setProgress(Float(prog), animated: true)
        }else{
            
            prog+=0.0033333333333333335
            progressRing.setProgress(Float(prog), animated: true)
        }


        if timeLabel.text == "00:00"{
            cycle += 1
            cnt+=1
            prog = 0
            print(cycle)
            progressRing.setProgress(0, animated: true)
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {}
            if cnt % 2 == 0{
                navigationItem.title = "Pomodoro"
                if timeTwo == 0{
                    time = second
                }else{
                    time = timeTwo
                }
                count+=1
                total.text = "\(count)"
                view.backgroundColor = .black
                
            }else{
                navigationItem.title = "BreakTime"
                time = 300
                prog = 0
                view.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
            }
        }
    }
    
    
    func formatTime()->String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
        
    }
    
    func constraint(){
        timeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
        }
        
        total.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.4)
            make.centerX.equalToSuperview()
            
        }
        cancelButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.7)
            make.leading.equalToSuperview().inset(50)
        }
        startButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.7)
            make.trailing.equalToSuperview().inset(50)
        }
    }
    
}


