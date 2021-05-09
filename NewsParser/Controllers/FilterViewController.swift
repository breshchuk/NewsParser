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

    // TODO: Make date filter
    @IBAction func filterByAllPressed(_ sender: NSButton) {
                filterJSONManager.filter(
                    by: [.everything(
                            author: filterByAuthorTextField.stringValue,
                            title: filterByTitleTextFiled.stringValue,
                            fromDate: fromDatePicker.dateValue.description,
                            toDate: toDatePicker.dateValue.description)
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
