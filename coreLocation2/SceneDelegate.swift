//
//  SceneDelegate.swift
//  coreLocation2
//
//  Created by Digital on 29/08/21.
//

import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let viewController = MainViewController()
        let navViewController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navViewController
        window?.makeKeyAndVisible()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }



    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

extension SceneDelegate: CLLocationManagerDelegate {
  func locationManager(
    _ manager: CLLocationManager,
    didEnterRegion region: CLRegion
  ) {
    if region is CLCircularRegion {
      handleEvent(for: region)
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didExitRegion region: CLRegion
  ) {
    if region is CLCircularRegion {
      handleEvent(for: region)
    }
  }

  func handleEvent(for region: CLRegion) {
    if UIApplication.shared.applicationState == .active {
      guard let message = note(from: region.identifier) else { return }
      window?.rootViewController?.showAlert(withTitle: nil, message: message)
    } else {
      guard let body = note(from: region.identifier) else { return }
      let notificationContent = UNMutableNotificationContent()
      notificationContent.body = body
      notificationContent.sound = .default
      notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
      let request = UNNotificationRequest(
        identifier: "location_change",
        content: notificationContent,
        trigger: trigger)
      UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
          print("Error: \(error)")
        }
      }
    }
  }

  func note(from identifier: String) -> String? {
    let geotifications = Geotification.allGeotifications()
    let matched = geotifications.first { $0.identifier == identifier }
    return matched?.note
  }
}


