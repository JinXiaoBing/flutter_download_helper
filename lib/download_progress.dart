library download_help;

class DownloadTaskInfo {
  String url;
  String fileName;
  String downloadBaseDir;
  String downloadSubDir;
  String downloadFilePath = "";
  String downloadDirPath = "";
  double progress = 0.0;

  DownloadTaskInfo({
    required this.url,
    required this.fileName,
    required this.downloadBaseDir,
    required this.downloadSubDir,
  });
}
