import XCTest
@testable import chatty_pal

final class WhisperTranscriberTests: XCTestCase {
    func testMultipartBodyContainsAllFields() {
        let wav = Data([0x52, 0x49, 0x46, 0x46])
        let (body, contentType) = WhisperTranscriber.multipartBody(wav: wav, model: WhisperTranscriber.model, language: "de")

        XCTAssertTrue(contentType.hasPrefix("multipart/form-data; boundary="))
        let boundary = String(contentType.dropFirst("multipart/form-data; boundary=".count))
        let text = String(decoding: body, as: UTF8.self)

        XCTAssertTrue(text.contains("--\(boundary)\r\n"))
        XCTAssertTrue(text.contains("name=\"model\"\r\n\r\n\(WhisperTranscriber.model)\r\n"))
        XCTAssertTrue(text.contains("name=\"language\"\r\n\r\nde\r\n"))
        XCTAssertTrue(text.contains("name=\"file\"; filename=\"audio.wav\""))
        XCTAssertTrue(text.contains("Content-Type: audio/wav"))
        XCTAssertTrue(text.hasSuffix("--\(boundary)--\r\n"))
        XCTAssertTrue(body.range(of: wav) != nil)
    }

    func testTextParsesTranscript() throws {
        let json = Data(#"{"text": "Hallo Welt", "task": "transcribe"}"#.utf8)
        XCTAssertEqual(try WhisperTranscriber.text(from: json), "Hallo Welt")
    }

    func testTextTrimsWhitespace() throws {
        let json = Data(#"{"text": "  hallo \n"}"#.utf8)
        XCTAssertEqual(try WhisperTranscriber.text(from: json), "hallo")
    }

    func testTextRejectsMissingOrEmptyText() {
        XCTAssertThrowsError(try WhisperTranscriber.text(from: Data(#"{"task": "transcribe"}"#.utf8)))
        XCTAssertThrowsError(try WhisperTranscriber.text(from: Data(#"{"text": "   "}"#.utf8)))
        XCTAssertThrowsError(try WhisperTranscriber.text(from: Data("not json".utf8)))
    }

    func testRefererAlwaysEndsWithSlash() {
        let base = URL(string: "https://chatty-pal.com")!
        XCTAssertEqual(WhisperTranscriber.referer(for: base), "https://chatty-pal.com/")
        let baseWithSlash = URL(string: "https://chatty-pal.com/")!
        XCTAssertEqual(WhisperTranscriber.referer(for: baseWithSlash), "https://chatty-pal.com/")
    }
}
