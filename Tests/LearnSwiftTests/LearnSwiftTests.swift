import XCTest
@testable import LearnSwiftCore

final class LearnSwiftTests: XCTestCase {
    func testCurriculumStageCount() async {
        let store = CurriculumStore()
        let stages = await store.getAllStages()
        XCTAssertEqual(stages.count, 7)
        XCTAssertEqual(stages.first?.id, 1)
        XCTAssertEqual(stages.last?.id, 7)
    }

    func testCompletedCount() async {
        let store = CurriculumStore()
        let completed = await store.getCompletedCount()
        XCTAssertGreaterThanOrEqual(completed, 2)
    }

    func testDomainResultEnum() {
        let success: DomainResult<Int> = .success(42)
        if case .success(let val) = success {
            XCTAssertEqual(val, 42)
        } else {
            XCTFail("Expected success")
        }
    }
}
