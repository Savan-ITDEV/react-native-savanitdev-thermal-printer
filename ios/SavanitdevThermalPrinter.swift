import Darwin
import UIKit
import Foundation
import CoreBluetooth
import CoreImage

class PrinterManager {
    var connectedPrinterMap: [String: WIFIConnecter] = [:]

    func addPrinter(id: String, printer: WIFIConnecter) {
        connectedPrinterMap[id] = printer
        printer.connect(withHost: id, port: 9100)
    }

    func removePrinter(id: String) {
        connectedPrinterMap.removeValue(forKey: id)
    }

    func getPrinter(id: String) -> WIFIConnecter? {
        return connectedPrinterMap[id]
    }
    
    func listPrinters() -> [String: WIFIConnecter] {
        return connectedPrinterMap
    }
}



@objc(SavanitdevThermalPrinter)
class SavanitdevThermalPrinter: NSObject, POSWIFIManagerDelegate,WIFIConnecterDelegate,CBCentralManagerDelegate,POSBLEManagerDelegate {
    

var rssiList: [NSNumber] = []
var dataArr: [CBPeripheral] = []
    
var wifiTSCManager: TSCWIFIManager!

var connectedPrinterList: [WIFIConnecter] = []
var connectedPrinterBTList: [POSBLEManager] = []
    
 var startTime: Date?
 var connectResolve: RCTPromiseResolveBlock?
 var connectReject: RCTPromiseRejectBlock?
 var centralManager: CBCentralManager!
 var addressCurrent = "";
 var btManager: POSBLEManager!
 var statusBLE :Bool=false
 var setPrinter = Data();
    // Usage:
    let printerManager = PrinterManager()
 
    
    @objc
    func initializePrinter() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.btManager = POSBLEManager.sharedInstance()
        self.btManager.delegate = self
    }
 
    
    @objc
    func startScanBLE() {
        self.btManager.startScan()
    }
    
    @objc
    func startQuickDiscovery(_ resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        if #available(iOS 16.4, *) {
            scanDevicesInLocalNetwork(resolver: resolver,rejecter: rejecter)
        } else {
            // Fallback on earlier versions
        }
       
    }
    
    // MARK: - WIFIConnecterDelegate Methods
        func wifiPOSConnected(toHost ip: String, port: UInt16, mac: String) {
            print("wifiPOSConnected Printer IP: \(ip), Printer MAC: \(port) connection succeeded \(mac)")
            connectResolve?("CONNECTED")
            connectResolve = nil
            connectReject = nil
        }
    
    func wifiPOSDisconnectWithError(_ error: Error?, mac: String, ip: String) {
        print("wifiPOSDisconnectWithError Printer IP: \(ip), Printer MAC: \(mac) write success")
    
        if let printer = printerManager.getPrinter(id: ip)
        {
            printer.disconnect()
            printerManager.removePrinter(id: ip)
            connectReject?("ERROR","DISCONNECT",error)
        
        }else{
            connectReject?("ERROR","NO_PRINTER_CONNECT",nil)
        }
        connectResolve = nil
        connectReject = nil
       
    }

        func wifiPOSWriteValue(withTag tag: Int, mac: String, ip: String) {
            print("wifiPOSWriteValue Printer \(tag) IP: \(ip), Printer MAC: \(mac) write success")
            connectResolve?("PRINT_DONE")
            connectResolve = nil
            connectReject = nil
        }

        func wifiPOSReceiveValue(for data: Data, mac: String, ip: String) {
            print("wifiPOSReceiveValue Printer IP: \(ip), Printer MAC: \(mac) receive success")
        }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
                       case .unknown:
                           print("Bluetooth status is UNKNOWN")
                       case .resetting:
                           print("Bluetooth status is RESETTING")
                       case .unsupported:
                           print("Bluetooth is NOT SUPPORTED on this device")
                       case .unauthorized:
                           print("Bluetooth is NOT AUTHORIZED for this app")
                       case .poweredOff:
                       statusBLE = false;
                           print("Bluetooth is currently POWERED OFF")
                           // Handle the case when Bluetooth is turned off
                       case .poweredOn:
                       statusBLE = true;
                           print("Bluetooth is currently POWERED ON")
                           // Handle the case when Bluetooth is turned on
                       @unknown default:
                           print("A previously unknown state occurred")
       }
    }
    func poSbleConnect(_ peripheral: CBPeripheral!) {
        print("poSbleConnect ")
        connectResolve?("CONNECTED")
         connectResolve = nil
         connectReject = nil
    }
    
    func poSbleFail(toConnect peripheral: CBPeripheral!, error: (any Error)!) {
        print("poSbleFail ")
        connectReject?("ERROR","BT_ERROR",nil)
        connectResolve = nil
        connectReject = nil
    }
    
    func poSbleDisconnectPeripheral(_ peripheral: CBPeripheral!, error: (any Error)!) {
        self.btManager.startScan();
        print("poSbleDisconnectPeripheral ")
        self.btManager.disconnectRootPeripheral();
        connectReject?("ERROR","DISCONNECT",nil)
        connectResolve = nil
        connectReject = nil
    }
    
    func poSbleUpdatePeripheralList(_ peripherals: [Any]!, rssiList: [Any]!) {
        if let peripherals = peripherals as? [CBPeripheral], let rssiList = rssiList as? [NSNumber] {
                   self.dataArr = peripherals
                   self.rssiList = rssiList
                     print("update BLE devices : \(String(describing: peripherals))");
          }
    }
    
    func poSbleWriteValue(for character: CBCharacteristic!, error: (any Error)!) {
        if error != nil {
            connectReject?("ERROR","PRINT_ERROR",nil)
          
            }
        print("poSbleWriteValue ")
        // Safely unwrap characteristic
        if character != nil  {
             connectResolve?("PRINT_DONE")
          
         }
       
        connectResolve = nil
        connectReject = nil
    }
    
    func poSbleReceiveValue(for character: CBCharacteristic!, error: (any Error)!) {
        print("poSbleReceiveValue \(character.description) ")
        
    }
    
    func poSbleCentralManagerDidUpdateState(_ state: Int) {
        self.btManager.startScan();
        print("poSbleCentralManagerDidUpdateState")
    }
    
 
    

    // controller WIFI

    @objc
    func connectNet(_ ip :String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        print("connectNet ")
     
        // Access a printer by its ID
        if printerManager.getPrinter(id: ip) != nil {
            resolver("CONNECTED")
        }else{
            connectResolve = resolver
            connectReject = rejecter
            // Add a printer with an ID
            let printer = WIFIConnecter()
            printer.delegate = self
            printerManager.addPrinter(id: ip, printer: printer)
        }
    }
   
    
    @objc
    func disConnect(_ ip :String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        connectResolve = resolver
        connectReject = rejecter
        if let printer = printerManager.getPrinter(id: ip)
        {
            printer.disconnect()
        }
        else{
          connectReject?("ERROR","DISCONNECT_ERROR",nil)
          }
      }
    
    @objc
    func getStatus(_ ip: String,resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock){
        if let printer = printerManager.getPrinter(id: ip) {
                printer.labelPrinterStatus { (statusData: Data?) in
                    var status: UInt8 = 0
                        // Check the length of the data and extract the correct byte
                    if statusData!.count == 1 {
                        let byte = [UInt8](statusData!)[0]
                            status = byte
                    } else if statusData!.count == 2 {
                        let byte = [UInt8](statusData!)[1]
                            status = byte
                        }

                        // Prepare status message based on the status byte
                        let statusMessage: String
                        switch status {
                        case 0x00:
                            statusMessage = "Ready"
                        case 0x01:
                            statusMessage = "Cover opened"
                        case 0x02:
                            statusMessage = "Paper jam"
                        case 0x03:
                            statusMessage = "Cover opened and paper jam"
                        case 0x04:
                            statusMessage = "Paper end"
                        case 0x05:
                            statusMessage = "Cover opened and Paper end"
                        case 0x08:
                            statusMessage = "No Ribbon"
                        case 0x09:
                            statusMessage = "Cover opened and no Ribbon"
                        case 0x10:
                            statusMessage = "Pause"
                        case 0x20:
                            statusMessage = "Printing.."
                        default:
                            statusMessage = "Unknown status"
                        }

                        // Set the resolved message to the resolver
                        resolver(statusMessage)
                }
            } else {
                rejecter("printer_not_found", "Printer not found for IP: \(ip)", nil)
            }
    }
    
    @objc
    func printRawDataESC(_ ip :String,base64String :String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        connectResolve = resolver
        connectReject = rejecter
        if let printer = printerManager.getPrinter(id: ip)
        {
            if let data = Data(base64Encoded: base64String) {
                printer.writeCommand(with: data)
//                connectResolve?("SUCCESS")
            }
            else{
                rejecter("ERROR","CONVERT_IMG_ERROR",nil)
            }
        }else{
            rejecter("ERROR","PRINT_ERROR",nil)
        }
       
    }
    
   
    @objc
    func printImgZPL(_ ip :String,base64String :String,width : Int,printCount :Int, x : Int,y : Int, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
       
            if let imageData = Data(base64Encoded: base64String) {
                if let image = UIImage(data: imageData) {
                   
                    var dataM = Data(ZPLCommand.xa())
                    dataM.append(ZPLCommand.setLabelWidth(Int32(width)))
                    dataM.append(ZPLCommand.drawImageWithx(Int32(x), y: Int32(y), image: image))
                    dataM.append(ZPLCommand.setPageCount(Int32(printCount)))
                    dataM.append(ZPLCommand.xz())
                    if let printer = printerManager.getPrinter(id: ip)
                    {
                    printer.writeCommand(with: dataM)
                    resolver("SUCCESS")
                    }else{
                    self.sendConfigNet(ip,data: dataM as Data)
                    }
//
                }else{
                    rejecter("ERROR","CONVERT_IMG_ERROR",nil)
                }
            }else{
                rejecter("ERROR","ENCODE_ERORR",nil)
            }
        
    }
    @objc
    func printImgTSPL(_ ip :String,base64String :String,width : Int,height : Int, x : Int,y : Int, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        if let printer = printerManager.getPrinter(id: ip)
        {
            if let imageData = Data(base64Encoded: base64String) {
                if let image = UIImage(data: imageData) {
                    var dataM = Data(TSCCommand.sizeBymm(withWidth: Double(width), andHeight: Double(height)))
                    dataM.append(TSCCommand.bitmapWith(x: Int32(x), andY: Int32(y), andMode: 0, andImage: image))
                    dataM.append(TSCCommand.print(1))
                    printer.writeCommand(with: dataM)
                    resolver("SUCCESS")
                }else{
                    rejecter("ERROR","CONVERT_IMG_ERROR",nil)
                }
            }else{
                rejecter("ERROR","ENCODE_ERORR",nil)
            }
        }else{
            rejecter("ERROR","PRINT_ERROR",nil)
        }
       
    } 
    @objc
    func printImgCPCL(_ ip :String,base64String :String,width : Int,height : Int, x : Int,y : Int, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        if let printer = printerManager.getPrinter(id: ip)
        {
            if let imageData = Data(base64Encoded: base64String) {
                if let image = UIImage(data: imageData) {
                    var dataM = Data(CPCLCommand.setPageWidth(Int32(width)))
                    dataM.append(CPCLCommand.initLabel(withHeight: Int32(height)))
                    dataM.append(CPCLCommand.drawImageWithx(Int32(x), y: Int32(y), image: image))
                    dataM.append(CPCLCommand.print())
                    printer.writeCommand(with: dataM)
                    resolver("SUCCESS")
                }else{
                    rejecter("ERROR","CONVERT_IMG_ERROR",nil)
                }
            }else{
                rejecter("ERROR","ENCODE_ERORR",nil)
            }
        }else{
            rejecter("ERROR","PRINT_ERROR",nil)
        }
  
    }
    @objc
    func printImgESC(_ ip :String,base64String :String,width : Int, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        if let printer = printerManager.getPrinter(id: ip)
        {
            if let imageData = imageCompressForWidthScale(imagePath: base64String, targetWidth: CGFloat(width)) {
//                if let image = UIImage(data: imageData) {
//                    let img = self.monoImg(image: image, threshold: 0.1)
                    let align:Data=POSCommand.selectAlignment(1);
                    let Hight :Data=POSCommand.printAndFeedLine();
                    let imgData:Data=POSCommand.printRasteBmp(withM: RasterNolmorWH, andImage: imageData, andType: Dithering);
                    let cut:Data=POSCommand.selectCutPageModelAndCutpage(withM: 1, andN: 1);
                      let spaceH1 = Data("    ".utf8);
                       let spaceH2 = Data("    ".utf8);
                    let concatenatedData = align + imgData + cut + spaceH1 + spaceH2 + Hight
                    printer.writeCommand(with: concatenatedData)
                    resolver("SUCCESS")
//                }else{
//                    rejecter("ERROR","CONVERT_IMG_ERROR",nil)
//                }
            }else{
                rejecter("ERROR","ENCODE_ERORR",nil)
            }
        }else{
            rejecter("ERROR","PRINT_ERROR",nil)
        }
     
    }
    
    func imageCompressForWidthScale(imagePath: String, targetWidth: CGFloat) -> UIImage? {
         let imageData = Data(base64Encoded: imagePath)
            // Load UIImage from imagePath
        guard let image = UIImage(data: imageData!) else {
                print("Failed to load image from base64String: \(imageData)")
                return nil
            }
            
            // Convert to grayscale and black & white
            guard let sourceImage = convertToGrayScaleWithBlackAndWhite(sourceImage: image) else {
                print("Failed to convert image to grayscale/black-and-white.")
                return nil
            }
            
            let imageSize = sourceImage.size
            let width = imageSize.width
            let height = imageSize.height
            let targetHeight = height / (width / targetWidth)
            let size = CGSize(width: targetWidth, height: targetHeight)
            
            var scaleFactor: CGFloat = 0.0
            var scaledWidth = targetWidth
            var scaledHeight = targetHeight
            var thumbnailPoint = CGPoint.zero
            
            if imageSize != size {
                let widthFactor = targetWidth / width
                let heightFactor = targetHeight / height
                
                if widthFactor > heightFactor {
                    scaleFactor = widthFactor
                } else {
                    scaleFactor = heightFactor
                }
                
                scaledWidth = width * scaleFactor
                scaledHeight = height * scaleFactor
                
                if widthFactor > heightFactor {
                    thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
                } else if widthFactor < heightFactor {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
                }
            }
            
            UIGraphicsBeginImageContext(size)
            
            var thumbnailRect = CGRect.zero
            thumbnailRect.origin = thumbnailPoint
            thumbnailRect.size.width = scaledWidth
            thumbnailRect.size.height = scaledHeight
            
            sourceImage.draw(in: thumbnailRect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            if newImage == nil {
                print("Failed to scale image")
            }
            UIGraphicsEndImageContext()
            return newImage
        
        
    }
    
    func convertToGrayScaleWithBlackAndWhite(sourceImage: UIImage?) -> UIImage? {
        guard let sourceImage = sourceImage else {
            print("Source image is nil")
            return nil
        }

        let size = sourceImage.size
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        // Create a new image context with grayscale color space
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Draw the image in grayscale
        sourceImage.draw(in: rect, blendMode: .luminosity, alpha: 1.0)

        // Get the grayscale image from the context
        let grayImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the context
        UIGraphicsEndImageContext()

        // Convert the grayscale image to black and white
        guard let cgGrayImage = grayImage?.cgImage else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceGray()
        guard let bitmapContext = CGContext(data: nil,
                                            width: Int(size.width),
                                            height: Int(size.height),
                                            bitsPerComponent: 8,
                                            bytesPerRow: Int(size.width),
                                            space: colorSpace,
                                            bitmapInfo: CGImageAlphaInfo.none.rawValue) else {
            return nil
        }

        bitmapContext.draw(cgGrayImage, in: rect)
        guard let bwImageRef = bitmapContext.makeImage() else { return nil }
        
        let bwImage = UIImage(cgImage: bwImageRef)

        return bwImage
    }
    @objc
    func printTestESC(_ ip :String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        connectResolve = resolver
        connectReject = rejecter
        if let printer = printerManager.getPrinter(id: ip)
        {
            if let data = Data(base64Encoded: "G0AbdBUbYQHgqtfozcG16M2h0brgpMPX6M2nu8PU6bnK0+DD56gKDQoNos2izbqk2LMKDR1WQgA=") {
                printer.writeCommand(with: data)
                connectResolve?("SUCCESS")
            }
        }else{
            connectReject?("","PRINT_ERROR",nil)
        }
      
    }
    
    @objc
    func cutESC(_ ip :String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        connectResolve = resolver
        connectReject = rejecter
        if let printer = printerManager.getPrinter(id: ip)
        {
            if let data = Data(base64Encoded: "G0AdVkIA") {
                printer.writeCommand(with: data)
                connectResolve?("SUCCESS")
            }
        }else{
            connectReject?("ERROR","PRINT_ERROR",nil)
        }
       
    }
    
    // BlueTOOTH
    
  @objc
  func getListDevice(_ id :String, resolver resolve: @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) {
   if(self.statusBLE == true){
        if dataArr.count > 0 {
            var arr: [[String: Any]] = []
            for peripheral in dataArr {
                let peripheralDict: [String: Any] = [
                    "identifier": peripheral.identifier.uuidString,
                    "name": peripheral.name ?? "Unknown"
                ]
             
                arr.append(peripheralDict)
            }
            print("found device: \(arr)")
            resolve(arr)
        } else {
            print("not found device")
            reject("ERROR", "NOT_FOUND", nil)
        }
        }else{
            reject("ERROR","BT_NOT_ENABLE", nil)
        }
    }
    func getStatusBT(){
        self.btManager.printerStatus {(responseData: Data?) in
                         if responseData!.count == 1 {
                             let byte = [UInt8](responseData!)
                                let status = byte[0]
     
                                switch status {
                                case 0x12:
                                    print("Ready")
     
                                case 0x16:
                                    print("Cover opened")
     
                                case 0x32:
                                    print("Paper end")
     
                                case 0x36:
                                    print("Cover opened & Paper end")
     
                                default:
                                    print("Error")
     
                                }
                            }
                     }
    }
    @objc
    func connectBLE(_ identifiers :String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
                connectResolve = resolver
                connectReject = rejecter
            if let peripheral = dataArr.first(where: { $0.identifier.uuidString == identifiers }){
             print("connectBLE ")
                self.btManager.connectDevice(peripheral);

            }else{
                self.btManager.startScan();
                rejecter("ERROR","CONNECT_FAIL", nil)
            }
           
    }
    
    @objc
    func disConnectBLE(_ id :String, resolver resolve :  @escaping RCTPromiseResolveBlock,
      rejecter reject: @escaping RCTPromiseRejectBlock) {
        if(self.statusBLE == true){
            do {
                try self.btManager.disconnectRootPeripheral();               
                print("disconnect")
                resolve("DISCONNECT")
            } catch {
               
                print("Failed disconnect: \(error)")
                reject("ERROR","DISCONNECT_FAIL", nil)
            }
        }else{
            reject("ERROR","BT_NOT_ENABLE", nil)
        }
    }
    
    @objc
    func checkStatusBLE(_ id :String, resolver resolve :  @escaping RCTPromiseResolveBlock,
      rejecter reject: @escaping RCTPromiseRejectBlock) {
        if(self.statusBLE == true){
      do {
          print("checkStatusBLE")
          let status = try self.btManager.printerIsConnect() ? "CONNECTED" :"DISCONNECT"
          resolve(status)
       } catch {
          print("Failed disconnect: \(error)")
          reject("ERROR","DISCONNECT", nil)
      }
        }else{
            print("your ble is not enable")
            reject("ERROR","BT_NOT_ENABLE", nil)
        }
    }
    
    @objc
    func rawDataBLE(_ base64String :String, resolver resolve :  @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        if(self.statusBLE == true){
     if let data = Data(base64Encoded: base64String) {
      do {
          connectResolve = resolve
          connectReject = reject
          try  self.btManager.writeCommand(with: data)
      } catch {
          print("Failed to send command: \(error)")
          reject("ERROR","PRINT_FAIL", nil)
      }
      }else{
        print("Failed to decode base64 string into data.")
          reject("ERROR","PRINT_FAIL_BASE64", nil)
        
       }
        }else{
            reject("ERROR","BT_NOT_ENABLE", nil)
        }
    }
    
    @objc
    func image64BaseBLE(_ base64String :String, resolver resolve :  @escaping RCTPromiseResolveBlock,
                        rejecter reject: @escaping RCTPromiseRejectBlock) {
        if(self.statusBLE == true){
            if let imageData = Data(base64Encoded: base64String) {
                if UIImage(data: imageData) != nil {
                     self.btManager.writeCommand(with: imageData)
                    resolve("PRINT_DONE")
                }else{
                    reject("ERROR","CONVERT_IMG_ERROR",nil)
                }
            }else{
                reject("ERROR","ENCODE_ERORR",nil)
            }
        }
        else{
            reject("ERROR","BT_NOT_ENABLE", nil)
        }
    }
    
    // MARK: - Ping IP Methods
    @objc
    func pingDevice(_ ip :String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
        if #available(iOS 12.0, *) {
            pingWithNWConnection(to: ip,resolver:resolver,rejecter: rejecter)
        } else {
            // Fallback on earlier versions
        };
    }


    
    
    // Convert color image
    func monoImg(image: UIImage, threshold: CGFloat = 0.1) -> UIImage? {
             // Convert UIImage to CIImage
             guard let ciImage = CIImage(image: image) else { return nil }
             
             // Convert to grayscale
             let grayscaleFilter = CIFilter(name: "CIColorControls")
             grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
             grayscaleFilter?.setValue(0.0, forKey: kCIInputSaturationKey)  // Remove color
             grayscaleFilter?.setValue(1.0, forKey: kCIInputContrastKey)    // Maximize contrast
             
             guard let grayscaleImage = grayscaleFilter?.outputImage else { return nil }
             
             // Apply threshold to create black and white effect
             let thresholdFilter = CIFilter(name: "CIColorMatrix")
             thresholdFilter?.setValue(grayscaleImage, forKey: kCIInputImageKey)
             
             // Set the threshold to control black and white conversion
             let thresholdVector = CIVector(x: threshold, y: threshold, z: threshold, w: 0)
             thresholdFilter?.setValue(thresholdVector, forKey: "inputRVector")
             thresholdFilter?.setValue(thresholdVector, forKey: "inputGVector")
             thresholdFilter?.setValue(thresholdVector, forKey: "inputBVector")
             thresholdFilter?.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
             
             guard let outputCIImage = thresholdFilter?.outputImage else { return nil }
             
             // Create a context and convert to UIImage
             let context = CIContext(options: nil)
             if let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                 return UIImage(cgImage: cgImage)
             }
             
             return nil
         }
    
        @objc
        func byteMerger(byte1: [UInt8], byte2: [UInt8]) -> [UInt8] {
            var byte3 = [UInt8]()
            byte3.append(contentsOf: byte1)
            byte3.append(contentsOf: byte2)
            return byte3
        }
    
    @objc
    func setLang(_ ip:String,codepage :String) {
            if let codepageInt = UInt8(codepage) {
                let byte1: [UInt8] = [31, 27, 31, 255]
                let byte2: [UInt8] = [codepageInt, 10, 0]
                let mergedBytes = byteMerger(byte1: byte1, byte2: byte2)
                let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
               if(ip.isEmpty){
                   self.sendConfigNet(ip,data: data as Data)
              }
            }
        }
        @objc
    func printLangPrinter(_ ip:String) {
            let byte1: [UInt8] = [27, 64, 28, 46, 27, 33, 0, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 0, 0, 0, 0, 0, 10]
            let byte2: [UInt8] = [27, 64, 29, 86, 65, 72, 28, 38, 0]
            let mergedBytes = byteMerger(byte1: byte1, byte2: byte2)
            let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
            if(ip.isEmpty){
                self.sendConfigNet(ip,data: data as Data)
           }
        
        }
        @objc
    func getLangModel(_ ip:String) {
            let byte1: [UInt8] = [31, 27, 31, 103]
            let byte2: [UInt8] = [/* your second byte array */]

            let mergedBytes = byteMerger(byte1: byte1, byte2: byte2)
            let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
        if(ip.isEmpty){
            self.sendConfigNet(ip,data: data as Data)
        }
        }
        @objc
        func cancelChinese(_ ip:String) {
            let byte1: [UInt8] = [31, 27, 31, 191, 8, 0]
            let byte2: [UInt8] = [/* your second byte array */]

            let mergedBytes = byteMerger(byte1: byte1, byte2: byte2)
            let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
            if(ip.isEmpty){
                self.sendConfigNet(ip,data: data as Data)
            }
        }
    
    
    @objc
       func sendConfigNet(_ ip:String,data : Data) -> Void   {
           if isValidIPAddress(ip) {
               if let printer = printerManager.getPrinter(id: ip)
               {
                   printer.writeCommand(with: data)
               }
              }else{
                  self.btManager.writeCommand(with: data)
              }
        }
    
    func isValidIPAddress(_ ipAddress: String) -> Bool {
        let components = ipAddress.split(separator: ".")
        
        // Check if it has exactly 4 components
        if components.count != 4 {
            return false
        }
        
        // Check if each component is a number between 0 and 255
        for component in components {
            if let number = Int(component), number >= 0 && number <= 255 {
                continue
            } else {
                return false
            }
        }
        
        return true
    }
  
    @objc
    func printTemplate(_ ip:String,isDisconnect:Bool,resolver resolve : @escaping RCTPromiseResolveBlock,
                       rejecter reject: @escaping RCTPromiseRejectBlock) -> Void   {
        connectResolve = resolve
        connectReject = reject
        self.sendConfigNet(ip,data: self.setPrinter)
    }
    
    @objc
     func clearPaper(_ resolve :  @escaping RCTPromiseResolveBlock,
                     rejecter reject: @escaping RCTPromiseRejectBlock) {
         self.setPrinter.removeAll();
         resolve("CLEAR_DONE");
    }
    @objc
    func initializeText() {
        let body: Data = POSCommand.initializePrinter();
        self.setPrinter.append(body)
        }
    @objc
       func cut() {
         let cut: Data = POSCommand.selectCutPageModelAndCutpage(withM: 1, andN: 1)
           self.setPrinter.append(cut)
        }
    @objc
       func printAndFeedLine() {
         let body: Data = POSCommand.printAndFeedLine()
           self.setPrinter.append(body)
        }
    @objc
         func CancelChineseCharModel() {
             let body: Data = POSCommand.cancelChineseCharModel()
             self.setPrinter.append(body)
        }
    @objc
        func selectAlignment(_ n :Int) {
         
            let  data :Data = POSCommand.selectAlignment(Int32(n))
                self.setPrinter.append(data)
        
        }
    @objc
       func text(_ txt :String,ch:String) {
           let bytes =  strToBytes(txt, charset: ch);
           let body = Data(bytes!);
           self.setPrinter.append(body)
       }
        @objc
        func selectCharacterSize(_ n :Int) {
           
                let  data :Data = POSCommand.selectCharacterSize(Int32(n))
                self.setPrinter.append(data)
            
        }
     @objc
     func selectOrCancelBoldModel(_ n :Int) {
         let  data :Data = POSCommand.selectOrCancleBoldModel(Int32(n))
                self.setPrinter.append(data)
            
        }
        @objc
     func selectCharacterCodePage(_ n :Int) {
                let  data :Data = POSCommand.selectCharacterCodePage(Int32(n))
                self.setPrinter.append(data)
            
        }
     @objc
    func selectInternationalCharacterSets(_ n :Int) {
           
                let  data :Data = POSCommand.selectInternationCharacterSets(Int32(n))
                self.setPrinter.append(data)
            
     }
     @objc
    func setAbsolutePrintPosition(_ n :Int, m :Int) {
            let  data :Data = POSCommand.setAbsolutePrintPositionWithNL(Int32(n), andNH: Int32(m))
        self.setPrinter.append(data)
    }
        @objc
         func setEncode(_ base64String :String)   {
             if let data = Data(base64Encoded: base64String) {
                 self.setPrinter.append(data)
                 }
           }
    @objc
     func setImg(_ base64String :String)   {
         guard let imageData = Data(base64Encoded: base64String) else {
                 print("Failed to decode base64 string into data.")
               
                 return
             }
             guard let image = UIImage(data: imageData) else {
                 print("Failed to create UIImage from data.")
               
                 return
             }
        let  data :Data = POSCommand.printRasteBmp(withM: RasterNolmorWH, andImage: image, andType: Dithering)
         self.setPrinter.append(data)
       }
    
    @objc
     func line(_ length :Int) {
         // Create a string with the specified length filled with "."
               let line = String(repeating: ".", count: length)
               // Convert the string to bytes using the existing method
               if let lineBytes = strToBytes(line, charset: "utf-8") {
                   // Carriage return and line feed bytes
                   let newline: [UInt8] = [13, 10] // CR LF
                   let mergedBytes = byteMerger(byte1: lineBytes, byte2: newline)
                   let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
                   self.setPrinter.append(data as Data)
               }
      }
      @objc
       func line2(_ length :Int) {
         // Create a string with the specified length filled with "."
               let line = String(repeating: "-", count: length)
               // Convert the string to bytes using the existing method
               if let lineBytes = strToBytes(line, charset: "utf-8") {
                   // Carriage return and line feed bytes
                   let newline: [UInt8] = [13, 10] // CR LF
                   let mergedBytes = byteMerger(byte1: lineBytes, byte2: newline)
                   let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
                   self.setPrinter.append(data as Data)
               }
      }
      @objc
         func line3(_ length :Int) {
         // Create a string with the specified length filled with "."
               let line = String(repeating: "=", count: length)
               // Convert the string to bytes using the existing method
               if let lineBytes = strToBytes(line, charset: "utf-8") {
                   // Carriage return and line feed bytes
                   let newline: [UInt8] = [13, 10] // CR LF
                   let mergedBytes = byteMerger(byte1: lineBytes, byte2: newline)
                   let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
                   self.setPrinter.append(data as Data)
               }
      }
    
    
    func strToBytes(_ str: String, charset: String) -> [UInt8]? {
           var data: [UInt8]? = nil

           // Convert the string to UTF-8 data
           if let utf8Data = str.data(using: .utf8) {
               // Convert the UTF-8 data back to a string
               if let utf8String = String(data: utf8Data, encoding: .utf8) {
                   // Convert the string to data with the specified charset
                   if let finalData = utf8String.data(using: String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(charset as CFString)))) {
                       // Convert the final data to a byte array
                       data = [UInt8](finalData)
                   }
               }
           }

           return data
       }
    
    
}







// status this work with poSbleReceiveValue
//                self.btManager.printerStatus {(responseData: Data?) in
//                    if responseData!.count == 1 {
//                        let byte = [UInt8](responseData!)
//                           let status = byte[0]
//
//                           switch status {
//                           case 0x12:
//                               print("Ready")
//
//                           case 0x16:
//                               print("Cover opened")
//
//                           case 0x32:
//                               print("Paper end")
//
//                           case 0x36:
//                               print("Cover opened & Paper end")
//
//                           default:
//                               print("Error")
//
//                           }
//                       }
//                }
