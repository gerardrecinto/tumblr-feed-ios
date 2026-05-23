# Tumblr Feed

![Swift](https://img.shields.io/badge/Swift-3%2B-F05138?logo=swift&logoColor=white)
![iOS 9+](https://img.shields.io/badge/iOS-9%2B-000000?logo=apple&logoColor=white)
![AFNetworking](https://img.shields.io/badge/Networking-AFNetworking-blue)
![UIKit](https://img.shields.io/badge/UIKit-UITableView-lightgrey)
![CocoaPods](https://img.shields.io/badge/CocoaPods-AFNetworking-red)

![Demo](docs/assets/demo2.gif)

> Tumblr photo feed reader that hits the Tumblr v2 `/posts/photo` API endpoint via `URLSession`, renders images with AFNetworking's `UIImageView+AFNetworking` category, and pages results with an `InfiniteScrollActivityView` appended below the table's content area.

## Features

- **Tumblr API Integration:** Fetches the Humans of New York photo feed from `api.tumblr.com/v2/blog/{blog}/posts/photo` with an API key; response JSON is parsed via `JSONSerialization.jsonObject` into an `NSDictionary`, and the `response.posts` array drives the table.
- **AFNetworking Image Loading:** `PhotoCell` exposes a `UIImageView` outlet; `cellForRowAt` calls `setImageWith(URL)` from the `UIImageView+AFNetworking` category, which handles async download, main-queue delivery, and in-memory caching automatically.
- **Original-Size URL Extraction:** Each post dictionary is traversed with `value(forKeyPath: "photos.0.original_size.url")` to extract the highest-resolution image URL available in the API response.
- **Infinite Scroll:** `UIScrollViewDelegate.scrollViewDidScroll` compares `contentOffset.y` against `contentSize.height - bounds.height`; when the threshold is crossed and `isDragging` is true, `isMoreDataLoading` is set to prevent duplicate requests and `loadMoreData()` fires the next page fetch.
- **InfiniteScrollActivityView:** A custom `UIView` subclass holding a `UIActivityIndicatorView` is appended below the table's `contentInset.bottom`; `startAnimating()` unhides it and `stopAnimating()` hides it once the load completes.
- **Pull-to-Refresh:** A `UIRefreshControl` inserted at subview index 0 calls `refreshControlAction(_:)`, which makes a fresh `URLRequest` with `cachePolicy: .reloadIgnoringLocalCacheData` and calls `endRefreshing()` in the completion handler.
- **Photo Detail View:** Selecting a row passes the `original_size.url` string to `PhotoDetailsViewController` via `prepare(for:sender:)`, which calls `setImageWith(URL)` again to render the full-resolution image.

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 3 |
| UI | UIKit, UITableView, UIScrollViewDelegate, Auto Layout |
| Networking | URLSession (data tasks), AFNetworking `UIImageView+AFNetworking` |
| Image Cache | AFNetworking `AFImageDownloader` / `AFAutoPurgingImageCache` |
| API | Tumblr v2 REST API (`/posts/photo` endpoint) |
| Dependencies | CocoaPods — AFNetworking |

## Architecture

`PhotosViewController` is the single root view controller. It owns `posts: [NSDictionary]` populated from the Tumblr API response and acts as both `UITableViewDataSource` and `UIScrollViewDelegate`. Pagination state is tracked with `isMoreDataLoading: Bool` to prevent overlapping requests. `PhotoDetailsViewController` is a lightweight detail screen that receives only the image URL string and renders it with `UIImageView+AFNetworking`. The `InfiniteScrollActivityView` is a self-contained `UIView` subclass with its own `UIActivityIndicatorView` lifecycle.

## Key Implementation

**Infinite scroll threshold:** `scrollViewDidScroll` computes `scrollOffsetThreshold = contentSize.height - bounds.size.height` and checks `contentOffset.y > scrollOffsetThreshold && isDragging` to trigger `loadMoreData()` exactly once per drag gesture.

**Image loading:** `cell.photoImageView.setImageWith(imageUrl)` dispatches the download on a background thread via `AFImageDownloader`'s shared session manager, then sets the image on the main thread — no manual `DispatchQueue.main.async` required.

**JSON traversal:** `responseDictionary["response"] as! NSDictionary` then `["posts"] as! [NSDictionary]` matches the Tumblr v2 envelope structure; each post's photo URL is extracted with `value(forKeyPath: "photos.0.original_size.url")`.

## Setup

```bash
git clone https://github.com/gerardrecinto/tumblr-feed-ios.git
cd tumblr-feed-ios
pod install
open tumblr.xcworkspace
```

The Tumblr API key is embedded in the request URL. Replace it with your own key from [https://www.tumblr.com/oauth/apps](https://www.tumblr.com/oauth/apps) if the current key is revoked.
