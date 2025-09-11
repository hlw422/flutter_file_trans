import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({super.key});

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? _selectedFile;
  String? _fileName;
  double _progress = 0.0;
  String _statusMessage = "";

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _statusMessage = "";
        _progress = 0.0;
      });
    }
  }

  Future<void> uploadFile() async {
    if (_selectedFile == null) {
      setState(() {
        _statusMessage = "请先选择文件";
      });
      return;
    }

    String fileName = _selectedFile!.path.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        _selectedFile!.path,
        filename: fileName,
      ),
    });

    Dio dio = Dio();

    try {
      var response = await dio.post(
        "http://localhost:9001/upload", // 改成你的后端接口
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
        onSendProgress: (sent, total) {
          setState(() {
            _progress = sent / total;
          });
        },
      );

      setState(() {
        _statusMessage = "上传成功: ${response.data}";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "上传失败: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("文件上传")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text("选择文件"),
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 10),
              Text("已选择文件: $_fileName"),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: uploadFile,
              child: const Text("上传文件"),
            ),
            const SizedBox(height: 20),
            if (_progress > 0)
              LinearProgressIndicator(value: _progress),
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(_statusMessage),
            ],
          ],
        ),
      ),
    );
  }
}
