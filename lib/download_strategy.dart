library download_help;

import 'package:download_help/download_help.dart';
import 'package:download_help/download_progress.dart';

typedef OnProgressListener = void Function(DownloadTaskInfo result);
typedef OnProgressesListener =  Function(List<DownloadTaskInfo> result);
typedef OnDownloadedSizeListener =  Function(int count);
typedef OnDownloadedCountListener =  Function(int downloadedCount);

abstract class DownloadStrategy {
  ///下载单一文件
  Future<DownloadResult> downloadFile({
    required DownloadTaskInfo task,
    OnProgressListener? onProgressListener,
  });

  ///下载多个文件
  Future<DownloadResult> downloadFiles({
    required List<DownloadTaskInfo> tasks,
    OnProgressesListener? onProgressesListener,
    OnDownloadedCountListener? onDownloadedCountListener,
  });

  Future cancelDownload();
  Future<bool> openFile(String path);
}
