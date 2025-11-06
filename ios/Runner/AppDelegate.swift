import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    // Kunci API Maps di iOS
    GMSServices.provideAPIKey("GANTI_DENGAN_KUNCI_API_ANDA") 
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}