
import UIKit
import CoreData

class CityCell: UITableViewCell {
    
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var localNameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cityContentView.layer.shadowColor = UIColor.gray.cgColor
        cityContentView.layer.shadowOpacity = 1
        cityContentView.layer.shadowOffset = .zero
        cityContentView.layer.shadowRadius = 1
        cityContentView.layer.shouldRasterize = true
        cityContentView.layer.cornerRadius = 5.0
        cityContentView.clipsToBounds = true
        cityContentView.layer.masksToBounds = false
    }
    
    var city: Cities? {
        didSet {
            iconLabel.backgroundColor = getRandomColor()
            iconLabel.layer.cornerRadius = 5.0
            iconLabel.clipsToBounds = true
            iconLabel.text = "\(city?.cityName?.first ?? "?")"
            nameLabel.text = city?.cityName
            localNameLabel.text = city?.localName
            if city?.country != nil {
                countryLabel.text = "\(city?.country ?? "")"
            }else{
                if city?.country != nil {
                    countryLabel.text = "\(city?.country ?? "")"
                }else{
                    countryLabel.text = ""
                }
            }
        }
    }
    
    func getRandomColor() -> UIColor {
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())
        return UIColor(red:red, green: green, blue: blue, alpha: 0.6)
    }
}
