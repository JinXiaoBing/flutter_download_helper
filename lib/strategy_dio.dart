library download_help;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:download_help/download_help.dart';
import 'package:download_help/download_progress.dart';
import 'package:download_help/download_strategy.dart';
import 'package:flutter/widgets.dart';

class DioStrategy implements DownloadStrategy {
  late Dio dio;
  CancelToken? cancelToken;

  DioStrategy() {
    dio = Dio();
    dio.options.connectTimeout = Duration(hours: 1);
    dio.options.receiveTimeout = Duration(hours: 1);
    dio.options.headers = {HttpHeaders.acceptEncodingHeader: '*'};
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  @override
  Future<DownloadState> downloadFile({
    required DownloadTaskInfo task,
    OnProgressListener? onProgressListener,
  }) async {
    try {
      cancelToken = CancelToken();
      await dio.download(
        task.url,
        "${task.downloadBaseDir}${Platform.pathSeparator}${task.downloadSubDir}${Platform.pathSeparator}${task.fileName}",
        cancelToken: cancelToken,
        onReceiveProgress: (count, total) {
          double progress = 0.0;
          if (total > 0) {
            progress = count / total;
          }
          debugPrint("dio下载：当前下载一个文件进度为$progress，count = $count, total = $total");
          task.progress = progress;
          onProgressListener?.call(task);
        },
      );
    } catch (e) {
      return DownloadState.failed;
    }
    return DownloadState.complete;
  }

  @override
  void cancelDownload() {
    cancelToken?.cancel();
    cancelToken = null;
  }

  @override
  Future<DownloadState> downloadFiles({
    required List<DownloadTaskInfo> tasks,
    OnProgressesListener? onProgressesListener,
    OnDownloadedCountListener? onDownloadedCountListener,
  }) async {
    int downloadedCount = 0;
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      await downloadFile(
        task: task,
        onProgressListener: (task) {
          tasks[i].progress = task.progress;
          onProgressesListener?.call(tasks);
          debugPrint("dio下载：当前下载多个文件总进度为${tasks.toString()}");
        },
      );
      downloadedCount++;
      debugPrint("dio下载：已下载完成文件数量：$downloadedCount");
      onDownloadedCountListener?.call(downloadedCount);
    }

    return DownloadState.complete;
  }

  @override
  Future<bool> openFile(String path) async {
    return false;
  }
}
