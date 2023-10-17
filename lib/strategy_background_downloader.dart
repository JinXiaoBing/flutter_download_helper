library download_help;

import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:download_help/download_help.dart';
import 'package:download_help/download_progress.dart';
import 'package:download_help/download_strategy.dart';
import 'package:flutter/material.dart';

class BackgroundDownloaderStrategy implements DownloadStrategy {
  String? taskId;

  @override
  void cancelDownload() {
    FileDownloader().cancelTaskWithId(taskId ?? "");
  }

  @override
  Future<DownloadState> downloadFile({required DownloadTaskInfo task, OnProgressListener? onProgressListener}) async {
    final downloadTask = await createDownloadTask(url: task.url, filename: task.fileName);
    taskId = downloadTask.taskId;
    final result = await FileDownloader().download(downloadTask,
        onProgress: (progress) {
          debugPrint("backgroundDownloader下载单个文件进度：$progress");
          if (progress < 0) {
            return;
          }
          task.progress = progress;
          onProgressListener?.call(task);
        },
        elapsedTimeInterval: Duration(seconds: 1),
        onStatus: (status) => debugPrint('Status: $status'));
    debugPrint('result.status: ${result.status}');
    if (result.status == TaskStatus.complete) {
      String? path = await FileDownloader()
          .moveToSharedStorage(downloadTask, SharedStorage.downloads, directory: task.downloadSubDir);
      debugPrint("下载成功，将文件移到path：$path");
      task.downloadFilePath = path ?? "";
      task.downloadDirPath = File(path ?? "").parent.path;
      onProgressListener?.call(task);
      return DownloadState.complete;
    }
    if (result.status == TaskStatus.notFound) {
      return DownloadState.notFound;
    }
    if (result.status == TaskStatus.canceled) {
      return DownloadState.canceled;
    }
    if (result.status == TaskStatus.paused) {
      return DownloadState.paused;
    }
    return DownloadState.failed;
  }

  @override
  Future<DownloadState> downloadFiles(
      {required List<DownloadTaskInfo> tasks,
      OnProgressesListener? onProgressesListener,
      OnDownloadedCountListener? onDownloadedCountListener}) async {
    int downloadedCount = 0;
    DateTime lastDate = DateTime.now();
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];

      final state = await downloadFile(
        task: task,
        onProgressListener: (task) async {
          DateTime curDate = DateTime.now();
          if (curDate.difference(lastDate).inMilliseconds < 1000 && task.progress < 1.0) {
            return;
          }
          lastDate = curDate;
          tasks[i].progress = task.progress;
          await onProgressesListener?.call(tasks);
          debugPrint("backgroundDownload下载：当前下载多个文件总进度为${tasks.toString()}");
        },
      );
      if (state != DownloadState.complete) {
        return state;
      }
      downloadedCount++;
      debugPrint("backgroundDownload下载：已下载完成文件数量：$downloadedCount");
      onDownloadedCountListener?.call(downloadedCount);
    }
    return DownloadState.complete;
  }

  Future<DownloadTask> createDownloadTask({
    required String url,
    Map<String, String>? params,
    Map<String, String>? headers,
    required String filename,
  }) async {
    return DownloadTask(
        url: url,
        urlQueryParameters: params,
        filename: filename,
        headers: headers ?? {"Accept-Encoding": "*"},
        baseDirectory: BaseDirectory.temporary,
        updates: Updates.statusAndProgress,
        requiresWiFi: false,
        retries: 0,
        allowPause: true);
  }

  @override
  Future<bool> openFile(String path) async {
    return await FileDownloader().openFile(filePath: path);
  }
}