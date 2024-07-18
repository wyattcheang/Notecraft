//
//  File.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 15/06/2024.
//

import Foundation
import Observation
import UIKit

class Chapter: Identifiable, Decodable {
    var id: Int
    var title: String
    var units: [Unit]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case units = "units"
    }
}

class Unit: Identifiable, Decodable {
    var id: Int
    var title: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
    }
}

@Observable
class Quiz: Codable, Identifiable {
    var id: String
    var question: String
    var image: String
    var options: [Option]
    var uiImage: UIImage?
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _question = "question"
        case _image = "image"
        case _options = "options"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: ._id)
        self.question = try container.decode(String.self, forKey: ._question)
        self.image = try container.decode(String.self, forKey: ._image)
        self.options = try container.decode([Option].self, forKey: ._options)
        self.uiImage = nil // Initialize uiImage as nil initially
        
        self.options.shuffle()
        if !image.isEmpty {
            fetchQuizImage()
        }
    }
    
    private func fetchQuizImage() {
        Storage.shared.fetchImage(bucket: "images", path: image) { result in
            switch result {
            case .success(let fetchImage):
                self.uiImage = fetchImage
            case .failure(let error):
                print("Failed to fetch quiz image: \(error)")
            }
        }
    }
}

@Observable
class Option: Codable, Identifiable {
    var id: String = ""
    var answer: String = ""
    var image: String = ""
    var correctness: Bool = false
    var uiImage: UIImage?
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _answer = "answer"
        case _image = "image"
        case _correctness = "correctness"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: ._id)
        self.answer = try container.decode(String.self, forKey: ._answer)
        self.image = try container.decode(String.self, forKey: ._image)
        self.correctness = try container.decode(Bool.self, forKey: ._correctness)
        self.uiImage = nil
        
        if !image.isEmpty {
            fetchOptionImage()
        }
    }
    
    func fetchOptionImage() {
        Storage.shared.fetchImage(bucket: "images", path: image) { result in
            switch result {
            case .success(let image):
                self.uiImage = image
            case .failure(let error):
                print("Failed to fetch option image: \(error)")
            }
        }
    }
}

@Observable
class QuizUnitAvailability: Codable {
    var unitId: Int
    var availability: Bool
    
    private enum CodingKeys: String, CodingKey {
        case _unitId = "unit_id"
        case _availability = "availability"
    }
}

@Observable
class QuizLog: Codable {
    var unitId: Int
    var accuracy: Double
    var date: Date
    var timeTaken: Int
    
    init(unitId: Int, accuracy: Double, timeTaken: Int) {
        self.unitId = unitId
        self.accuracy = accuracy
        self.timeTaken = timeTaken
        self.date = Date()
    }
    
    private enum CodingKeys: String, CodingKey {
        case unitId = "unit_id"
        case accuracy = "accuracy"
        case date = "date"
        case timeTaken = "time_taken"
    }
    
    // Custom decoding to include date
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        unitId = try container.decode(Int.self, forKey: .unitId)
        accuracy = try container.decode(Double.self, forKey: .accuracy)
        date = try container.decode(Date.self, forKey: .date)
        timeTaken = try container.decode(Int.self, forKey: .timeTaken)
    }
    
    // Custom encoding to exclude date
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(unitId, forKey: .unitId)
        try container.encode(accuracy, forKey: .accuracy)
        try container.encode(timeTaken, forKey: .timeTaken)
    }
}

class Database {
    static let shared = Database()
    func fetchQuizUnitAvailability(completion: @escaping (Result<[QuizUnitAvailability], Error>) -> Void) {
        Task {
            do {
                let fn = "get_unit_availability"
            let quizUnitAvailability: [QuizUnitAvailability] = try await supabase
                .rpc(fn)
                .select()
                .execute()
                .value
                completion(.success(quizUnitAvailability))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchQuizzes(unitId: Int, completion: @escaping (Result<[Quiz], Error>) -> Void) {
        Task {
            do {
                let quizzes: [Quiz] = try await supabase
                    .from("quiz")
                    .select("""
                            id,
                            question,
                            image,
                            options:option (
                                id,
                                answer,
                                image,
                                correctness
                            )
                            """)
                    .eq("unit_id", value: unitId)
                    .execute()
                    .value
                completion(.success(quizzes))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func addQuizLog(quiz_log: QuizLog, completion: @escaping (Result<Int, Error>) -> Void) {
        Task {
            do {
                let result = try await supabase
                    .from("quiz_log")
                    .insert(quiz_log)
                    .execute()
                completion(.success(result.response.statusCode))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchBestQuizResult(unitId: Int, completion: @escaping (Result<QuizLog, Error>) -> Void) {
        Task {
            do {
                let fn = "get_best_result"
                let params = ["unit_id_input": unitId]
                let quizLog: QuizLog = try await supabase
                    .rpc(fn, params: params)
                    .execute()
                    .value
                completion(.success(quizLog))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
extension Data {
    var prettyString: NSString? {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) ?? nil
    }
}
