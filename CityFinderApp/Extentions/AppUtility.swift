
import UIKit
import Foundation

class AppUtility: NSObject {

    //MARK: -
    static let shared = AppUtility()
    public static var appDelegate : AppDelegate! {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    override init() {
        super.init()
    }

    class func RGBACOLOR(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: (red) / 255.0, green: (green) / 255.0, blue: (blue) / 255.0, alpha: alpha)
    }

    class func RGBCOLOR(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return RGBACOLOR(red: red, green: green, blue: blue, alpha: 1)
    }
}
