import Foundation
import ParseSwift

import Foundation
import ParseSwift

struct Comment: ParseObject {
    // Required properties by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Custom properties for the Comment
    var content: String?
    var post: Post? // Reference to the related post
    var user: User? // Reference to the user who made the comment
}

