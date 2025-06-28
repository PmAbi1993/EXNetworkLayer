# EXNetworkLayer

EXNetworkLayer is a library made to simplify network calls made by our app in an easy to debug manner.

The main **Features** of EXNetworkLayer is:
* **Reduce the impact of adding a third party dependancy** like `Alamofire` or `Moya` or the combination of both in our app when all we have to do are basic network calls.
* **Reduce boilerplate code & App complexity**: I have complied some essential features from multiple sources and created a network library which can be used to cater the needs of our api calls.
* **Secure**: `Certificate based SSL Pinned` are supported out of the box.
* **Cachable responses**: Disk & inMemory caching is supported for the api.
* **Easy Mocking & Unit Testing**: Since mocked urlsessions are already present, you can hit local data from get go without hitting your network endpoints to test your viewmodels and model efficiently.
* **Strong foundation**: Built with `S.O.L.I.D Principles`, `POP` and `Enumerated Absatractions` in mind.
* **Customizable**: Since POP is followed all basic classes are made as blueprints which would enable the end-user to inject thier custom implementations.

## Installation

Currently EXNetworklayer only supports downloads through Swift Package manager. Since we are under active development we would advice against downloading source and manually adding to project

#### Swift Package Manager

``` swift

.package(
    url: "https://github.com/PmAbi1993/EXNetworkLayer",
    .branch("master")
)

```
## Usage

The main use case of EXNetwork layer is to clean and organize your network calls. So we sujjest you to create an enum which can hold the api skeletons.

After adding the EXNetworklayer package import it
``` swift
import EXNetworkLayer

class ViewController: UIViewController {
    
```
Take a look at a list of the below apis

1. https://jsonplaceholder.typicode.com/users
2. https://jsonplaceholder.typicode.com/users/{index}
3. https://jsonplaceholder.typicode.com/posts
4. https://jsonplaceholder.typicode.com/comments?postId=1

These can be represented as abstractions by below enum 
``` swift

enum JSONPlaceHolderAPI {
    case users // this will pull in all users
    case user(id: Int) // This will pull in only one user
    case posts // This will pull in all the posts of the user
    case comments(postID: Int) // Pulls in the comments for the specific post
}

```

This level of abstraction would help us to remove adding any concrete dependancy to our viewmodels. The views can be totally independant from the network implementations.

To add the details of how to call the api, we just have to implement `API` protocol for our enum. *Preferably in an extension of the enum so we have even more clarity*. This will ask us to inject the needed data for executing the api. 

Lets see how all the information of above api can be added to our enum.

``` swift
extension JSONPlaceHolderAPI: API {
    var scheme: HTTPScheme {
        <#code#>
    }
    
    var method: HTTPMethod {
        <#code#>
    }
    
    var headers: HTTPHeader {
        <#code#>
    }
    
    var requestParameters: HTTPRequestBody {
        <#code#>
    }
    
    var baseURL: String {
        <#code#>
    }
    
    var endPoint: String {
        <#code#>
    }
    
    var sslContent: SSLContent {
        <#code#>
    }
    
    var shouldLog: Bool {
        <#code#>
    }
}

```

Nearly all the values that can produce errors from developer side are restricted with enums to provide only specific type values. 

A filled data of api can be as shown below

``` swift
extension JSONPlaceHolderAPI: API {
    var scheme: HTTPScheme { .https }
    var method: HTTPMethod { .get }
    var headers: HTTPHeader { .jsonContent }
    var requestParameters: HTTPRequestBody {
        switch self {
        case .comments(let postID): return .url(params: ["postID": postID])
        default: return .none
        }
    }
    var baseURL: String { "jsonplaceholder.typicode.com" }
    var endPoint: String {
        switch self {
        case .users: return "/users"
        case .user(let id): return "/users/\(id)"
        case .posts: return "/posts"
        case .comments: return "/comments"
        }
    }
    var sslContent: SSLContent {
        .none
    }
    var shouldLog: Bool {
        false
    }
}
```

If we have to provide more request values to api we can create custom implementaion of `API` and extend to our enum. Since all elements are made with `Interface Segregation Principle` in mind, we can plug in our implementations without writing all the features from scratch again.

## Execute the api call

We can use the  concrete implementation of `BasicRequest` called `EXNetworkManager` to execute the api calls.

``` swift
let networkManager: EXNetworkManager<JSONPlaceHolderApi> = EXNetworkManager(
    api: .user(id: 1)
)
networkManager.callApi(responseType: UserData.self) { result in
    switch result {
    case .success(let userData):
        print(userData.name)
        print(userData.username)
        print(userData.email)
    case .failure(let error):
        print(error)
    }
}
```

### Async/Await Support

EXNetworkLayer now supports Swift's `async/await` for a more concise and readable asynchronous code. You can use the `async` versions of `callApi` methods directly.

```swift
@available(iOS 13.0.0, *)
func fetchUser() async {
    let networkManager: EXNetworkManager<JSONPlaceHolderApi> = EXNetworkManager(
        api: .user(id: 1)
    )
    do {
        let userData = try await networkManager.callApi(responseType: UserData.self)
        print(userData.name)
        print(userData.username)
        print(userData.email)
    } catch {
        print(error)
    }
}
```

The `EXNetworkManager` accepts a generic API element. This will ensure we can only pass in the proper data and the manager will return a proper result of the codable data we provided in function signature

## Adding SSL Pinning 

EXNetworkManager has built in capability to execute API call with SSL Pinning from certificate file.

##### Steps to add SSL Pinning to App with EXNetworkManager

1. Download / Obtain the SSL certificate from the concerned team and add the certificate to the bundle of the application
2. In the Implementation of API details, override the values of key `sslContent` to point it to the added certificate file
3. Execute the api call using `EXNetworkManager` concrete implementation. Please note the `BasicRequest` doesn't include the SSLPinning by default. *Implement this in your concrete classes if you want to add these features.*

``` swift
var sslContent: SSLContent {
    .file(bundle: .main, name: "JSONPlaceholder")
}
```

## Caching API Responses

EXNetworkManager has been extended to support multiple types of caching.
The caching implemented is pretty basic and supports only caching of `Codable` items. Currently the layer supports `inMemory` & `inDisk` caching.

##### InMemory Caching

InMemory caching in EXNetworkManager uses `NSCache` in the background. Use this type of caching when you want the least impact on appside. The cache size and invalidation will be handled by ios subsystem by default. Since the cache is based on NSCache which is stored in memory, it will be faster by default.

##### inDisk Caching

InDisk caching is based on storing String JSON value files in the documents directory. Since this is based on persisted data, Use this cache when we have to persist cached data across app lifecycles.

#### Usage

The cache type is set by property injection.
``` swift
let networkManager: EXNetworkManager<JSONPlaceHolderApi> = EXNetworkManager(api: .post)
networkManager.requestCacheType = .inDisk
networkManager.requestCacheType = .inMemory 
```

#### Future Scope

Clear the cache with a configurable expirationHandler and set size limits.

## Mocking Network Responses

Mocking Network responses is an integral part of API development. We have to keep in mind that Unit test cases should not be part of Integration testing. We have to keep integration tests seperate and let the unit test cases run parallelly and efficiently.

The concrete implementaion `EXNetworkManager` supports mocking by default. 

#### Mocking with local JSON files

1. Create a text file with `.json` as the extension and keep the file in application bundle. 
2. Create an implementaion of `MockHTTPClient` and in the constructor pass in the fileName and bundle. Please note to dynamically find the bundle while in seperate bundles and not pass in `.main` in all cases.
3. Create an instance of `EXNetworkManager` and pass in the custom `MockHTTPClient` as constructor injection and continue execution.

> Mocking would also work with Cached network responses.

#### Usage

``` swift
let mockClient: MockHTTPClient = MockHTTPClient(mockData: .jsonFile(bundle: .main,
                                                                    name: "MockPostResponse"))
let networkManager3: EXNetworkManager<JSONPlaceHolderApi> = EXNetworkManager<JSONPlaceHolderApi>(api: .post,
                                                                                                 session: mockClient)
networkManager3.callApi(responseType: UserData.self) { result in
    switch result {
    case .success(let userData):
        print(userData.name)
        print(userData.username)
        print(userData.email)
    case .failure(let error):
        print(error)
    }
}
```

## Customizing blueprints

Most of the building blocks in the Network layer is written with `P.O.P`, *Functionality is not inherited but Injected *,so the individual elements can be extended / created anew without needing to re-write basic implementaion details. Please refer the actual implementaion of `EXNetworkManager` and the generic `BasicRequest` for implementaiton details.

## Future Scope

* Add Multipart file upload by extending `BasicRequest`.
* Complete adding unit test cases and increase code coverage.
* Add CI/CD to the repository.

## ❗️⚠️ Warning ⚠️❗️
> This is an experimental project started with high hopes to learn `S.O.L.I.D`, `P.O.P`, Architectural & Design pattern implementaions in a real life long term project. Use cautiously & push implementation to production only after extensive testing.

## License

EXNetworkLayer is released under an MIT license. See [License.md](https://github.com/PmAbi1993/EXNetworkLayer/blob/main/README.md) for more information.
