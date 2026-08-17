import XCTest
@testable import chatty_pal

final class ExamViewRenderTests: XCTestCase {
    func testRenderHome() throws {
        _ = ExamPrepHomeView().body
    }
    func testRenderSections() throws {
        for section in ExamSection.allCases {
            _ = ExamSectionView(section: section).body
        }
    }
    func testRenderUnitDetails() throws {
        for section in ExamSection.allCases {
            for unit in ExamA1Catalog.units(in: section) {
                _ = ExamUnitDetailView(unit: unit).body
            }
        }
    }
    func testRenderMiniExam() throws {
        _ = ExamMiniExamView().body
    }
}
