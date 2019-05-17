

import Foundation

class IPUtility {
    static let Wifi = "wifi"
    static let Cellular = "3g"

    class func getMyIP() -> (ip: String?, network: String?) {
        // Get list of all interfaces on the local machine:
        var interfaceAddress : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&interfaceAddress) == 0 else { return (nil, nil) }
        defer {
            freeifaddrs(interfaceAddress)
        }
        guard let firstAddress = interfaceAddress else { return (nil, nil) }
        var secondaryAddress: String? = nil //will be returned if there's no wifi connection
        // For each interface ...
        for ifptr in sequence(first: firstAddress, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily != UInt8(AF_INET) && addrFamily != UInt8(AF_INET6) {
                continue
            }

            // Check interface name:
            let name = String(cString: interface.ifa_name)
            if name != "en0" && name.range(of: "pdp") == nil  {
                continue
            }

            // Convert interface address to a human readable string:
            var address = interface.ifa_addr.pointee
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(&address, socklen_t(interface.ifa_addr.pointee.sa_len),
                        &hostname, socklen_t(hostname.count),
                        nil, socklen_t(0), NI_NUMERICHOST)
            let returnAddress = String(cString: hostname)
            if returnAddress.isEmpty {
                continue
            }
            if(returnAddress.range(of: "::") != nil) {
                continue
            }
            if(name == "en0") {
                return (returnAddress, IPUtility.Wifi)
            } else {
                secondaryAddress = returnAddress
            }
        }
        return (secondaryAddress, IPUtility.Cellular)
    }
}
