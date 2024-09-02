import UIKit
import FirebaseCore
import FirebaseFirestore
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        let _ = Firestore.firestore()
        
        do {
            try _ = Realm()
            print(Realm.Configuration.defaultConfiguration.fileURL!)
        } catch {
            print(error)
        }
        
        let _ = NetworkConnectionStatusService.shared
        
        return true
    }
}

