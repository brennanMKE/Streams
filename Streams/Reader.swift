import Foundation

public class Reader: NSObject {
    private let fileURL: URL
    private let stream: InputStream
    private let group: DispatchGroup
    private let queue: DispatchQueue

    private let size = 1024
    private var buffer: [UInt8]
    private var totalReadCount = 0

    public init?(fileURL: URL) {
        guard let stream = InputStream(url: fileURL) else {
            return nil
        }
        self.fileURL = fileURL
        self.stream = stream
        buffer = [UInt8](repeating: 0, count: size)
        group = DispatchGroup()
        queue = DispatchQueue(label: "ReadQueue")
        super.init()
    }

    public func readAll() -> Int {
        stream.delegate = self
        stream.schedule(in: .main, forMode: .defaultRunLoopMode)
        stream.open()
        group.enter()
        queue.async(execute: read)
        group.wait()

        return totalReadCount
    }

    private func read() {
        var i = 0
        while stream.hasBytesAvailable {
            i += 1
            let readCount = stream.read(&buffer, maxLength: size)
            if readCount == 0 {
                finish()
            }
            totalReadCount += readCount
        }
    }

    private func finish() {
        stream.close()
        stream.remove(from: .main, forMode: .defaultRunLoopMode)
        group.leave()
    }

}

extension Reader: StreamDelegate {

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            debugPrint("🚀 Open Completed")
            queue.async(execute: read)
        case .hasBytesAvailable:
            debugPrint("🚀 Has Bytes Available")
            queue.async(execute: read)
        case .hasSpaceAvailable:
            debugPrint("🚀 Has Space Available")
        case .errorOccurred:
            debugPrint("🚀 Error Occurred")
        case .endEncountered:
            debugPrint("🚀 End Encountered")
            finish()
        default:
            fatalError()
        }
    }

}
