
//
//  AsyncTests.swift
//  
//
//  Created by Abhijith Pm on 28/06/25.
//

import XCTest
@testable import EXNetworkLayer

// MARK: - Mock
struct MockTodo: Codable, Equatable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

enum TodoAPI {
    case getTodo(id: Int)
}

extension TodoAPI: API {
    var scheme: HTTPScheme {
        .https
    }
    
    var baseURL: String {
        "jsonplaceholder.typicode.com"
    }
    
    var path: String {
        switch self {
        case .getTodo(let id):
            return "/todos/\(id)"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeader {
        [:]
    }
    
    var requestParameters: HTTPRequestBody {
        .body(params: [:])
    }
    
    var sslContent: SSLContent {
        .none
    }
    
    var shouldLog: Bool {
        false
    }
    
    var endPoint: String {
        path
    }
}

// MARK: - Tests

@available(iOS 13.0.0, *)
final class AsyncTests: XCTestCase {

    func testGetTodo() async throws {
        let mockData = MockData.data("""
        {
            "userId": 1,
            "id": 1,
            "title": "delectus aut autem",
            "completed": false
        }
        """.data(using: .utf8)!)
        let mockClient = MockHTTPClient(mockData: mockData)
        let networkManager = EXNetworkManager(api: TodoAPI.getTodo(id: 1), session: mockClient)
        let todo = try await networkManager.callApi(responseType: MockTodo.self)
        XCTAssertEqual(todo.id, 1)
    }
    
    func testGetTodos() async throws {
        let mockData = MockData.data("""
        [
            {
                "userId": 1,
                "id": 1,
                "title": "delectus aut autem",
                "completed": false
            }
        ]
        """.data(using: .utf8)!)
        let mockClient = MockHTTPClient(mockData: mockData)
        let networkManager = EXNetworkManager(api: TodoAPI.getTodo(id: 1), session: mockClient)
        let todos = try await networkManager.callApi(responseType: [MockTodo].self)
        XCTAssertEqual(todos.count, 1)
    }
}

