//
//  AppDelegate.swift
//  Petwork
//
//  Created by Iksang Yoo on 2022/05/14.
//

import UIKit
import Firebase
import FirebaseCore
import GoogleSignIn
import IQKeyboardManagerSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate {
   

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Firebase
        FirebaseApp.configure()
        
        // Google Sign In
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
 
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.resignFirstResponder()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("Google Sign In Error: \(error.localizedDescription)")
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        
        Auth.auth().signIn(with: credential) { result, error in
            guard let isNewUser = result?.additionalUserInfo?.isNewUser else { return }
            guard let user = result?.user else { return }
            guard let urlString = user.photoURL?.absoluteString else { return }
            if let err = error {
                print("Firebase Google Login Error: \(err.localizedDescription)")
            }
            
            if isNewUser {
                Database.database().reference().child("users").child(user.uid).setValue(["name": user.displayName, "profileImageURL": urlString, "aboutMe": "Please Set About Me"])
            }
            self.showSetProfileViewController()
        }
    }
    private func showSetProfileViewController() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
        vc.modalPresentationStyle = .fullScreen
//        UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: true)
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
extension UIApplication {
    var keyWindow: UIWindow? {
            // Get connected scenes
            return UIApplication.shared.connectedScenes
                // Keep only active scenes, onscreen and visible to the user
                .filter { $0.activationState == .foregroundActive }
                // Keep only the first `UIWindowScene`
                .first(where: { $0 is UIWindowScene })
                // Get its associated windows
                .flatMap({ $0 as? UIWindowScene })?.windows
                // Finally, keep only the key window
                .first(where: \.isKeyWindow)
        }
}
