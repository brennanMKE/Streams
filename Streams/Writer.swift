import Foundation

public class Writer: NSObject {
    private let fileURL: URL
    private let stream: OutputStream
    private let group: DispatchGroup
    private let queue: DispatchQueue

    private let size = 1024
    private let maxWrites = 512
    private var totalWrites = 0
    private var totalWriteCount = 0

    // Swift OutputStream StreamDelegate

    public init?(fileURL: URL) {
        guard let stream = OutputStream(url: fileURL, append: false) else {
            return nil
        }
        self.fileURL = fileURL
        self.stream = stream
        group = DispatchGroup()
        queue = DispatchQueue(label: "WriteQueue")
        super.init()
    }

    public func writeAll() -> Int {
        if isClosed {
            return 0
        }
        stream.delegate = self
        stream.schedule(in: .main, forMode: .defaultRunLoopMode)
        stream.open()
        group.enter()
        queue.async(execute: write)
        group.wait()

        return totalWriteCount
    }

    private var isClosed: Bool {
        return stream.streamStatus == .closed
    }

    private var isDone: Bool {
        return totalWrites == maxWrites
    }

    private func write() {
        var writeCount = 0
        while stream.hasSpaceAvailable && !isDone {
            var buffer = [UInt8].init(repeating: 0, count: size)
            writeCount = stream.write(&buffer, maxLength: size)
            totalWriteCount = writeCount
            totalWrites += 1
        }

        if isDone {
            finish()
        }
    }

    private func finish() {
        stream.close()
        stream.remove(from: .main, forMode: .defaultRunLoopMode)
        group.leave()
    }

}

extension Writer: StreamDelegate {

    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            debugPrint("🚀 Open Completed")
            queue.async(execute: write)
        case .hasBytesAvailable:
            debugPrint("🚀 Has Bytes Available")
        case .hasSpaceAvailable:
            debugPrint("🚀 Has Space Available")
            queue.async(execute: write)
        case .errorOccurred:
            debugPrint("🚀 Error Occurred")
        case .endEncountered:
            debugPrint("🚀 End Encountered")
        default:
            fatalError()
        }
    }

}
