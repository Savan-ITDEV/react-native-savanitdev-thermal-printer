

import Darwin
import UIKit
import Foundation

@objc(SavanitdevThermalPrinter)
class SavanitdevThermalPrinter: NSObject {

  var test:PrinterManager!
  var isConnectedGlobal:Bool=false
  // Create an array of Bike objects
  var printList: [PrinterManager] = []
  var queueList:[DispatchQueue] = [];
  var isConnectedList = [false];
  var objectArray : [String] = [];
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
    
  }
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
  func ConnectPrinter(_ ip:String, resolver resolve :  @escaping RCTPromiseResolveBlock,
                      rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
    let queue = DispatchQueue(label: "com.receipt.printer1", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    if(self.isConnectedGlobal){
      self.test.disConnectPrinter();
      self.isConnectedGlobal=false;
      self.ConnectPrinter(ip,resolver: resolve, rejecter: reject);
      print("disconnect printer1 \n");
    }else{
      queue.async {
        var isConnected:Bool;
        self.test=PrinterManager.share(0,threadID: "com.receipt.printer1");
        isConnected=self.test.connectWifiPrinter(ip, port: 9100);
        self.isConnectedGlobal=isConnected;
        
        if(isConnected){
          resolve("conenct printer");
          print("connect printer1 succeessfully\n");
          self.test.startMonitor();
          
        }else{
          reject("ERROR_CODE", "fail connect", nil)
          print("connect printer1 failed\n");
        }
      }
      
    }
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
              resolve("conenct printer");
              self.printList[index].startMonitor();
            }else{
              print("check test false : ",isConnected);
              reject("ERROR_CODE", "fail connect", nil)
            }
          }
        }       
      }
    }
  }
  
  @objc
  func connectBLE(_ ip:String, resolver resolve : @escaping RCTPromiseResolveBlock,
                  rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
     
  }
  @objc
  func connectNet(_ ip:String, resolver resolve : @escaping RCTPromiseResolveBlock,
                  rejecter reject: @escaping RCTPromiseRejectBlock) -> Void {
    do{
      if(self.objectArray.contains(ip)){
        // resolve("conenct printer");
        if(self.objectArray.count > 0 ){
          self.connectIP(ip,resolver: resolve,rejecter: reject)
        }
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
      print("connect printer catch : ",ip);
      reject("ERROR_CODE", "fail connect", nil)
    }
  }
  
  
  @objc
  func disconnectNet(_ ip :String) {
    if(self.isConnectedList.count > 0){
      if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
        if(self.isConnectedList[index]){
          self.printList[index].disConnectPrinter();
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
  func printImgNet(_ ip:String,base64String :String,resolver resolve : @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock)  -> Void {
      if(self.isConnectedList.count > 0){
        if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
          if(self.isConnectedList[index]){
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
                    resolve("print done");
                  }else{
                    let status = self.printList[index].getPrinterStatus();
                    if(status == "Printer Disconnected" || status == "Error"){
                      reject("ERROR_CODE", status  , nil)
                    }else if(status == "Normal"){
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
  func printEncodeNet(_ ip:String,base64String :String,resolver resolve : @escaping RCTPromiseResolveBlock,
                rejecter reject: @escaping RCTPromiseRejectBlock) -> Void   {
      if(self.isConnectedList.count > 0){
        if let index = self.objectArray.firstIndex(where: { $0 == ip }) {
          if(self.isConnectedList[index]){
            print(" print index : ",index);
            queueList[index].async {
              if let data = Data(base64Encoded: base64String) {
                // 'data' now contains the decoded bytes
                _ = [UInt8](data)
                 let printSucceed = self.printList[index].sendData(toPrinter: data);
                  if(printSucceed){
                    print("print1 succeessfully\n");
                    resolve("print done");
                  }else{
                    let status = self.printList[index].getPrinterStatus();
                    if(status == "Printer Disconnected" || status == "Error"){
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
 }
}