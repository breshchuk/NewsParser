//
//  ReadFromFirebase.swift
//  NewsParser
//
//  Created by Harbros61 on 8.05.21.
//

import Firebase

protocol ReadData {
    func getData(completion: @escaping (Result<Data,Error>) -> Void)
}

class ReadFromFirebase: ReadData {
    
    var ref = Database.database().reference().child("news")
    
    func getData(completion: @escaping (Result<Data,Error>) -> Void) {
        self.ref.getData { (error, snapshot) in
            if let error = error {
                print("Error getting data \(error)")
            }
            else if snapshot.exists() {
                let data = snapshot.value
                guard let json = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                    DispatchQueue.main.async {
                        completion(.failure(error!))
                    }
                    return
                }
                DispatchQueue.main.async {
                completion(.success(json))
                }
            }
            else {
                print("No data available")
            }
        }
    }
}
