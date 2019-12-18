
import UIKit
import CoreData
import MapKit
import CoreLocation

class CityListViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var citySearchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapContentView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    lazy var locationManager = CLLocationManager()
    lazy var currentLocation = CLLocationCoordinate2D()

    let presenter = CityItemPresenter(provider: CityProvider())
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    func initialSetup() {
        self.title = "City"
        presenter.attachView(view: self)
        mapView.delegate = self
        citiesTableView.tableFooterView = UIView()
        presenter.perFormGetCity()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func closeMapClicked(_ sender: Any) {
        mapView.removeAnnotation(annotation)
        mapContentView.isHidden = true
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        currentLocation = location.coordinate
    }
}

//MARK: - UITableView
extension CityListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.fetchedResultsController.sections?[section].objects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
        guard let city = presenter.fetchedResultsController.fetchedObjects?[indexPath.row] else { return cell }
        
        cell.selectionStyle = .none
        cell.tag = Int(city.cityId)
        cell.city = city
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y/(scrollView.contentSize.height - scrollView.frame.size.height)
        let relativeHeight = 1 - (citiesTableView.rowHeight / (scrollView.contentSize.height - scrollView.frame.size.height))
        if y >= relativeHeight{
            presenter.perFormGetCity()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CityCell else {
            return
        }
        if let city = cell.city {
            annotation.coordinate = CLLocationCoordinate2D(latitude: city.lat, longitude: city.lng)
            annotation.title = city.cityName
            mapView.addAnnotation(annotation)
            mapView.showAnnotations([annotation], animated: true)
            mapContentView.isHidden = false
            
            let locationFrom = CLLocation(latitude: city.lat, longitude: city.lng)
            let locationTo = CLLocation(latitude: currentLocation.latitude,longitude: currentLocation.longitude)
            distanceLabel.text = "\(Int(round(locationFrom.distance(from: locationTo) * 0.000621371))) mi"
        }
    }
}

extension CityListViewController {
    func showAlertView(errorMessage: String) {
        let alertController = UIAlertController(title: Alert.title, message: errorMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Alert.ok, style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UISearchBarDelegate
extension CityListViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        citySearchBar.showsCancelButton = (searchBar.text?.isValid) ?? false
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        citySearchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        citySearchBar.text = ""
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if searchBar.text?.isValid ?? false {
            presenter.getSearchedCity(searchCity: searchBar.text ?? "")
        } else {
            presenter.perFormGetCity(isSearch: true)
        }
    }
}

extension CityListViewController: CityView {
    // NSFRC
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        citiesTableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        citiesTableView.beginUpdates()
    }
    
    func fetchedResultsControllerChangedPredicate() {
        citiesTableView.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            UIView.setAnimationsEnabled(false)
            citiesTableView.insertRows(at: [newIndexPath!], with: .none)
        case .delete:
            UIView.setAnimationsEnabled(false)
            citiesTableView.deleteRows(at: [indexPath!], with: .none)
        case .update:
            UIView.setAnimationsEnabled(false)
            citiesTableView.reloadRows(at: [indexPath!], with: .none)
        default:
            UIView.setAnimationsEnabled(false)
            citiesTableView.reloadData()
            break
        }
    }
    
    func finishWithError(_ error: String?) {
        if error != nil {
            showAlertView(errorMessage: error ?? Errors.genericError)
        }
        citiesTableView.reloadData()
    }
}

