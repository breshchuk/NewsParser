//
//  FilterViewController.swift
//  NewsParser
//
//  Created by Harbros61 on 9.05.21.
//

import Cocoa

class FilterViewController: NSViewController {
    
    @IBOutlet weak var filterByTitleTextFiled: NSTextField!
    
    @IBOutlet weak var filterByAuthorTextField: NSTextField!
    
    @IBOutlet weak var filterByDateCheckBox: NSButton!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    
    private var readJSONManager: ReadData!
    private var filterJSONManager: FilterJSON!
    private var saveToFileManager: SaveManager!
    private var dataForFilter: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readJSONManager = ReadFromFirebase()
        filterJSONManager = FilterNewsJSON()
        saveToFileManager = SaveToFile()
        
        getDataForFilter()
        
    }
    
    private func getDataForFilter() {
        readJSONManager.getData { result in
            switch result {
            case .success(let data):
                self.dataForFilter = data
            case .failure(let error):
                self.view.presentError(error)
            }
        }
    }

    @IBAction func filterByAllPressed(_ sender: NSButton) {
        let fromDate = fromDatePicker.dateValue
        let toDate = toDatePicker.dateValue
        var isFilterByDate = false
        if filterByDateCheckBox.state == .on {
            isFilterByDate.toggle()
        }
                filterJSONManager.filter(
                    by: [.everything(
                            author: filterByAuthorTextField.stringValue,
                            title: filterByTitleTextFiled.stringValue,
                            fromDate: fromDate,
                            toDate: toDate,
                            isFilterByDate: isFilterByDate
                    )
                    ],
                    jsonData: self.dataForFilter) { result in
                    switch result {
                    case .success(let saveData):
                        self.saveToFileManager.save(data: saveData)
                    case .failure(let error):
                        self.view.presentError(error)
                    }
                }
        }
    }
