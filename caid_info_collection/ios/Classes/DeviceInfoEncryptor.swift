//
//  DeviceInfoEncryptor.swift
//  caid_info_collection
//
//  Created by zhongyu on 2026/2/14.
//

import Foundation
import Security

struct DeviceInfoEncryptor {

    let publicKeyBase64: String

    func encryptDeviceInfo(_ deviceInfo: [String: String]) throws -> String {
        print("开始加密设备信息")
        let jsonData = try JSONSerialization.data(withJSONObject: deviceInfo, options: [])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("JSON 转字符串失败")
            throw NSError(domain: "json_error", code: -1)
        }
        print("JSON 转换成功，长度：\(jsonString.count)")

        print("开始获取公钥，publicKeyBase64 长度：\(publicKeyBase64.count)")
        guard let publicKey = getPublicKey() else {
            print("获取公钥失败")
            throw NSError(domain: "key_error", code: -2)
        }

        print("jsonString:\(jsonString)")
        print("publicKey:\(publicKey)")

        let encryptedData = try rsaEncrypt(plainText: jsonString, publicKey: publicKey)

        return encryptedData.base64EncodedString()
    }

}


extension DeviceInfoEncryptor {

    private func getPublicKey() -> SecKey? {
        print("getPublicKey: 开始解析公钥")

        // 去除换行符和空白字符
        let cleanedBase64 = publicKeyBase64
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: " ", with: "")

        guard let certData = Data(base64Encoded: cleanedBase64) else {
            print("getPublicKey: Base64 解码失败")
            return nil
        }
        print("getPublicKey: Base64 解码成功，数据长度：\(certData.count)")

        guard let certificate = SecCertificateCreateWithData(nil, certData as CFData) else {
            print("getPublicKey: 创建证书失败")
            return nil
        }
        print("getPublicKey: 创建证书成功")

        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?

        let status = SecTrustCreateWithCertificates(certificate, policy, &trust)
        guard status == errSecSuccess, let trustObj = trust else {
            print("getPublicKey: 创建 Trust 失败，status: \(status)")
            return nil
        }
        print("getPublicKey: 创建 Trust 成功")

        // 对于自签名证书，跳过验证直接提取公钥
        if #available(iOS 12.0, *) {
            // iOS 12+ 可以直接从 trust 对象获取公钥，无需验证
            if let key = SecTrustCopyKey(trustObj) {
                print("getPublicKey: 跳过验证，直接提取密钥成功")
                return key
            }
        }

        // iOS 12 以下，尝试设置为信任根证书
        SecTrustSetAnchorCertificates(trustObj, [certificate] as CFArray)
        SecTrustSetAnchorCertificatesOnly(trustObj, true)

        var error: CFError?
        if SecTrustEvaluateWithError(trustObj, &error) {
            print("getPublicKey: 验证证书成功")
        } else {
            print("getPublicKey: 验证证书失败（忽略），error: \(String(describing: error))")
        }

        let key = SecTrustCopyKey(trustObj)
        print("getPublicKey: 提取密钥\(key != nil ? "成功" : "失败")")
        return key
    }

}

extension DeviceInfoEncryptor {
    private func rsaEncrypt(plainText: String, publicKey: SecKey) throws -> Data {
        guard let plainData = plainText.data(using: .utf8) else {
            throw NSError(domain: "encoding_error", code: -3, userInfo: nil)
        }

        let blockSize = SecKeyGetBlockSize(publicKey)

        let maxChunkSize = blockSize - 11

        var encryptedData = Data()
        var offset = 0

        while offset < plainData.count {
            let chunkLength = min(maxChunkSize, plainData.count - offset)
            let chunk = plainData.subdata(in: offset..<(offset + chunkLength))

            var error: Unmanaged<CFError>?
            guard let encryptedChunk = SecKeyCreateEncryptedData(
                publicKey,
                .rsaEncryptionPKCS1,
                chunk as CFData,
                &error
            ) as Data? else {
                throw error?.takeRetainedValue() ?? NSError(domain: "encrypt_chunk_error", code: -4, userInfo: nil)
            }

            encryptedData.append(encryptedChunk)
            offset += chunkLength
        }

        return encryptedData
    }
}

