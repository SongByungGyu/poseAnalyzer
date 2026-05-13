import UIKit

/// 사진 파일을 Documents 폴더에 저장·로드·삭제
final class ImageStore {

    private let baseDirectory: URL
    private let fileManager = FileManager.default

    init(baseDirectory: URL? = nil) {
        if let base = baseDirectory {
            self.baseDirectory = base
        } else {
            self.baseDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }

    enum ImageStoreError: Error {
        case encodingFailed
        case writeFailed(underlying: Error)
    }

    /// 사진 저장 후 상대 경로 반환
    @discardableResult
    func save(_ image: UIImage, for sessionID: UUID, view: SessionView) throws -> String {
        let sessionDir = baseDirectory
            .appendingPathComponent("sessions")
            .appendingPathComponent(sessionID.uuidString)
        try fileManager.createDirectory(at: sessionDir, withIntermediateDirectories: true)

        // 저장용 다운샘플링 (max 1024px)
        let downsized = image.downscaled(maxDimension: 1024)
        guard let data = downsized.jpegData(compressionQuality: 0.85) else {
            throw ImageStoreError.encodingFailed
        }

        let filename = "\(view.rawValue).jpg"
        let fileURL = sessionDir.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw ImageStoreError.writeFailed(underlying: error)
        }

        // 상대 경로 (Documents 기준)
        return "sessions/\(sessionID.uuidString)/\(filename)"
    }

    /// 경로로 사진 로드
    func load(path: String) -> UIImage? {
        let url = baseDirectory.appendingPathComponent(path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    /// 세션의 모든 사진 삭제
    func delete(for sessionID: UUID) throws {
        let sessionDir = baseDirectory
            .appendingPathComponent("sessions")
            .appendingPathComponent(sessionID.uuidString)
        if fileManager.fileExists(atPath: sessionDir.path) {
            try fileManager.removeItem(at: sessionDir)
        }
    }
}

// MARK: - UIImage Downscale

extension UIImage {
    /// 긴 변이 maxDimension을 넘지 않도록 축소 (작으면 원본 반환)
    func downscaled(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
