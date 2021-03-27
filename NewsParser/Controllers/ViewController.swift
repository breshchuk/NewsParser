//
//  ViewController.swift
//  NewsParser
//
//  Created by dimam on 15.03.21.
//

import Cocoa
import Firebase
import SwiftSoup

class ViewController: NSViewController {
    
   private var newsArray = [News]()
   private var parsers: [NewsParserProtocol] = [ParserFromNY()]
   private var timer : Timer?
   private var timerToParseIndicator: Timer?
    
    
    //MARK: - UI
    @IBOutlet weak var passTextField: NSTextField!
    
    @IBOutlet weak var emailTextField: NSTextField!
    
    @IBOutlet weak var TimerView: NSView!
    
    @IBOutlet weak var timerTimeLabel: NSTextField!
    
    @IBOutlet weak var timeToParseLabel: NSTextField!
    
    @IBOutlet weak var slider: NSSlider!
    
    @IBOutlet weak var loginButton: NSButton!
    
    @IBOutlet weak var descriptionLabel: NSTextField!
    
    @IBOutlet weak var parsingIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        
        TimerView.isHidden = true
        timerTimeLabel.stringValue = "\(slider.stringValue) min"
        slider.isEnabled = false
        
        //MARK: - Check user
        if Auth.auth().currentUser != nil {
            TimerView.isHidden = false
            hideOrUnHideElements()
        }
        
    }
    
    private func hideOrUnHideElements() {
        emailTextField.isHidden = !emailTextField.isHidden
        passTextField.isHidden = !passTextField.isHidden
        loginButton.isHidden = !loginButton.isHidden
        descriptionLabel.isHidden = !descriptionLabel.isHidden
    }
    
    private func cancelTimers() {
        timerToParseIndicator?.invalidate()
        timerToParseIndicator = nil
        timer?.invalidate()
        timer = nil
        
    }
    
    
    @objc private func updateNews() {
        
        cancelTimers()
        parsingIndicator.isHidden = false
        parsingIndicator.startAnimation(self)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        //MARK: - Parse data
        do {
            for parser in self!.parsers {
                let news = try parser.getNews()
                DispatchQueue.main.async {
                    self?.newsArray.append(contentsOf: news )
                }
            }
        } catch Exception.Error(let type, let message) {
            print(type)
            print(message)
        } catch {
            print(error.localizedDescription)
        }
        
        
        //MARK: - Save data
        let saver = SaveToFirebase()
        
            for item in self!.newsArray {
               saver.saveNews(news: item)
        }
            DispatchQueue.main.async {
                 self?.newsArray.removeAll()
                self?.createTimer(timeInterval: self!.slider.intValue)
                self?.parsingIndicator.stopAnimation(self)
                self?.parsingIndicator.isHidden = true
            }
        }
        
    }
    
    @objc private func updateTimeToParseLabel() {
        guard let timerTime = timer?.fireDate else { return }
        let time = Date().timeIntervalSince(timerTime)
        
        let hours = -(Int(time) / 3600)
        let minutes = -(Int(time) / 60 % 60)
        let seconds = -(Int(time) % 60)
        
        var times: [String] = []
        if hours > 0 {
          times.append("\(hours)h")
        }
        if minutes > 0 {
          times.append("\(minutes)m")
        }
        times.append("\(seconds)s")
        
        timeToParseLabel.stringValue = times.joined(separator: " ")
    }
    
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func checkUser() {
        if Auth.auth().currentUser == nil {
            Auth.auth().signIn(withEmail: emailTextField.stringValue, password: passTextField.stringValue) { [weak self] authResult , error in
                if let error = error {
                    self?.view.presentError(error)
                } else {
                    
                }
            }
            
        }
    }
    
    private func createTimer(timeInterval: Int32) {
        let ti = Double(timeInterval * 60)
        timer = Timer.scheduledTimer(timeInterval: ti, target: self, selector: #selector(updateNews), userInfo: nil, repeats: true)
        timerToParseIndicator = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeToParseLabel), userInfo: nil, repeats: true)
        print("timer \(ti)")
    }
    
    @IBAction func switchChanged(_ sender: NSSwitch) {
        if sender.state == .on, timer == nil {
            createTimer(timeInterval: slider.intValue)
            slider.isEnabled = true
        } else {
            cancelTimers()
            slider.isEnabled = false
            timeToParseLabel.stringValue = "0s"
            print("timer off")
        }
    }
    
    @IBAction func sliderChanged(_ sender: NSSlider) {
        if timer != nil {
            cancelTimers()
        }
          createTimer(timeInterval: sender.intValue)
          timerTimeLabel.stringValue = "\(sender.intValue)m"
    }
    
    @IBAction func loginButtonPressed(_ sender: NSButton) {
        checkUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: { [weak self] in
            if Auth.auth().currentUser != nil {
                self?.TimerView.isHidden = false
                self?.hideOrUnHideElements()
            }
        })
    }
    
    
    @IBAction func signOutButtonPressed(_ sender: NSButton) {
        do {
            try Auth.auth().signOut()
            hideOrUnHideElements()
            emailTextField.stringValue = ""
            passTextField.stringValue = ""
            TimerView.isHidden = true
        } catch {
            view.presentError(error)
        }
    }
    
    
}

