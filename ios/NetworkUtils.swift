import Network
import Foundation
import SystemConfiguration.CaptiveNetwork



@available(iOS 12.0, *)
func pingWithNWConnection(to host: String, port: UInt16 = 9100, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
     let hostEndpoint = NWEndpoint.Host(host)
     let portEndpoint = NWEndpoint.Port(rawValue: port)!
    
     let options = NWProtocolTCP.Options()
         options.connectionTimeout = 1
         let params = NWParameters(tls: nil, tcp: options)
     let connection = NWConnection(host: hostEndpoint, port: portEndpoint, using: params)
 
     let startTime = Date()  // Record start time
     connection.stateUpdateHandler = { newState in
          
               print("TCP state change to: \(newState)")
                      switch newState {
                      case .setup:
                          break
                      case .waiting(let error):
                          print("Waiting Error \(error)")
                          connection.cancel()
                          break
                      case .preparing:
                          break
                      case .ready:
                          let endTime = Date()  // Record end time
                          let rtt = endTime.timeIntervalSince(startTime) * 1000
                          resolver(rtt)
                          break
                      case .failed(let error):
                          print("\(error)")
                          break
                      case .cancelled:
                          rejecter("ERROR","Ping fail please check your device",nil)
                          break
                      default:
                          break
                      }

       }
   
     connection.start(queue: .main)
    
    
}

@available(iOS 16.4, *)
func scanDevicesInLocalNetwork(resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    let startIP = 2
     let endIP = 254
      guard let localIP = getLocalIPAddress() else {
           print("Could not determine local IP address.")
           return
       }
       
       // Extract the base IP from the local IP (e.g., from 192.168.1.105 -> 192.168.1.)
       let baseIP = localIP.components(separatedBy: ".").dropLast().joined(separator: ".") + "."
       print("Scanning network with base IP: \(baseIP)")
     
     // Common ports for network devices
     let ports: [UInt16] = [80, 9100]
     
     // Set to track found IPs
     var foundIPs = Set<String>()
     
     let scanQueue = DispatchQueue(label: "scanQueue", qos: .background)
     
     for i in startIP...endIP {
         let host = baseIP + String(i)
         for port in ports {
             let hostEndpoint = NWEndpoint.Host(host)
             let portEndpoint = NWEndpoint.Port(rawValue: port)!
             let options = NWProtocolTCP.Options()
             options.connectionTimeout = 50
             let params = NWParameters(tls: nil, tcp: options)
             let connection = NWConnection(host: hostEndpoint, port: portEndpoint, using: params)
             connection.stateUpdateHandler = { state in
                 switch state {
                 case .ready:
                     // Only report the device if the IP hasn't been found yet
                     if !foundIPs.contains(host) {
                         print("Device found at: \(host)")
                         foundIPs.insert(host)  // Mark IP as found
                     }
                     connection.cancel()
                 case .failed(let error):
                     if (error as? NWError)?.errorCode == 61 {
                         // Connection refused is normal for devices not listening on this port
                     } else {
                         print("Failed to connect to \(host) on port \(port): \(error)")
                     }
                     connection.cancel()
                 default:
                     break
                 }
             }
             
             scanQueue.async {
                 connection.start(queue: scanQueue)
             }
         }
     }
   
}
// Helper function to get the local IP address of the device
func getLocalIPAddress() -> String? {
    var address: String?
    
    // Get list of all interfaces on the device
    var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            // Check for IPv4 interface (AF_INET)
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                if let ifaName = String(cString: (interface?.ifa_name)!, encoding: .utf8), ifaName == "en0" {
                    var addr = interface?.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr!, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                }
            }
        }
        freeifaddrs(ifaddr)
    }
    
    return address
}
