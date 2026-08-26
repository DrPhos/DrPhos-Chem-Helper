import Foundation

struct ReviewRequestPolicy {
    struct Configuration: Equatable {
        let requiredToolOpenCount: Int
        let requiredDistinctToolCount: Int
        let requiredLaunches: Int
        let minimumUsageDuration: TimeInterval
        let requestCooldown: TimeInterval

        static let production = Configuration(
            requiredToolOpenCount: 10,
            requiredDistinctToolCount: 3,
            requiredLaunches: 3,
            minimumUsageDuration: 7 * 24 * 60 * 60,
            requestCooldown: 120 * 24 * 60 * 60
        )

        static var appDefault: Configuration {
#if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-ReviewRequestTesting") {
                return Configuration(
                    requiredToolOpenCount: 1,
                    requiredDistinctToolCount: 1,
                    requiredLaunches: 1,
                    minimumUsageDuration: 0,
                    requestCooldown: 0
                )
            }
#endif
            return .production
        }
    }

    private enum Key {
        static let firstUseDate = "reviewRequest.firstUseDate"
        static let launchCount = "reviewRequest.launchCount"
        static let toolOpenCount = "reviewRequest.toolOpenCount"
        static let distinctToolIDs = "reviewRequest.distinctToolIDs"
        static let lastRequestDate = "reviewRequest.lastRequestDate"
        static let lastRequestedVersion = "reviewRequest.lastRequestedVersion"

        static let all = [
            firstUseDate,
            launchCount,
            toolOpenCount,
            distinctToolIDs,
            lastRequestDate,
            lastRequestedVersion
        ]
    }

    private let defaults: UserDefaults
    private let configuration: Configuration

    init(
        defaults: UserDefaults = .standard,
        configuration: Configuration = .appDefault
    ) {
        self.defaults = defaults
        self.configuration = configuration
    }

    func recordLaunch(at date: Date = Date()) {
        if defaults.object(forKey: Key.firstUseDate) == nil {
            defaults.set(date, forKey: Key.firstUseDate)
        }

        defaults.set(
            defaults.integer(forKey: Key.launchCount) + 1,
            forKey: Key.launchCount
        )
    }

    func recordToolOpen(toolID: String) {
        defaults.set(
            defaults.integer(forKey: Key.toolOpenCount) + 1,
            forKey: Key.toolOpenCount
        )

        var distinctToolIDs = Set(defaults.stringArray(forKey: Key.distinctToolIDs) ?? [])
        distinctToolIDs.insert(toolID)
        defaults.set(distinctToolIDs.sorted(), forKey: Key.distinctToolIDs)
    }

    func shouldRequestReview(at date: Date = Date(), appVersion: String) -> Bool {
        let distinctToolCount = defaults.stringArray(forKey: Key.distinctToolIDs)?.count ?? 0

        guard defaults.integer(forKey: Key.toolOpenCount)
                >= configuration.requiredToolOpenCount,
              distinctToolCount >= configuration.requiredDistinctToolCount,
              defaults.integer(forKey: Key.launchCount) >= configuration.requiredLaunches,
              let firstUseDate = defaults.object(forKey: Key.firstUseDate) as? Date,
              date.timeIntervalSince(firstUseDate) >= configuration.minimumUsageDuration,
              defaults.string(forKey: Key.lastRequestedVersion) != appVersion else {
            return false
        }

        if let lastRequestDate = defaults.object(forKey: Key.lastRequestDate) as? Date,
           date.timeIntervalSince(lastRequestDate) < configuration.requestCooldown {
            return false
        }

        return true
    }

    func recordRequestAttempt(at date: Date = Date(), appVersion: String) {
        defaults.set(date, forKey: Key.lastRequestDate)
        defaults.set(appVersion, forKey: Key.lastRequestedVersion)
    }

#if DEBUG
    func reset() {
        for key in Key.all {
            defaults.removeObject(forKey: key)
        }
    }
#endif
}
