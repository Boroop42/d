import Foundation

struct PikoPreferences: Codable, Equatable {
    var enableEnhancements = true
    var hidePromotedPosts = false
    var hidePromotedTrends = false
    var hideRecommendedUsers = false
    var hideViewCount = false
    var postFontPercent = 100.0
    var hideNativeToolbar = false
}
