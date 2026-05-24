//
//  PhotosViewController.swift
//  tumblr
//
//  Created by Gerard Recinto on 2/2/17.
//  Copyright © 2017 Gerard Recinto. All rights reserved.
//

import UIKit

@MainActor
class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var PhotoTableView: UITableView!

    private var posts: [[String: Any]] = []
    private var isMoreDataLoading = false
    private var loadingMoreView: InfiniteScrollActivityView?

    private let tumblrURL = URL(string:
        "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV"
    )!

    override func viewDidLoad() {
        super.viewDidLoad()
        PhotoTableView.rowHeight = 240
        PhotoTableView.delegate = self
        PhotoTableView.dataSource = self

        let frame = CGRect(x: 0, y: PhotoTableView.contentSize.height,
                           width: PhotoTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView?.isHidden = true
        PhotoTableView.addSubview(loadingMoreView!)

        var insets = PhotoTableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        PhotoTableView.contentInset = insets

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        PhotoTableView.insertSubview(refreshControl, at: 0)

        Task { await fetchPosts() }
    }

    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl) {
        Task {
            await fetchPosts()
            refreshControl.endRefreshing()
        }
    }

    private func fetchPosts() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: tumblrURL)
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let response = json["response"] as? [String: Any],
                  let results = response["posts"] as? [[String: Any]] else { return }
            posts = results
            PhotoTableView.reloadData()
        } catch {
            print("Fetch error: \(error.localizedDescription)")
        }
    }

    private func loadMoreData() {
        guard !isMoreDataLoading else { return }
        isMoreDataLoading = true
        Task {
            await fetchPosts()
            isMoreDataLoading = false
            loadingMoreView?.stopAnimating()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentHeight = PhotoTableView.contentSize.height
        let threshold = contentHeight - PhotoTableView.bounds.size.height
        if !isMoreDataLoading && scrollView.contentOffset.y > threshold && PhotoTableView.isDragging {
            let frame = CGRect(x: 0, y: contentHeight,
                               width: PhotoTableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
            loadingMoreView?.frame = frame
            loadingMoreView?.startAnimating()
            loadMoreData()
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell
        let post = posts[indexPath.row]
        if let photos = post["photos"] as? [[String: Any]],
           let urlString = (photos.first?["original_size"] as? [String: Any])?["url"] as? String,
           let imageUrl = URL(string: urlString) {
            cell.photoImageView.loadImage(from: imageUrl)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? UITableViewCell,
              let indexPath = PhotoTableView.indexPath(for: cell) else { return }
        let vc = segue.destination as? PhotoDetailsViewController
        let post = posts[indexPath.row]
        if let photos = post["photos"] as? [[String: Any]],
           let urlString = (photos.first?["original_size"] as? [String: Any])?["url"] as? String {
            vc?.photoUrlString = urlString
        }
    }
}

// MARK: - InfiniteScrollActivityView

class InfiniteScrollActivityView: UIView {
    static let defaultHeight: CGFloat = 60.0
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        activityIndicatorView.hidesWhenStopped = true
        addSubview(activityIndicatorView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func startAnimating() {
        isHidden = false
        activityIndicatorView.startAnimating()
    }

    func stopAnimating() {
        activityIndicatorView.stopAnimating()
        isHidden = true
    }
}
