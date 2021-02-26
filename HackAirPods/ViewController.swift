import UIKit
import CoreMotion
import CoreML

class Classifier: NSObject {
    let model = GestureRecognition()
    
    func predict(_ input: Array<MLMultiArray>) -> String {
        guard let modelPrediction = try? model.prediction(AccelerationX: input[0], AccelerationY: input[1], AccelerationZ: input[2], RotationX: input[3], RotationY: input[4], RotationZ: input[5], stateIn: nil) else {
            fatalError("Unable to make prediction")
        }
        return modelPrediction.label
    }
}

class ViewController: UIViewController, CMHeadphoneMotionManagerDelegate {

    @IBOutlet var label: UILabel!
    
    //AirPods Pro => APP :)
    let APP = CMHeadphoneMotionManager()
    let classifier = Classifier()
    var frameCount:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        label.textAlignment = NSTextAlignment.center

        APP.delegate = self
        var inputData = [MLMultiArray]()
        
        guard var Ax = try? MLMultiArray(shape: [100], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard var Ay = try? MLMultiArray(shape: [100], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard var Az = try? MLMultiArray(shape: [100], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard var Rx = try? MLMultiArray(shape: [100], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard var Ry = try? MLMultiArray(shape: [100], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        guard var Rz = try? MLMultiArray(shape: [100], dataType: MLMultiArrayDataType.double) else {
            fatalError("Unexpected runtime error. MLMultiArray")
        }
        
        guard APP.isDeviceMotionAvailable else { return }
        APP.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {[weak self] motion, error  in
            guard let motion = motion, error == nil else { return }
            
            Ax[self!.frameCount] = NSNumber(value: motion.userAcceleration.x)
            Ay[self!.frameCount] = NSNumber(value: motion.userAcceleration.y)
            Az[self!.frameCount] = NSNumber(value: motion.userAcceleration.z)
            Rx[self!.frameCount] = NSNumber(value: motion.rotationRate.x)
            Ry[self!.frameCount] = NSNumber(value: motion.rotationRate.y)
            Rz[self!.frameCount] = NSNumber(value: motion.rotationRate.z)
            
            self!.frameCount = self!.frameCount + 1
            
            if self!.frameCount == 100 {
                inputData.append(contentsOf: [Ax, Ay, Az, Rx, Ry, Rz])
                let result = self?.classifier.predict(inputData)
//                self?.printData(motion)
                print(result ?? "N/A")
                self!.label.text = result
                
                self!.frameCount = 0
                inputData.removeAll()
            }
            self?.printData(motion)
        })
    }

    func printData(_ data: CMDeviceMotion) {
//      print(data.attitude)            // 姿勢 pitch, roll, yaw
//      print(data.gravity)             // 重力加速度
//      print(data.rotationRate)        // 角速度
//        print(data.userAcceleration)    // 加速度
        let acceleration = data.userAcceleration
        let x = round(acceleration.x * 1000) / 10
        let y = round(acceleration.y * 1000) / 10
        let z = round(acceleration.z * 1000) / 10
//        if ((x > 15 || y > 15 || z > 15) || (x < -15 || y < -15 || z < -15)) {
//            print(x, "\t", y, "\t", z)
//        }
        print(acceleration)
//      print(data.magneticField)       // 磁気フィールド　磁気ベクトルを返す
//      print(data.heading)             // 方位角
    }

}
