//
//  SaveTimes.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 31.05.25.
//

import Foundation

struct RecordTime: Codable {
    var squareCount: Int
    var newTime: Int
}

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("File \(file) not found!")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Data from File \(file) could not be read.")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Unable to decode \(file).")
        }
        
    }
}

func createFile(file: String) {
    let documentURL = URL.documentsDirectory.appendingPathComponent(file)
    let fileExists = FileManager.default.fileExists(atPath: documentURL.path)
    if !fileExists {
        let records = Bundle.main.decode([Int:Int].self, from: file)
        do {
            try JSONEncoder().encode(records).write(to: documentURL, options: [.atomic, .completeFileProtection])
            print("records saved to documents directory")
        } catch {
            print(error.localizedDescription)
        }
    }
}

func getAllRecords(file: String = "records.json") -> [Int:Int] {
    let documentURL = URL.documentsDirectory.appendingPathComponent(file)
    let fileExists = FileManager.default.fileExists(atPath: documentURL.path)
    if !fileExists {
        createFile(file: file)
    }
    do {
        let data = try Data(contentsOf: documentURL)
        return try JSONDecoder().decode([Int:Int].self, from: data)
    } catch{
        print(error.localizedDescription)
    }
    return [:]
}

func deleteRecord(fieldCount: Int) {
    var records = getAllRecords()
    records.removeValue(forKey: fieldCount)
    let documentURL = URL.documentsDirectory.appendingPathComponent("records.json")
    do {
        try JSONEncoder().encode(records).write(to: documentURL, options: [.atomic, .completeFileProtection])
    } catch {
        print(error.localizedDescription)
    }
}

func getOldRecord(for squareCount: Int) -> Int {
    let documentURL = URL.documentsDirectory.appendingPathComponent("records.json")
    let fileExists = FileManager.default.fileExists(atPath: documentURL.path)
    if !fileExists {
        createFile(file: "records.json")
    } else {
        do {
            let data = try Data(contentsOf: documentURL)
            let records = try JSONDecoder().decode([Int:Int].self, from: data)
            if records.keys.contains(squareCount) {
                return records[squareCount]!
            }
            return 0
        } catch {
            print(error.localizedDescription)
        }
    }
    return 0
}

func saveNew(record: RecordTime, to file: String = "records.json") throws {
    let documentURL = URL.documentsDirectory.appendingPathComponent(file)
    let fileExists = FileManager.default.fileExists(atPath: documentURL.path)
    if !fileExists {
        createFile(file: file)
    }
    let data = try Data(contentsOf: documentURL)
    var records = try JSONDecoder().decode([Int:Int].self, from: data)
    if records.keys.contains(where: { record.squareCount == $0 }) {
        if records[record.squareCount]! > record.newTime {
            records[record.squareCount] = record.newTime
        }
    } else {
        records[record.squareCount] = record.newTime
    }
    try JSONEncoder().encode(records).write(to: documentURL, options: [.atomic, .completeFileProtection])
}
