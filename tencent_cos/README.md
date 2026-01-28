# Tencent COS

一个用于 Flutter 的腾讯云对象存储 (COS) SDK 封装包，提供简单易用的文件上传、下载和删除功能。

## 功能特性

- ✅ 文件上传（支持图片、视频等）
- ✅ 批量上传
- ✅ 文件下载链接生成
- ✅ 文件删除
- ✅ 批量删除
- ✅ 支持临时密钥（STS）
- ✅ 支持范围限制的临时密钥
- ✅ 上传进度回调
- ✅ 上传状态监听

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  tencent_cos:
    git:
      url: https://github.com/your-repo/tencent_cos.git
```

## 使用方法

### 1. 初始化

在使用前需要先初始化客户端：

```dart
import 'package:tencent_cos/tencent_cos.dart';

await TencentCosClient.initialize(
  TencentCosConfig(
    appId: 'your_app_id',              // 腾讯云 APP ID
    bucketName: 'your_bucket_name',    // 存储桶名称
    region: 'ap-guangzhou',            // 存储桶所在地域
    useSessionToken: true,             // 是否使用临时密钥
    stsUrl: 'https://your-sts-server.com/sts',  // STS 服务器地址
    isDebuggable: true,                // 是否开启调试模式
  ),
);
```

### 2. 上传文件

#### 上传任意文件（自定义路径）

```dart
await client.upload.uploadFile(
  cosPath: 'documents/report.pdf',
  srcPath: '/path/to/local/report.pdf',
  successUpload: (uploadUrl) {
    print('上传成功: $uploadUrl');
  },
  failUpload: (error) {
    print('上传失败: $error');
  },
);
```

#### 上传单个图片

```dart
final client = TencentCosClient.instance;

await client.upload.uploadImageToTencent(
  cosPath: 'test.jpg',
  srcPath: '/path/to/local/image.jpg',
  successUpload: (uploadUrl) {
    print('上传成功: $uploadUrl');
  },
  failUpload: (error) {
    print('上传失败: $error');
  },
);
```

#### 上传视频

```dart
await client.upload.uploadVideoToTencent(
  'test.mp4',
  '/path/to/local/video.mp4',
  (uploadUrl) {
    print('上传成功: $uploadUrl');
  },
);
```

#### 批量上传图片

```dart
await client.upload.uploadMultipleImageToTencent(
  pathList: [
    {'cosPath': 'image1.jpg', 'srcPath': '/path/to/image1.jpg'},
    {'cosPath': 'image2.jpg', 'srcPath': '/path/to/image2.jpg'},
  ],
  successUpload: (uploadUrlList) {
    print('批量上传成功: $uploadUrlList');
  },
  failUpload: (error) {
    print('上传失败: $error');
  },
);
```

#### 同时上传图片和视频

```dart
await client.upload.uploadImageAndVideoToTencent(
  'image.jpg',
  '/path/to/image.jpg',
  'video.mp4',
  '/path/to/video.mp4',
  (imageUrl, videoUrl) {
    print('图片: $imageUrl');
    print('视频: $videoUrl');
  },
);
```

### 3. 获取下载链接

```dart
// 获取图片下载链接
final imageUrl = client.download.getImageDownloadUrl('test.jpg');

// 获取视频下载链接
final videoUrl = client.download.getVideoDownloadUrl('test.mp4');

// 获取任意文件下载链接
final fileUrl = client.download.getDownloadUrl('path/to/file.pdf');
```

### 4. 删除文件

```dart
// 删除图片
await client.delete.deleteImage('test.jpg');

// 删除视频
await client.delete.deleteVideo('test.mp4');

// 删除任意对象
await client.delete.deleteObject('path/to/file.pdf');

// 批量删除
await client.delete.deleteObjects([
  'images/image1.jpg',
  'images/image2.jpg',
  'videos/video1.mp4',
]);
```

## 配置说明

### TencentCosConfig 参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| appId | String | 是 | 腾讯云 APP ID |
| bucketName | String | 是 | 存储桶名称 |
| region | String | 是 | 存储桶所在地域，如 `ap-guangzhou` |
| useSessionToken | bool | 否 | 是否使用临时密钥，默认 `true` |
| useScopeLimitToken | bool | 否 | 是否使用范围限制的临时密钥，默认 `false` |
| secretId | String? | 否 | 永久密钥 SecretID（不使用临时密钥时必填） |
| secretKey | String? | 否 | 永久密钥 SecretKey（不使用临时密钥时必填） |
| stsUrl | String? | 否 | STS 临时密钥服务器地址（使用临时密钥时必填） |
| stsScopeLimitUrl | String? | 否 | STS 范围限制的临时密钥服务器地址 |
| isDebuggable | bool | 否 | 是否开启调试模式，默认 `false` |
| imagesPrefix | String | 否 | “图片”类接口使用的文件夹前缀，默认 `images`（即 `images/`） |
| videosPrefix | String | 否 | “视频”类接口使用的文件夹前缀，默认 `videos`（即 `videos/`） |

初始化时可通过 `imagesPrefix`、`videosPrefix` 自定义文件夹名，例如使用 `avatars`、`media` 等：

```dart
await TencentCosClient.initialize(
  TencentCosConfig(
    appId: 'your_app_id',
    bucketName: 'your_bucket_name',
    region: 'ap-guangzhou',
    imagesPrefix: 'avatars',   // 图片类接口将使用 avatars/ 前缀
    videosPrefix: 'media',     // 视频类接口将使用 media/ 前缀
  ),
);
```

### 自定义文件夹（任意前缀）

不限于 images/videos，可用任意文件夹名上传、下载、删除：

```dart
// 上传到自定义文件夹
await client.upload.uploadToFolder(
  folder: 'documents',
  cosPath: 'report.pdf',
  srcPath: '/path/to/report.pdf',
  successUpload: (url) => print(url),
  failUpload: (err) => print(err),
);

// 批量上传到同一文件夹
await client.upload.uploadMultipleToFolder(
  folder: 'attachments',
  pathList: [
    {'cosPath': 'a.pdf', 'srcPath': '/path/a.pdf'},
    {'cosPath': 'b.pdf', 'srcPath': '/path/b.pdf'},
  ],
  successUpload: (urls) => print(urls),
);

// 获取自定义文件夹下的下载链接
final url = client.download.getDownloadUrlInFolder('documents', 'report.pdf');

// 删除自定义文件夹下的对象
await client.delete.deleteInFolder('documents', 'report.pdf');
```

### 地域列表

常用地域代码：

- `ap-beijing` - 北京
- `ap-shanghai` - 上海
- `ap-guangzhou` - 广州
- `ap-chengdu` - 成都
- `ap-nanjing` - 南京
- `ap-hongkong` - 香港

更多地域请参考 [腾讯云 COS 地域列表](https://cloud.tencent.com/document/product/436/6224)

## 注意事项

1. 使用临时密钥时，需要搭建 STS 服务器来获取临时密钥
2. 图片/视频类接口使用的文件夹前缀可在 [TencentCosConfig] 中通过 `imagesPrefix`、`videosPrefix` 配置；也可使用 `uploadToFolder`、`getDownloadUrlInFolder`、`deleteInFolder` 指定任意文件夹名
3. 建议在生产环境中使用临时密钥，避免永久密钥泄露
4. 确保存储桶的访问权限配置正确

## 依赖

本包基于 [tencentcloud_cos_sdk_plugin](https://github.com/maojiu-bb/cos-sdk-flutter-plugin) 开发。

## 许可证

MIT License
