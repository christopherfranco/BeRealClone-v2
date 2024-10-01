//
//  FeedViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit

import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    private let refreshControl = UIRefreshControl()
    
    var comments: [Comment] = []
    var selectedPost: Post?
    
    private var posts = [Post]() {
        didSet {
            // Reload table view data any time the posts variable gets updated.
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        queryPosts()
    }

    private func queryPosts(completion: (() -> Void)? = nil) {
        // TODO: Pt 1 - Query Posts
        // Get the date for yesterday. Adding (-1) day is equivalent to subtracting a day.
        // NOTE: `Date()` is the date and time of "right now".
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!

        

        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate) // <- Only include results created yesterday onwards
            .limit(10) // <- Limit max number of returned posts to 10

        // Find and return posts that meet query criteria (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update the local posts property with fetched posts
                self?.posts = posts
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }

            // Call the completion handler (regardless of error or success, this will signal the query finished)
            // This is used to tell the pull-to-refresh control to stop refresshing
            completion?()
        }
    }
    
   // @IBAction func postComment(_ sender: UIButton) {
     //       guard let post = selectedPost, let text = commentTextField.text, !text.isEmpty else { return }
       //     addComment(post: post, content: text)
        //}
    
    
    //user can add a comment
  //  private func addComment(post: Post, content: String) {
    //        guard let currentUser = User.current else {
      //          print("No user logged in")
        //        return
          //  }

            //var comment = Comment()
       //     comment.content = content
         //   comment.post = post
           // comment.user = currentUser

          //  comment.save { result in
            //    switch result {
              //  case .success(let savedComment):
                //    print("Comment saved successfully: \(savedComment)")
            //        self.loadComments(for: post) { comments in
                  //      self.comments = comments ?? []
                    //    self.tableView.reloadData()
                   // }
               // case .failure(let error):
                 //   print("Error saving comment: \(error.localizedDescription)")
          //      }
           // }
        //}
    //end of the add comment method
    
    //start of the load comments method---
  //  private func loadComments(for post: Post, completion: @escaping ([Comment]?) -> Void) {
    //    let query = ParseObject(className: "Comment")
      //  query.whereKey("post", equalTo: post)
        //query.findObjectsInBackground { (objects, error) in
          //  if let comments = objects as? [Comment] {
            //    completion(comments)
           // } else {
             //   print("Error loading comments: \(error?.localizedDescription ?? "Unknown error")")
               // completion(nil)
           // }
        //}
   // }
    //end of the load comments method-----

    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    @objc private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        queryPosts { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of \(User.current?.username ?? "current account")?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        return cell
        
    }
}

extension FeedViewController: UITableViewDelegate { }
