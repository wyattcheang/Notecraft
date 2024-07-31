//
//  File.swift
//  Notecraft
//
//  Created by Wyatt Cheang on 15/06/2024.
//

import Foundation
import Observation
import UIKit

protocol ImageLoadable: AnyObject {
    var image: String { get }
    var uiImage: UIImage? { get set }
    var imageLoadingState: ImageLoadingState { get set }
}

enum ImageLoadingState {
    case loading, loaded, failed
}

extension ImageLoadable {
    func fetchImageAsync() async {
        await withCheckedContinuation { continuation in
            Storage.shared.fetchImage(bucket: "images", path: image) { result in
                switch result {
                case .success(let fetchedImage):
                    self.uiImage = fetchedImage
                    self.imageLoadingState = .loaded
                case .failure(let error):
                    print(self.image)
                    print("Failed to fetch image: \(error)")
                    self.imageLoadingState = .failed
                }
                continuation.resume()
            }
        }
    }
}

class Chapter: Identifiable, Decodable {
    var id: Int
    var title: String
    var subtitle: String
    var units: [Unit]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case subtitle = "subtitle"
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
class Lesson: Codable, Identifiable, ImageLoadable {
    var id: Int
    var text: String
    var image: String
    var midi: [Midi]
    var uiImage: UIImage?
    var imageLoadingState: ImageLoadingState = .loading
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id", _text = "text", _image = "image", _midi = "midi"
    }
}

class Midi: Codable, Identifiable {
    var notes: [UInt8]
    var duration: Double
    
    init(notes: [UInt8], duration: Double = 0.25) {
        self.notes = notes
        self.duration = duration
    }
    
    private enum CodingKeys: String, CodingKey {
        case notes
        case duration
    }
    
    // Custom initializer to provide default value for duration
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode notes as [Int] and then convert to [UInt8]
        let notesArray = try container.decode([Int].self, forKey: .notes)
        self.notes = notesArray.map { UInt8($0) }
        
        // Provide default value if duration is missing
        self.duration = try container.decodeIfPresent(Double.self, forKey: .duration) ?? 0.25
    }
}

@Observable
class Quiz: Codable, Identifiable, ImageLoadable {
    var id: String
    var question: String
    var image: String
    var midi: [Midi]
    var options: [Option]
    var uiImage: UIImage?
    var imageLoadingState: ImageLoadingState = .loading
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id", _question = "question", _image = "image", _options = "options", _midi="midi"
    }
}

@Observable
class Option: Codable, Identifiable, ImageLoadable {
    var id: String = ""
    var answer: String = ""
    var image: String = ""
    var correctness: Bool = false
    var uiImage: UIImage?
    var imageLoadingState: ImageLoadingState = .loading
    
    private enum CodingKeys: String, CodingKey {
        case _id = "id", _answer = "answer", _image = "image", _correctness = "correctness"
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
    func fetchChapter(completion: @escaping (Result<[Chapter], Error>) -> Void) {
        Task {
            do {
                let chapter: [Chapter] = try await supabase
                    .from("chapter")
                    .select("""
                            id,
                            title,
                            subtitle,
                            units: unit (id, title)
                            """)
                    .order("id")
                    .order("id", referencedTable: "unit")
                    .execute()
                    .value
                completion(.success(chapter))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func fetchLesson(unitId: Int, completion: @escaping (Result<[Lesson], Error>) -> Void) {
        Task {
            do {
                let lessons: [Lesson] = try await supabase
                    .from("lesson")
                    .select("""
                            id,
                            image,
                            text,
                            midi
                            """)
                    .eq("unit_id", value: unitId)
                    .order("id")
                    .execute()
                    .value

                // Create a TaskGroup to fetch images concurrently
                await withTaskGroup(of: Void.self) { group in
                    for lesson in lessons {
                        group.addTask {
                            await lesson.fetchImageAsync()
                        }
                    }
                }
                completion(.success(lessons))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
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
    
    func fetchQuizzes(unitId: Int, amount: Int = 10, completion: @escaping (Result<[Quiz], Error>) -> Void) {
        Task {
            do {
                let quizzes: [Quiz] = try await supabase
                    .rpc("random_quizzes", params: ["p_unit_id": unitId, "p_amount": amount])
                    .select("""
                            id,
                            question,
                            image,
                            midi,
                            options:option (
                                id,
                                answer,
                                image,
                                correctness
                            )
                            """)
                    .execute()
                    .value
                // Wait for all quiz and option images to be loaded
                await withTaskGroup(of: Void.self) { group in
                    for quiz in quizzes {
                        if !quiz.image.isEmpty {
                            group.addTask {
                                await quiz.fetchImageAsync()
                            }
                        }
                        for option in quiz.options {
                            if !option.image.isEmpty {
                                group.addTask {
                                    await option.fetchImageAsync()
                                }
                            }
                        }
                    }
                }
                completion(.success(quizzes))
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

}
extension Data {
    var prettyString: NSString? {
        return NSString(data: self, encoding: String.Encoding.utf8.rawValue) ?? nil
    }
}
