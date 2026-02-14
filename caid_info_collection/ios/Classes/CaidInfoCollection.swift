//
//  CaidInfoCollection.swift
//  caid_info_collection
//
//  Created by zhongyu on 2026/2/13.
//

import Foundation
import Darwin
import CryptoKit
import UIKit
import CoreTelephony

class CaidInfoCollection {

    static let shared = CaidInfoCollection()

    private init() {  }

    func getEncryptedDeviceInfo(_ publicKeyBase64: String) -> String {
        var deviceName = ""
        if #available(iOS 13.0, *) {
            deviceName = self.deviceName() ?? ""
        }

        let deviceInfo: [String: String] = [
            "bootTimeInSec": bootTimeInSec(),
            "countryCode": countryCode(),
            "language": language(),
            "deviceName": deviceName,
            "systemVersion": systemVersion(),
            "machine": machine(),
            "carrierInfo": carrierInfo(),
            "memory": memory(),
            "disk": disk(),
            "sysFileTime": sysFileTime() ?? "",
            "model": model(),
            "timeZone": timeZone(),
            "mntId": mntId(),
            "deviceInitTime": fileInitTime()
        ]

        let encryptor = DeviceInfoEncryptor(publicKeyBase64: publicKeyBase64)

        do {
            let result = try encryptor.encryptDeviceInfo(deviceInfo)
            print("加密成功，结果长度：\(result.count)")
            return result
        } catch {
            print("加密失败，错误：\(error)")
            return ""
        }
    }


    // 获取设备启动时间
    private func bootTimeInSec() -> String {
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var boottime = timeval()
        var size = MemoryLayout<timeval>.stride

        guard sysctl(&mib, 2, &boottime, &size, nil, 0) == 0 else {
            return "0"
        }

        return String(boottime.tv_sec)
    }

    // 获取国家信息
    private func countryCode() -> String {
        if #available(iOS 16.0, *) {
            return Locale.current.region?.identifier ?? ""
        } else {
            return Locale.current.regionCode ?? ""
        }
    }

    // 获取语音信息
    private func language() -> String {
        if let first = Locale.preferredLanguages.first {
            return first
        } else {
            if #available(iOS 16.0, *) {
                return Locale.current.language.languageCode?.identifier ?? ""
            } else {
                return Locale.current.languageCode ?? ""
            }
        }
    }

    // 获取设备名称
    @available(iOS 13.0, *)
    private func deviceName() -> String? {
        let name = UIDevice.current.name
        guard !name.isEmpty else {
            return nil
        }
        return md5HexDigest(name)
    }

    // 获取系统版本
    private func systemVersion() -> String {
        return UIDevice.current.systemVersion
    }

    // 获取设备machine
    private func machine() -> String {
        return getSystemHardwareByName("hw.machine") ?? ""
    }

    // 获取运营商信息，iOS16之后被废弃默认不可获取，设置为unknown
    private func carrierInfo() -> String {

#if targetEnvironment(simulator)
        return "SIMULATOR"
#else

        if #available(iOS 16.0, *) {
            return "unknown"
        } else {

            let queue = DispatchQueue(label: "com.carr.\(UUID().uuidString)")
            let semaphore = DispatchSemaphore(value: 0)

            var carr: String?

            queue.async {

                let info = CTTelephonyNetworkInfo()
                var carrier: CTCarrier?

                if let providers = info.serviceSubscriberCellularProviders,
                   let firstKey = providers.keys.sorted().first {

                    carrier = providers[firstKey]

                    if carrier?.mobileNetworkCode == nil,
                       let lastKey = providers.keys.sorted().last {
                        carrier = providers[lastKey]
                    }
                }

                if carrier == nil {
                    carrier = info.subscriberCellularProvider
                }

                if let carrier = carrier {

                    let networkCode = carrier.mobileNetworkCode
                    let countryCode = carrier.mobileCountryCode

                    if countryCode == "460", let networkCode = networkCode {

                        switch networkCode {
                        case "00", "02", "07", "08":
                            carr = "中国移动"
                        case "01", "06", "09":
                            carr = "中国联通"
                        case "03", "05", "11":
                            carr = "中国电信"
                        case "04":
                            carr = "中国卫通"
                        case "20":
                            carr = "中国铁通"
                        default:
                            break
                        }

                    } else {
                        carr = carrier.carrierName
                    }
                }

                if carr?.isEmpty ?? true {
                    carr = "unknown"
                }

                semaphore.signal()
            }

            _ = semaphore.wait(timeout: .now() + 0.5)

            return carr ?? "unknown"
        }

#endif
    }

    // 获取物理内存容量
    private func memory() -> String {
        let memory = ProcessInfo.processInfo.physicalMemory
        return String(memory)
    }

    // 获取硬盘容量
    private func disk() -> String {
        var space: Int64 = -1

        do {
            let attrs = try FileManager.default.attributesOfFileSystem(
                forPath: NSHomeDirectory()
            )

            if let size = attrs[.systemSize] as? NSNumber {
                space = size.int64Value
            }
        } catch {
            space = -1
        }

        if space < 0 {
            space = -1
        }

        return String(space)
    }

    // 获取系统更新时间
    private func sysFileTime() -> String? {

        let information = """
        L3Zhci9tb2JpbGUvTGlicmFyeS9Vc2VyQ29uZmlndXJhdGlvblByb2ZpbGVzL1B1YmxpY0luZm8vTUNNZXRhLnBsaXN0
        """

        guard
            let data = Data(base64Encoded: information),
            let path = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: path)

            if let date = attributes[.creationDate] as? Date {
                let timestamp = date.timeIntervalSince1970
                return String(format: "%.6f", timestamp)
            }
        } catch {
            return nil
        }

        return nil
    }

    // 获取设备model
    private func model() -> String {
        return getSystemHardwareByName("hw.model") ?? ""
    }

    // 获取时区
    private func timeZone() -> String {
        let offset = TimeZone.current.secondsFromGMT()
        return String(offset)
    }

    // 获取mnt_id
    private func mntId() -> String {

        var buf = statfs()

        if statfs("/", &buf) != 0 {
            return ""
        }

        let prefix = "com.apple.os.update-"

        let mountFrom = withUnsafePointer(to: &buf.f_mntfromname) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) {
                String(cString: $0)
            }
        }

        if let range = mountFrom.range(of: prefix) {
            let start = range.upperBound
            return String(mountFrom[start...])
        }

        return ""
    }

    // 获取设备初始化时间
    private func fileInitTime() -> String {

        var info = stat()

        let result = stat("/var/mobile", &info)
        if result != 0 {
            return ""
        }

        let time = info.st_birthtimespec

        let seconds = time.tv_sec
        let nanoseconds = time.tv_nsec

        let nanoString = String(format: "%09ld", nanoseconds)

        return "\(seconds).\(nanoString)"
    }

}

extension CaidInfoCollection {

    @available(iOS 13.0, *)
    private func md5HexDigest(_ string: String) -> String {
        let data = Data(string.utf8)
        let digest = Insecure.MD5.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func getSystemHardwareByName(_ typeSpecifier: String) -> String? {
        var size: size_t = 0

        sysctlbyname(typeSpecifier, nil, &size, nil, 0)

        var buffer = [CChar](repeating: 0, count: size)

        let result = sysctlbyname(typeSpecifier, &buffer, &size, nil, 0)
        guard result == 0 else {
            return nil
        }

        return String(cString: buffer)
    }

}
