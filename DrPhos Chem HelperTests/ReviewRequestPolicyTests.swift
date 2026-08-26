import XCTest
@testable import DrPhos_Chem_Helper

final class ReviewRequestPolicyTests: XCTestCase {
    private let startDate = Date(timeIntervalSince1970: 1_000_000)

    func testPolicyWaitsForMeaningfulToolEngagement() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let policy = ReviewRequestPolicy(defaults: defaults, configuration: .production)
        recordRequiredLaunches(using: policy)

        for index in 0..<9 {
            policy.recordToolOpen(toolID: "tool-\(index % 3)")
        }

        let eligibleDate = startDate.addingTimeInterval(8 * 24 * 60 * 60)
        XCTAssertFalse(policy.shouldRequestReview(at: eligibleDate, appVersion: "4.0.2"))

        policy.recordToolOpen(toolID: "tool-0")

        XCTAssertTrue(policy.shouldRequestReview(at: eligibleDate, appVersion: "4.0.2"))
    }

    func testPolicyRequiresThreeDistinctTools() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let policy = ReviewRequestPolicy(defaults: defaults, configuration: .production)
        recordRequiredLaunches(using: policy)

        for index in 0..<10 {
            policy.recordToolOpen(toolID: index.isMultiple(of: 2) ? "calculator" : "pH")
        }

        let eligibleDate = startDate.addingTimeInterval(8 * 24 * 60 * 60)
        XCTAssertFalse(policy.shouldRequestReview(at: eligibleDate, appVersion: "4.0.2"))

        policy.recordToolOpen(toolID: "reaction-solver")

        XCTAssertTrue(policy.shouldRequestReview(at: eligibleDate, appVersion: "4.0.2"))
    }

    func testPolicyRequiresThreeLaunchesAndSevenDays() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let policy = ReviewRequestPolicy(defaults: defaults, configuration: .production)
        policy.recordLaunch(at: startDate)
        policy.recordLaunch(at: startDate.addingTimeInterval(60))
        recordRequiredToolOpens(using: policy)

        XCTAssertFalse(
            policy.shouldRequestReview(
                at: startDate.addingTimeInterval(8 * 24 * 60 * 60),
                appVersion: "4.0.2"
            )
        )

        policy.recordLaunch(at: startDate.addingTimeInterval(120))

        XCTAssertFalse(
            policy.shouldRequestReview(
                at: startDate.addingTimeInterval(6 * 24 * 60 * 60),
                appVersion: "4.0.2"
            )
        )
        XCTAssertTrue(
            policy.shouldRequestReview(
                at: startDate.addingTimeInterval(7 * 24 * 60 * 60),
                appVersion: "4.0.2"
            )
        )
    }

    func testPolicyAttemptsOnlyOncePerVersionAndObservesCooldown() throws {
        let (defaults, suiteName) = try makeDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let policy = ReviewRequestPolicy(defaults: defaults, configuration: .production)
        recordRequiredLaunches(using: policy)
        recordRequiredToolOpens(using: policy)

        let firstRequestDate = startDate.addingTimeInterval(8 * 24 * 60 * 60)
        policy.recordRequestAttempt(at: firstRequestDate, appVersion: "4.0.2")

        XCTAssertFalse(
            policy.shouldRequestReview(
                at: firstRequestDate.addingTimeInterval(200 * 24 * 60 * 60),
                appVersion: "4.0.2"
            )
        )
        XCTAssertFalse(
            policy.shouldRequestReview(
                at: firstRequestDate.addingTimeInterval(119 * 24 * 60 * 60),
                appVersion: "4.0.3"
            )
        )
        XCTAssertTrue(
            policy.shouldRequestReview(
                at: firstRequestDate.addingTimeInterval(120 * 24 * 60 * 60),
                appVersion: "4.0.3"
            )
        )
    }

    private func recordRequiredLaunches(using policy: ReviewRequestPolicy) {
        policy.recordLaunch(at: startDate)
        policy.recordLaunch(at: startDate.addingTimeInterval(60))
        policy.recordLaunch(at: startDate.addingTimeInterval(120))
    }

    private func recordRequiredToolOpens(using policy: ReviewRequestPolicy) {
        for index in 0..<10 {
            policy.recordToolOpen(toolID: "tool-\(index % 3)")
        }
    }

    private func makeDefaults() throws -> (UserDefaults, String) {
        let suiteName = "ReviewRequestPolicyTests.\(UUID().uuidString)"
        return (try XCTUnwrap(UserDefaults(suiteName: suiteName)), suiteName)
    }
}
