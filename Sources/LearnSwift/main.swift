import Foundation
import LearnSwiftCore

print(String(repeating: "=", count: 70))
print("  Learn Swift 6 Modern Systems Architecture Masterclass")
print(String(repeating: "=", count: 70))

let store = CurriculumStore()

Task {
    print("\n[Actor Isolated Stream] Streaming 7-Stage Pedagogical Roadmap:")
    var completedCount = 0

    let stream = await store.streamStages()
    for await stage in stream {
        let symbol = stage.completed ? "✓" : "○"
        if stage.completed { completedCount += 1 }
        print("  [\(symbol)] Stage \(stage.id): \(stage.title)")
        print("      Focus: \(stage.domainFocus)")
    }

    let total = await store.getAllStages().count
    let percent = await store.getProgressPercentage()
    print("\n[Progress Metric] Mastered \(completedCount) of \(total) stages (\(percent)%)")

    let result: DomainResult<String> = .success("Actors isolated state without data races.")
    switch result {
    case .success(let message):
        print("\n[Pattern Matching] Success: \(message)")
    case .failure(let err):
        print("\n[Pattern Matching] Error: \(err)")
    }
    
    exit(0)
}

RunLoop.main.run()
