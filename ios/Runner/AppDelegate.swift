// Copyright (c) 2022 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical
// or instructional purposes related to programming, coding, application
// development, or information technology.  Permission for such use, copying,
// modification, merger, publication, distribution, sublicensing, creation of
// derivative works, or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import Flutter
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    // 1
    private var flutterResult: FlutterResult? = nil
    // 2
    private var fetchLimit: Int = 0
    // 3
    private var fetchResult: PHFetchResult<PHAsset>? = nil
    
    private func requestImage(width: Double, height: Double, asset: PHAsset, onComplete: @escaping (Data) -> Void) {
        let size = CGSize.init(width: width, height: height)
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        PHImageManager
            .default()
            .requestImage(for: asset, targetSize: size, contentMode: .default, options: option) { image, _ in
                guard let image = image,
                      let data = image.jpegData(compressionQuality: 1.0) else { return }
                onComplete(data)
            }
    }
    
    private func fetchImage(args: Dictionary<String, Any>?, result: @escaping FlutterResult) {
        // 1
        let id = args?["id"] as! String
        let width = args?["width"] as! Double
        let height = args?["height"] as! Double

        // 2
        self.fetchResult?.enumerateObjects { (asset: PHAsset, count: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if (asset.localIdentifier == id) {
                // 3
                stop.pointee = true
                // 4
                self.requestImage(width: width, height: height, asset: asset) { data in
                    // 5
                    result(data)
                }
                return
            }
        }

    }
    
    private func getPhotos() {
        PHPhotoLibrary.requestAuthorization { (status) in
            if (status == .authorized) {
                let options = PHFetchOptions()
                options.fetchLimit = self.fetchLimit
                options.sortDescriptors =
                    [NSSortDescriptor(key: "creationDate", ascending: false)]
                self.fetchResult = PHAsset.fetchAssets(with: .image, options: options)

                var results: [String] = []
                self.fetchResult?.enumerateObjects { asset, count, stop in
                    results.append(asset.localIdentifier)
                }
                self.flutterResult?(results)
            } else {
                let error =
                    FlutterError
                    .init(code: "0", message: "Not authorized", details: status)
                self.flutterResult?(error)
            }
        }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = (window?.rootViewController as! FlutterViewController)
        // 1
        let methodChannel =
            FlutterMethodChannel(name: "com.raywenderlich.photos_keyboard", binaryMessenger: controller.binaryMessenger)
        // 2
        methodChannel
            .setMethodCallHandler({ [weak self](call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "getPhotos":
                // 3
                self?.fetchLimit = call.arguments as! Int
                self?.flutterResult = result
                self?.getPhotos()
            default:
                // 4
                result(FlutterMethodNotImplemented)
            }
        })
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
