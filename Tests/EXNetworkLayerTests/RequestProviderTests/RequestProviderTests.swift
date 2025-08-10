//
//  RequestProviderTests.swift
//  
//
//  Created by Abhijith Pm on 06/11/22.
//

import XCTest
import EXNetworkLayer

class RequestProviderTests: XCTestCase {
    
    private var userApi: EXRequestProvider<TestApi> = .init(api: .users)
    private var postApi: EXRequestProvider<TestApi> = .init(api: .post)
    private var commentsApi: EXRequestProvider<TestApi> = .init(api: .comments(2))
    private var todoApi: EXRequestProvider<TestApi> = .init(api: .todo(2))

    private var allRequestProviders: [EXRequestProvider<TestApi>] {
        [ postApi,
          userApi,
          commentsApi,
          todoApi
        ]
    }

    
    func testRequestURLNotNil() {
        for provider in allRequestProviders {
            try XCTAssertNoThrow(provider.request())
        }
    }
    
    func testURLStringsAreValid() {

        XCTAssertEqual(
            url(for: userApi),
            "https://jsonplaceholder.typicode.com/users"
        )
        XCTAssertEqual(
            url(for: commentsApi),
            "https://jsonplaceholder.typicode.com/comments%3FpostId=2"
        )
        XCTAssertEqual(
            url(for: postApi),
            "http://jsonplaceholder.typicode.com/posts"
        )
        XCTAssertEqual(
            url(for: todoApi),
            "https://jsonplaceholder.typicode.com/todos/2"
        )
    }
    
    private func url(for provider: EXRequestProvider<TestApi>) -> String  {
        guard let url = try? provider.request().url else {
            XCTFail("Failed converting request data to url")
            return ""
        }
        return url.absoluteString
    }
}

// MARK: Test Api Endpoint creation
extension RequestProviderTests {
    fileprivate enum TestApi: API {
        
        var scheme: HTTPScheme {
            switch self {
            case .post: return .http
            default: return .https
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .post: return .get
            default: return .post
            }
        }
        
        var headers: HTTPHeader {
            switch self {
            case .post: return .jsonContent
            default: return ["Authorization": "Bearer abcdefghi"]
            }
        }
        
        var requestParameters: HTTPRequestBody { .none }
        
        var sslContent: SSLContent { .none }
        
        var shouldLog: Bool { false }
        
        var baseURL: String { "jsonplaceholder.typicode.com" }
        
        var endPoint: String {
            switch self {
            case .post: return "/posts"
            case .users: return "/users"
            case .comments(let postID): return "/comments?postId=\(postID)"
            case .todo(let todoPage): return "todos/\(todoPage)"
            }
        }
        
        case post
        case users
        case comments(_ postID: Int)
        case todo(_ page: Int)

    }
}
