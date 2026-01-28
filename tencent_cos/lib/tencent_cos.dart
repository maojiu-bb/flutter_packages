library tencent_cos;

export 'src/credential/fetch_credentials.dart' show CosCredentialsException;
export 'src/tencent_cos_client.dart';
export 'src/transfer/cos_delete.dart';
export 'src/transfer/cos_download.dart';
export 'src/transfer/cos_upload.dart';
export 'package:tencentcloud_cos_sdk_plugin/pigeon.dart'
    show STSCredentialScope;
export 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart'
    show TransferTask;
