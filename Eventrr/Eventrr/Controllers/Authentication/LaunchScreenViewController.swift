import UIKit

class LaunchScreenViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    // MARK: - Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        animateLogo()
    }
    
    // MARK: - Private Methods
    
    private func animateLogo() {
        let secondsForFirstAnimation = 0.8
        
        /* Move image from bottom to the middle */
        UIView.animate(withDuration: secondsForFirstAnimation, animations: {
            self.logoImageView.center = self.view.center
        })
        
        /* Fade the image out */
        UIView.animate(withDuration: 0.5, delay: secondsForFirstAnimation + 0.2, animations: {
            self.logoImageView.alpha -= 1
        }) { animationCompleted in
            if animationCompleted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.showLoginViewController()
                })
            }
        }
    }
    
    private func showLoginViewController() {
        let storyboard = UIStoryboard(name: K.MainStoryboardIdentifiers.mainBundle, bundle: nil)
        let authNavigationController = storyboard.instantiateViewController(withIdentifier: K.MainStoryboardIdentifiers.authNavigationController)
        
        authNavigationController.modalTransitionStyle = .crossDissolve
        authNavigationController.modalPresentationStyle = .fullScreen
        
        present(authNavigationController, animated: true)
    }
}

