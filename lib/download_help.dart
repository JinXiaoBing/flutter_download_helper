library download_help;

import 'package:download_help/download_progress.dart';
import 'package:download_help/download_strategy.dart';

enum DownloadState {
  complete,
  notFound,
  failed,
  canceled,
  paused;
}

class DownloadManager {
  static DownloadManager? _instance;

  static DownloadManager get instance {
    _instance ??= DownloadManager._();
    return _instance!;
  }

  late DownloadStrategy downloadStrategy;

  DownloadManager._();

  void setStrategy(DownloadStrategy downloadStrategy) {
    this.downloadStrategy = downloadStrategy;
  }

  void downloadFile({
    required String url,
    required String downloadBaseDir,
    required String downloadSubDir,
    required String fileName,
    OnProgressListener? onProgressListener,
  }) {
    DownloadTaskInfo task = DownloadTaskInfo(
      url: url,
      fileName: fileName,
      downloadBaseDir: downloadBaseDir,
      downloadSubDir: downloadSubDir,
    );
    downloadStrategy.downloadFile(task: task, onProgressListener: onProgressListener);
  }

  Future<DownloadState> downloadFiles({
    required List<String> urls,
    required List<String> fileNames,
    required String downloadDir,
    required String downloadSubDir,
    OnProgressesListener? onProgressesListener,
    OnDownloadedCountListener? onDownloadedCountListener,
  }) async {
    if (urls.length != fileNames.length) {
      return DownloadState.failed;
    }
    List<DownloadTaskInfo> tasks = [];
    for (int i = 0; i < urls.length; i++) {
      tasks.add(DownloadTaskInfo(
        url: urls[i],
        fileName: fileNames[i],
        downloadBaseDir: downloadDir,
        downloadSubDir: downloadSubDir,
      ));
    }

    return await downloadStrategy.downloadFiles(
      tasks: tasks,
      onProgressesListener: onProgressesListener,
      onDownloadedCountListener: onDownloadedCountListener,
    );
  }

  void cancelDownload() {
    downloadStrategy.cancelDownload();
  }

  Future<bool> openFile(String path) async {
    return await downloadStrategy.openFile(path);
  }
}
