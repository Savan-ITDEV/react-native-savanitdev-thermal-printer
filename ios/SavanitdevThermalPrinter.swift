

import Darwin
import UIKit
import Foundation
import CoreBluetooth
@objc(SavanitdevThermalPrinter)
class SavanitdevThermalPrinter: NSObject,POSBLEManagerDelegate,CBCentralManagerDelegate {
    var statusBLE :Bool=false
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
    
var centralManager: CBCentralManager!
  var test:PrinterManager!
  var isConnectedGlobal:Bool=false
  // Create an array of Bike objects
  var printList: [PrinterManager] = []
  var queueList:[DispatchQueue] = [];
  var isConnectedList = [false];
  var objectArray : [String] = [];
  var manager: POSBLEManager!
  var dataArr: [CBPeripheral] = []
  var rssiList: [NSNumber] = []
  var addressCurrent = "";
  var setPrinter = Data();
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return true
  }
  @objc
  func disConnect() {
    if(self.isConnectedGlobal){
      self.test.disConnectPrinter();
    }
  }
  @objc
  func clearLoops() {
    self.printList.removeAll();
    self.queueList.removeAll();
    self.isConnectedList.removeAll();
    self.objectArray.removeAll();
    self.dataArr.removeAll()
    self.manager.poSdisconnectRootPeripheral()
       self.addressCurrent = "";
  }

  // ------------------ bluetooth function ------------------ //
    

  @objc
  func initBLE() {
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
     self.manager = POSBLEManager.sharedInstance()
     self.manager.delegate = self
    print("init BLE")
  }
  @objc
  func startScanBLE() {
      if(self.statusBLE == true){
     self.manager.poSdisconnectRootPeripheral()
     self.manager.poSstartScan()
    print("startScanBLE")
       self.addressCurrent = "";
      }else{
         
          print("your ble is not enable")
        
      }
  }
    
  @objc
  func disconnectBLE(_ id :String, resolver resolve :  @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock) {
      if(self.statusBLE == true){
          do {
              try self.manager.poSdisconnectRootPeripheral()
              print("disconnect")
              self.addressCurrent = "";
              resolve("disconnect")
          } catch {
             
              print("Failed disconnect: \(error)")
              reject("","Failed disconnect: \(error) ", nil)
          }
      }else{
          print("your ble is not enable")
          reject("","your ble is not enable  ", nil)
      }
  }
  @objc
  func checkStatusBLE(_ id :String, resolver resolve :  @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock) {
      if(self.statusBLE == true){
    do {
        try
        print("checkStatusBLE")
        let status = self.manager.connectOK ? "connected" :"no connect"
        resolve(status)
     } catch {
        print("Failed disconnect: \(error)")
        reject("","Failed disconnect: \(error) ", nil)
    }
      }else{
          print("your ble is not enable")
          reject("","your ble is not enable  ", nil)
      }
  }
  @objc
  func connectBLE(_ identifiers :String,resolver resolve :  @escaping RCTPromiseResolveBlock,
    rejecter reject: @escaping RCTPromiseRejectBlock) {
      if(self.statusBLE == true){
      if(dataArr.count > 0){
    do {
            if let matchedPeripheral =  dataArr.first { $0.identifier.uuidString == identifiers }{
                print("Found peripheral: \(matchedPeripheral.name ?? "Unknown")")
//                let peripheral = dataArr[0]
                try self.manager.poSconnectDevice(matchedPeripheral);
                    self.manager.writePeripheral = matchedPeripheral;
                       self.addressCurrent = "";
                print("connect successfully.")
                resolve("connected")
            }else{
                print("Peripheral not found")
                reject("","Peripheral not found", nil)
            }
            
       
      
    } catch {
        print("Failed connect: \(error)")
        reject("","Failed connect: \(error) ", nil)
    }
      }else{
          reject("","Please check your printer is enable or not ", nil)
      }
      }else{
         
          reject("","Please check your printer is enable or not ", nil)
      }
  }
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
//            resolve(String(describing: peripherals[0]))
        } else {
            print("not found device")
            reject("", "not found device", nil)
        }
        }else{
          
            reject("","Please check your printer is enable or not ", nil)
        }
    }
  @objc
  func rawDataBLE(_ base64String :String, resolver resolve :  @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {
      if(self.statusBLE == true){
   if let data = Data(base64Encoded: base64String) {
    do {
        try self.manager.posWriteCommand(with: data)
        print("Command sent successfully.")
        resolve("successfully")
    } catch {
        print("Failed to send command: \(error)")
        reject("","Failed to send command: \(error) ", nil)
    }
    }else{
      print("Failed to decode base64 string into data.")
        reject("","Failed to decode base64 string into data", nil)
     }
      }else{
          reject("","Please check your printer is enable or not ", nil)
      }
  }
  
  
  @objc
  func image64BaseBLE(_ base64String :String, resolver resolve :  @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {
      if(self.statusBLE == true){
    guard let imageData = Data(base64Encoded: base64String) else {
        print("Failed to decode base64 string into data.")
        reject("","Failed to decode base64 string into data.", nil)
        return
    }
    guard let image = UIImage(data: imageData) else {
        print("Failed to create UIImage from data.")
        reject("","Failed to create UIImage from data.", nil)
        return
    }
 
     do {
         let align: Data = PosCommand.selectAlignment(1)
         let height: Data = PosCommand.printAndFeedLine()
         
         let imgData: Data = PosCommand.printRasteBmp(withM: RasterNolmorWH, andImage: image, andType: Dithering)
          let cut: Data = PosCommand.selectCutPageModelAndCutpage(withM: 1, andN: 1)
          let spaceH1 = Data("    ".utf8)
          let spaceH2 = Data("    ".utf8)
          let concatenatedData = align + imgData + spaceH1 + spaceH2 + height
        try self.manager.posWriteCommand(with: concatenatedData)
        print("Command sent successfully 3.")
         resolve("successfully test 3")
    } catch {
        print("Failed to send command: \(error)")
        reject("","Failed to send command: \(error) ", nil)
    }
      }else{
          reject("","Please check your printer is enable or not ", nil)
      }
}
  
 
  func poSdidUpdatePeripheralList(_ peripherals: [Any]!, rssiList: [Any]!) {
        if let peripherals = peripherals as? [CBPeripheral], let rssiList = rssiList as? [NSNumber] {
            self.dataArr = peripherals
            self.rssiList = rssiList

              print("update BLE devices : \(String(describing: peripherals[0]))");
        }
    }
  func poSdidConnect(_ peripheral: CBPeripheral!) {
        print(" BLE poSdidConnect");
    }
    
  func poSdidFail(toConnect peripheral: CBPeripheral!, error: Error!) {
        print(" BLE poSdidFail");
  }
    
  func poSdidDisconnectPeripheral(_ peripheral: CBPeripheral!, isAutoDisconnect: Bool) {
        print(" BLE poSdidDisconnectPeripheral ");
  }
    
  func poSdidWriteValue(for character: CBCharacteristic!, error: Error!) {
        print(" BLE poSdidWriteValue");
  }

   // ------------------ bluetooth function ------------------ //

  // Just calling a routing
  @objc
  func onPrint(_ resolve: @escaping RCTPromiseResolveBlock,
               rejecter reject: @escaping RCTPromiseRejectBlock)-> Void {
    if(self.isConnectedGlobal){
      let queue = DispatchQueue(label: "com.receipt.printer1", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
      queue.async {
        var printSucceed:Bool;
        printSucceed=self.test.sendData(toPrinter:Data("hello swift\n".utf8));
        if(printSucceed){
          resolve("print done")
          print("print1 succeessfully\n");
        }else{
          reject("ERROR_CODE", "fail print", nil)
          print("print1 failed\n");
          print("get status printer : ",self.test.getPrinterStatus());
        }
      }
    }else{
      print("printer offline or printer error");
    }
    print("Hi, I'm written in Native code, and being consumed in react-native code.")
  }
  

  @objc
  func connectIP(_ ip:String, resolver resolve : @escaping RCTPromiseResolveBlock,
                 rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
    if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
      if(self.printList.count > 0 && self.queueList.count > 0)
      {
        if (self.isConnectedList[index]) {
          self.disconnectNet(ip);
          self.isConnectedList[index]=false;
         self.connectNet(ip,resolver: resolve,rejecter: reject);
          print("disconnect printer index \n",ip);        
        }
        else
        {         
          self.queueList[index].async {
            self.printList[index]=PrinterManager.share(0,threadID: "com.receipt.printer\(index)");
            let isConnected = self.printList[index].connectWifiPrinter(ip, port: 9100);
            if(isConnected){
              self.isConnectedList[index]=true;
              print("check test true : ",isConnected);
               self.addressCurrent = ip;
               resolve("conenctConnectIP");
                // self.connectNet(ip,resolver: resolve,rejecter: reject);
              self.printList[index].startMonitor();
            }else{
               self.addressCurrent = "";
              print("check test false : ",isConnected);
              reject("ERROR_CODE", "fail connect", nil)
            }
          }
        }       
      }
    }
  }
  
  @objc
  func connectNet(_ ip:String, resolver resolve : @escaping RCTPromiseResolveBlock,
                  rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
    do{
      if(self.objectArray.contains(ip)){
        self.addressCurrent = "";
        // self.disconnectNet(ip);
        resolve("reconnectConnectNet");
      }else{
        self.objectArray.append(ip);
        if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
        let printer = PrinterManager()
            
        let queue = DispatchQueue(label: "com.receipt.printer\(index)", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        self.printList.append(printer)
        self.queueList.append(queue);
        self.isConnectedList.append(false);
        if(self.objectArray.count > 0 ){
          self.connectIP(ip,resolver: resolve,rejecter: reject)
        }
       }
      }
    } catch{
       self.addressCurrent = "";
      print("connect printer catch : ",ip);
      reject("ERROR_CODE", "fail connect", nil)
    }
  }
  
  
  @objc
  func disconnectNet(_ ip :String) {
    if(self.isConnectedList.count > 0){
      if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
        if(self.isConnectedList[index]){
          self.objectArray.removeAll();
          self.printList[index].disConnectPrinter();
          self.addressCurrent = "";
        }
      }
    }
  }
  
  
  @objc
  func printTest(_ ip:String, resolver resolve : @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock)  -> Void {
    if(self.isConnectedList.count > 0){
      if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
        if(self.isConnectedList[index]){
          queueList[index].async {
            let printSucceed=self.printList[index].sendData(toPrinter:Data("hello swift\n".utf8));
            if(printSucceed){
              print("print1 succeessfully\n");
              resolve("print done");
            }else{
              let status = self.printList[index].getPrinterStatus();
              print("status : ",status);
              if(status == "Printer Disconnected" || status == "Error"){
//                self.connectNet(ip,resolver: resolve,rejecter: reject);
                reject("ERROR_CODE", status  , nil)
              }
              else if(status == "Normal"){
                        resolve("print Normal");
               }
              else{
                reject("ERROR_CODE", "status : \(status) ip : \(ip)"  , nil)
              }
            }
          }
        }
      }
    }
  }
  
  @objc
  func printImgNet(_ ip:String,base64String :String,isDisconnect:Bool,resolver resolve : @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock)  -> Void {
      print("init print \n");
      if(self.isConnectedList.count > 0){
          print("init isConnectedList \n");
        if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
            print("init objectArray \n");
          if(self.isConnectedList[index]){
              print("init index \n");
            queueList[index].async {
              // Convert the Img base64 string to Data
              if let imageData = Data(base64Encoded: base64String) {
                if let image = UIImage(data: imageData) { 
                  let align:Data=PosCommand.selectAlignment(1);
                  let Hight  :Data=PosCommand.printAndFeedLine();
                  let imgData:Data=PosCommand.printRasteBmp(withM: RasterNolmorWH, andImage: image, andType: Dithering);
                  let cut:Data=PosCommand.selectCutPageModelAndCutpage(withM: 1, andN: 1);
                  let spaceH1 = Data("    ".utf8);
                  let spaceH2 = Data("    ".utf8);
                  let concatenatedData = align + imgData + cut + spaceH1 + spaceH2 + Hight
                  let printSucceed = self.printList[index].sendData(toPrinter: concatenatedData);
                  if(printSucceed){
                    print("print1 succeessfully\n");
                      if(isDisconnect){
                         self.disconnectNet(ip);
                         }
                    resolve("print done");
                  }else{
                    let status = self.printList[index].getPrinterStatus();
                    if(status == "Error"){
                      reject("ERROR_CODE", status  , nil)
                    }
                    else if(status == "Printer Disconnected"){
                      if(self.objectArray.count > 0 ){
                       self.connectIP(ip,resolver: resolve,rejecter: reject)
                      }
                    }
                    else if(status == "Normal"){
                        resolve("print Normal");
                    }
                   else
                   {
                    reject("ERROR_CODE", "status : \(status) ip : \(ip)"  , nil)
                   }
                  }
                }
              }
            }
          }
        }
      }
  }
  
   @objc
  func printImgNetSticker(_ ip:String,base64String :String,isCut:Bool,resolver resolve : @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock)  -> Void {
      print("init print \n");
      if(self.isConnectedList.count > 0){
          print("init isConnectedList \n");
        if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
            print("init objectArray \n");
          if(self.isConnectedList[index]){
              print("init index \n");
            queueList[index].async {
              // Convert the Img base64 string to Data
              if let imageData = Data(base64Encoded: base64String) {
                if let image = UIImage(data: imageData) { 
                  let align:Data=PosCommand.selectAlignment(1);
                  let Hight  :Data=PosCommand.printAndFeedLine();
                  let imgData:Data=PosCommand.printRasteBmp(withM: RasterNolmorWH, andImage: image, andType: Dithering);
                  let cut:Data=PosCommand.selectCutPageModelAndCutpage(withM: 1, andN: 1);
                  let spaceH1 = Data("    ".utf8);
                  let spaceH2 = Data("    ".utf8);
                    var concatenatedData = align + imgData + spaceH1 + spaceH2 + Hight;
                    if(isCut){
                      concatenatedData = concatenatedData + cut;
                    }
                  let printSucceed = self.printList[index].sendData(toPrinter: concatenatedData);
                  if(printSucceed){
                    print("print1 succeessfully\n"); 
                    resolve("print done");
                  }else{
                    let status = self.printList[index].getPrinterStatus();
                    if(status == "Error"){
                      reject("ERROR_CODE", status  , nil)
                    }
                    else if(status == "Printer Disconnected"){
                      if(self.objectArray.count > 0 ){
                       self.connectIP(ip,resolver: resolve,rejecter: reject)
                      }
                    }
                    else if(status == "Normal"){
                        resolve("print Normal");
                    }
                   else
                   {
                    reject("ERROR_CODE", "status : \(status) ip : \(ip)"  , nil)
                   }
                  }
                }
              }
            }
          }
        }
      }
  }

  @objc
  func printEncodeNet(_ ip:String,base64String :String,isDisconnect:Bool,resolver resolve : @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock) -> Void   {
      print("init print \n");
      if(self.isConnectedList.count > 0){
          print("init isConnectedList \n");
        if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
            print("init objectArray \n");
          if(self.isConnectedList[index]){
            print(" print index : ",index);
            queueList[index].async {
              if let data = Data(base64Encoded: base64String) {
                // 'data' now contains the decoded bytes
                _ = [UInt8](data)
                 let printSucceed = self.printList[index].sendData(toPrinter: data);
                  if(printSucceed){
                    print("print1 succeessfully\n");
                      if(isDisconnect){
                          self.disconnectNet(ip);
                      }
                    resolve("print done");
                  }else{
                    let status = self.printList[index].getPrinterStatus();
                    if(status == "Error"){
                      reject("ERROR_CODE", status  , nil)
                    }
                    else if(status == "Printer Disconnected"){
                      if(self.objectArray.count > 0 ){
                      self.connectIP(ip,resolver: resolve,rejecter: reject)
                        }
                    }
                    else if(status == "Normal"){
                      resolve("print Normal");
                    }
                   else{
                    reject("ERROR_CODE", "status : \(status) ip : \(ip)"  , nil)
                   }
                  }
            }
          }
        }
      }
   } 
 }
    
 @objc
    func byteMerger(byte1: [UInt8], byte2: [UInt8]) -> [UInt8] {
        var byte3 = [UInt8]()
        byte3.append(contentsOf: byte1)
        byte3.append(contentsOf: byte2)
        return byte3
    }
    
    @objc
    func setLang(_ codepage :String) {
        if let codepageInt = UInt8(codepage) {
            let byte1: [UInt8] = [31, 27, 31, 255]
            let byte2: [UInt8] = [codepageInt, 10, 0]
            let mergedBytes = byteMerger(byte1: byte1, byte2: byte2)
            let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
           if(self.addressCurrent.isEmpty){
                       self.manager.posWriteCommand(with: data as Data)
                   }else{
                       self.sendConfigNet(self.addressCurrent,data: data as Data)
                   }
        }
    }
    @objc
    func printLangPrinter() {
        let byte1: [UInt8] = [27, 64, 28, 46, 27, 33, 0, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 0, 0, 0, 0, 0, 10]
        let byte2: [UInt8] = [27, 64, 29, 86, 65, 72, 28, 38, 0]
        let mergedBytes = byteMerger(byte1: byte1, byte2: byte2)
        let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
        if(self.addressCurrent.isEmpty){
                       self.manager.posWriteCommand(with: data as Data)
                   }else{
                       self.sendConfigNet(self.addressCurrent,data: data as Data)
                   }
     
    }
    @objc
    func getLangModel() {
        let byte1: [UInt8] = [31, 27, 31, 103]
        let byte2: [UInt8] = [/* your second byte array */]

        let mergedBytes = byteMerger(byte1: byte1, byte2: byte2)
        let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
        if(self.addressCurrent.isEmpty){
                       self.manager.posWriteCommand(with: data as Data)
                   }else{
                       self.sendConfigNet(self.addressCurrent,data: data as Data)
                   }
     
    }
    @objc
    func cancelChinese() {
        let byte1: [UInt8] = [31, 27, 31, 191, 8, 0]
        let byte2: [UInt8] = [/* your second byte array */]

        let mergedBytes = byteMerger(byte1: byte1, byte2: byte2)
        let data = NSData(bytes: mergedBytes, length: mergedBytes.count)
         if(self.addressCurrent.isEmpty){
                       self.manager.posWriteCommand(with: data as Data)
                   }else{
                       self.sendConfigNet(self.addressCurrent,data: data as Data)
                   }
     
    }

    @objc
    func sendConfigNet(_ ip:String,data : Data) -> Void   {
            if(self.isConnectedList.count > 0){
              if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
                if(self.isConnectedList[index]){
                  queueList[index].async {
                     self.printList[index].sendData(toPrinter: data);
                }
              }
            }
         }
       }

       @objc
 func printText(_ resolve :  @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) {
    do {
        try self.manager.posWriteCommand(with: self.setPrinter)
        print("Command sent successfully.")
        resolve("successfully")
    } catch {
        print("Failed to send command: \(error)")
        reject("","Failed to send command: \(error) ", nil)
    }
  }

@objc
  func printTemplate(_ ip:String,isDisconnect:Bool,resolver resolve : @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock) -> Void   {
      if(self.isConnectedList.count > 0){
        if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
          if(self.isConnectedList[index]){
            print(" print index : ",index);
            queueList[index].async {
             
                let printSucceed = self.printList[index].sendData(toPrinter: self.setPrinter);
                   if(printSucceed){
                    print("print1 succeessfully\n");
                      if(isDisconnect){
                          self.disconnectNet(ip);
                      }
                    resolve("print done");
                  }else{
                    let status = self.printList[index].getPrinterStatus();
                    if(status == "Error"){
                      reject("ERROR_CODE", status  , nil)
                    }
                    else if(status == "Printer Disconnected"){
                      if(self.objectArray.count > 0 ){
                      self.connectIP(ip,resolver: resolve,rejecter: reject)
                        }
                    }
                    else if(status == "Normal"){
                      resolve("print Normal");
                    }
                   else{
                    reject("ERROR_CODE", "status : \(status) ip : \(ip)"  , nil)
                   }
                  }
          }
        }
      }
   } 
 }

 
@objc
 func clearPaper(_ resolve :  @escaping RCTPromiseResolveBlock,
                 rejecter reject: @escaping RCTPromiseRejectBlock) {
     self.setPrinter.removeAll();
     resolve("clear done");
}
@objc
func initializeText() {
      let body: Data = PosCommand.initializePrinter();
    self.setPrinter.append(body)
    }
@objc
   func cut() {
     let cut: Data = PosCommand.selectCutPageModelAndCutpage(withM: 1, andN: 1)
       self.setPrinter.append(cut)
    }
@objc
   func printAndFeedLine() {
     let body: Data = PosCommand.printAndFeedLine()
       self.setPrinter.append(body)
    }
@objc
     func CancelChineseCharModel() {
         let body: Data = PosCommand.cancelChineseCharModel()
         self.setPrinter.append(body)
    }
@objc
    func selectAlignment(_ n :Int) {
     
        let  data :Data = PosCommand.selectAlignment(Int32(n))
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
       
            let  data :Data = PosCommand.selectCharacterSize(Int32(n))
            self.setPrinter.append(data)
        
    }
 @objc
 func selectOrCancelBoldModel(_ n :Int) {
     let  data :Data = PosCommand.selectOrCancleBoldModel(Int32(n))
            self.setPrinter.append(data)
        
    }
    @objc
 func selectCharacterCodePage(_ n :Int) {
      
            let  data :Data = PosCommand.selectCharacterCodePage(Int32(n))
            self.setPrinter.append(data)
        
    }
 @objc
func selectInternationalCharacterSets(_ n :Int) {
       
            let  data :Data = PosCommand.selectInternationCharacterSets(Int32(n))
            self.setPrinter.append(data)
        
 }
 @objc
func setAbsolutePrintPosition(_ n :Int, m :Int) {
        let  data :Data = PosCommand.setAbsolutePrintPositionWithNL(Int32(n), andNH: Int32(m))
    self.setPrinter.append(data)
}
    @objc
     func getEncode(_ base64String :String)   {
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
    let  data :Data = PosCommand.printRasteBmp(withM: RasterNolmorWH, andImage: image, andType: Dithering)
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
