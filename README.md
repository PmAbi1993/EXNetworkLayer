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
The EXNetworkManager accepts a generic API element. This will ensure we can only pass in the proper data and the manager will return a proper result of the codable data we provided in function signature
