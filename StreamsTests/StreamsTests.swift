import XCTest
@testable import Streams

class StreamsTests: XCTestCase {

    func testReadVideoFile() {
        let bundle = Bundle(for: StreamsTests.self)
        guard let fileURL = bundle.url(forResource: "video", withExtension: "mov") else {
            XCTFail()
            return
        }

        guard let reader = Reader(fileURL: fileURL) else {
            XCTFail()
            return
        }

        let count = reader.readAll()
        debugPrint("Read Count = \(count)")
        XCTAssertTrue(count > 0)
    }

    func testWriteLotsOfData() {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .allDomainsMask, true).first else {
            XCTFail()
            return
        }

        let outputDirectoryURL = URL(fileURLWithPath: path).appendingPathComponent("Testing")
        do {
            try FileManager.default.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            debugPrint("Error: \(error)")
            XCTFail()
            return
        }
        let filename = UUID().uuidString

        let fileURL = outputDirectoryURL.appendingPathComponent(filename)
        debugPrint("Output: \(fileURL.path)")
        guard let writer = Writer(fileURL: fileURL) else {
            XCTFail()
            return
        }

        let count = writer.writeAll()
        debugPrint("Write Count = \(count)")
        XCTAssertTrue(count > 0)

        try? FileManager.default.removeItem(at: fileURL)
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
