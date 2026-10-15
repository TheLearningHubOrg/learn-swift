import Foundation

public actor CurriculumStore {
    private var stages: [RoadmapStage] = [
        RoadmapStage(id: 1, title: "Swift Type System & Value Semantics", domainFocus: "Structs vs classes, copy-on-write (COW), ARC, optionals", completed: true),
        RoadmapStage(id: 2, title: "Protocols, Generics & Opaque Types", domainFocus: "Protocol-oriented programming, associated types, some vs any", completed: true),
        RoadmapStage(id: 3, title: "Memory Safety & Lifetime Ownership", domainFocus: "Exclusive access to memory, ~Copyable noncopyable types", completed: true),
        RoadmapStage(id: 4, title: "Structured Concurrency & async/await", domainFocus: "Tasks, task groups, cancellation cooperative checks", completed: false),
        RoadmapStage(id: 5, title: "Actors & Data Race Safety", domainFocus: "Global actors (@MainActor), actor reentrancy, isolation", completed: false),
        RoadmapStage(id: 6, title: "Server-Side Swift & High-Throughput I/O", domainFocus: "SwiftNIO event loops, non-blocking HTTP streaming", completed: false),
        RoadmapStage(id: 7, title: "Staff Swift Systems Architect Handbook", domainFocus: "Binary size optimization, SIL (Swift Intermediate Language), ABI stability", completed: true)
    ]

    public init() {}

    public func getAllStages() -> [RoadmapStage] {
        return stages
    }

    public func getCompletedCount() -> Int {
        return stages.filter { $0.completed }.count
    }

    public func getProgressPercentage() -> Int {
        let completed = getCompletedCount()
        return Int((Double(completed) / Double(stages.count)) * 100)
    }

    public func streamStages() -> AsyncStream<RoadmapStage> {
        AsyncStream { continuation in
            Task {
                for stage in self.stages {
                    try? await Task.sleep(nanoseconds: 20_000_000) // 20ms
                    continuation.yield(stage)
                }
                continuation.finish()
            }
        }
    }
}
