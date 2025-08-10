import Foundation

/// Run async tasks in parallel and return results preserving input order.
/// Cancels remaining tasks on first thrown error (fail-fast).
public func concurrently<R>(_ tasks: [() async throws -> R]) async throws -> [R] {
    if Task.isCancelled { throw CancellationError() }
    return try await withThrowingTaskGroup(of: (Int, R).self) { group in
        for (i, work) in tasks.enumerated() {
            group.addTask { (i, try await work()) }
        }
        var results = Array<R?>(repeating: nil, count: tasks.count)
        for try await (i, value) in group {
            results[i] = value
        }
        // At this point, either all tasks succeeded, or the group threw and remaining tasks were cancelled.
        return results.compactMap { $0 }
    }
}

