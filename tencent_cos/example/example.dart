import 'package:tencent_cos/tencent_cos.dart';

void main() async {
  // 初始化腾讯云 COS 客户端
  await TencentCosClient.initialize(
    TencentCosConfig(
      appId: 'your_app_id',
      bucketName: 'your_bucket_name',
      region: 'ap-guangzhou',
      useSessionToken: true,
      stsUrl: 'https://your-sts-server.com/sts',
      isDebuggable: true,
    ),
  );

  // 获取客户端实例
  final client = TencentCosClient.instance;

  // 上传图片
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

  // 上传视频
  await client.upload.uploadVideoToTencent(
    'test.mp4',
    '/path/to/local/video.mp4',
    (uploadUrl) {
      print('上传成功: $uploadUrl');
    },
  );

  // 上传多张图片
  await client.upload.uploadMultipleImageToTencent(
    pathList: [
      {'cosPath': 'image1.jpg', 'srcPath': '/path/to/image1.jpg'},
      {'cosPath': 'image2.jpg', 'srcPath': '/path/to/image2.jpg'},
    ],
    successUpload: (uploadUrlList) {
      print('批量上传成功: $uploadUrlList');
    },
  );

  // 获取下载链接
  final imageUrl = client.download.getImageDownloadUrl('test.jpg');
  print('图片下载链接: $imageUrl');

  final videoUrl = client.download.getVideoDownloadUrl('test.mp4');
  print('视频下载链接: $videoUrl');

  // 删除文件
  await client.delete.deleteImage('test.jpg');
  await client.delete.deleteVideo('test.mp4');

  // 批量删除
  await client.delete.deleteObjects([
    'images/image1.jpg',
    'images/image2.jpg',
  ]);
}
