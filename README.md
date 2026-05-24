# Tumblr Feed

![Swift](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)
![iOS 16+](https://img.shields.io/badge/iOS-16%2B-000000?logo=apple&logoColor=white)
![UIKit](https://img.shields.io/badge/UIKit-UITableView-lightgrey)
![CocoaPods](https://img.shields.io/badge/CocoaPods-URLSession (native)| Layer | Technology |
|---|---|
| Language | Swift 6.0 |
| UI | UIKit, UITableView, UIScrollViewDelegate, Auto Layout |
| Networking | URLSession (data tasks), URLSession (native)|
| Image Cache | URLSession (native)|
| API | Tumblr v2 REST API (`/posts/photo` endpoint) |
| Dependencies | CocoaPods — URLSession (native)|

## Architecture

`PhotosViewController` is the single root view controller. It owns `posts: [NSDictionary]` populated from the Tumblr API response and acts as both `UITableViewDataSource` and `UIScrollViewDelegate`. Pagination state is tracked with `isMoreDataLoading: Bool` to prevent overlapping requests. `PhotoDetailsViewController` is a lightweight detail screen that receives only the image URL string and renders it with `UIImageView+URLSession (native)