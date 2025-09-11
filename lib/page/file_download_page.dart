import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloadPage extends StatefulWidget {
  const FileDownloadPage({super.key});

  @override
  State<FileDownloadPage> createState() => _FileDownloadPageState();
}

class _FileDownloadPageState extends State<FileDownloadPage> {
  double progress = 0.0;
  String status = "等待下载...";
  final TextEditingController _fileNameController = TextEditingController();

  Future<void> downloadFile(String filename) async {
    if(filename.isEmpty){
      setState(() {
        status = "文件名不能为空";
      });
      return;
    }
    try {
      Dio dio = Dio();
      // 后端下载接口
      String url = "http://localhost:9001/download/$filename";

      // 获取存储路径 (Documents 目录)
      Directory dir = await getApplicationDocumentsDirectory();
      String savePath = "${dir.path}/$filename";

      setState(() {
        status = "下载中...";
      });

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (count, total) {
          setState(() {
            progress = total > 0 ? count / total : 0;
          });
        },
      );

      setState(() {
        status = "下载完成，保存到: $savePath";
      });
    } catch (e) {
      setState(() {
        status = "下载失败: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("文件下载示例")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fileNameController,
              decoration: const InputDecoration(
                labelText: "文件名",
                hintText: "请输入文件名",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => downloadFile(_fileNameController.text.trim()), // 下载 test.txt
              child: const Text("下载文件"),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text("进度: ${(progress * 100).toStringAsFixed(0)}%"),
            const SizedBox(height: 16),
            Text("状态: $status"),
          ],
        ),
      ),
    );
  }
}
