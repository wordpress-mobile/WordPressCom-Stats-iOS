import UIKit
#if !MAIN_PROJECT
import WordPressShared
#endif

@objc public class StatsStringUtilities: NSObject {
    public func sanitizePostTitle(postTitle: String) -> String {
        var postTitle = postTitle.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        postTitle = postTitle.stringByDecodingXMLCharacters()
        
        return postTitle
    }
}
