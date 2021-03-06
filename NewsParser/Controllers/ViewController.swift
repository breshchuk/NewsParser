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
    
    private var parsers: [NewsParserProtocol] = [
        ParserFromContextualWebSearch(),
        ParserFromNY()
    ]
    
    private var saveService: SaveManager!
    private var timer : Timer?
    private var timerToParseIndicator: Timer?
    
    //MARK: - UI
    
    @IBOutlet weak var switchOutlet: NSSwitch!
    @IBOutlet weak var TimerView: NSView!
    
    @IBOutlet weak var timerTimeLabel: NSTextField!
    
    @IBOutlet weak var timeToParseLabel: NSTextField!
    
    @IBOutlet weak var slider: NSSlider!
    
    @IBOutlet weak var parsingIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseApp.configure()
        
        saveService = SaveToFile()
        
        timerTimeLabel.stringValue = "\(slider.stringValue) min"
        slider.isEnabled = false
        
        //MARK: - Check user
        if Auth.auth().currentUser == nil {
            Auth.auth().signIn(withEmail: "breschuk1@gmail.com", password: "test123") { (result, error) in
                if let error = error {
                    self.presentError(error)
                    return
                } else if let result = result {
                    print("-------------", result)
                }
            }
        }
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
        
        let saver = SaveToFirebase()
        
        //MARK: - Parse data
        for parser in self.parsers {
            parser.getNews { result in
                switch result {
                case .success(let news):
                    for item in news {
                        saver.saveNews(news: item)
                    }
                    self.createTimer(timeInterval: self.slider.intValue)
                    self.parsingIndicator.stopAnimation(self)
                    self.parsingIndicator.isHidden = true
                case .failure(let error):
                    self.view.presentError(error)
                    self.switchOutlet.state = .off
                    self.switchChanged(self.switchOutlet)
                    self.parsingIndicator.stopAnimation(self)
                    self.parsingIndicator.isHidden = true
                }
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
    
    private func createTimer(timeInterval: Int32) {
        if timer == nil, switchOutlet.state != .off {
            let ti = Double(timeInterval * 60)
            timer = Timer.scheduledTimer(timeInterval: ti, target: self, selector: #selector(updateNews), userInfo: nil, repeats: true)
            timerToParseIndicator = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeToParseLabel), userInfo: nil, repeats: true)
            print("timer \(ti)")
        }
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
    
    @IBAction func saveJSONButtonPressed(_ sender: NSButton) {
        self.saveService.save(data: nil)
    }
}

