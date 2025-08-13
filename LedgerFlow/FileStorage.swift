import Foundation

class FileStorage {
    static let shared = FileStorage()
    private init() {}
    
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func fileURL(for filename: String) -> URL {
        documentsDirectory.appendingPathComponent("\(filename).json")
    }
    
    func save<T: Codable>(_ object: T, to filename: String) async throws {
        let url = fileURL(for: filename)
        let data = try JSONEncoder().encode(object)
        try data.write(to: url)
    }
    
    func load<T: Codable>(_ type: T.Type, from filename: String) async throws -> T {
        let url = fileURL(for: filename)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    func exists(_ filename: String) -> Bool {
        let url = fileURL(for: filename)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func delete(_ filename: String) throws {
        let url = fileURL(for: filename)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
