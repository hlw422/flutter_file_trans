import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pdfx/pdfx.dart';
import 'package:open_filex/open_filex.dart';

class FileItem {
  final String name;
  final String type;
  final int size; // 文件大小（字节）
  final DateTime modified; // 最后修改时间
  final String path; // 文件路径

  FileItem(this.name, this.type, this.size, this.modified, this.path);
}

class FileManagerPage extends StatefulWidget {
  const FileManagerPage({super.key});

  @override
  State<FileManagerPage> createState() => _FileManagerPageState();
}

class _FileManagerPageState extends State<FileManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<FileItem> sentFiles = [
    FileItem(
      "我发的报告.pdf",
      "pdf",
      1048576,
      DateTime.now().subtract(const Duration(days: 1)),
      "/path/to/sent1.pdf",
    ),
    FileItem(
      "我发的图片.png",
      "image",
      524288,
      DateTime.now().subtract(const Duration(hours: 5)),
      "/path/to/sent2.png",
    ),
  ];

  final List<FileItem> receivedFiles = [
    FileItem(
      "别人发的文档.txt",
      "text",
      2048,
      DateTime.now().subtract(const Duration(hours: 2)),
      "/path/to/recv1.txt",
    ),
    FileItem(
      "别人发的合同.pdf",
      "pdf",
      2097152,
      DateTime.now().subtract(const Duration(days: 3)),
      "/path/to/recv2.pdf",
    ),
  ];

  String searchQuery = "";
  String filterType = "all";
  double _progress = 0.0;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / 1024 / 1024).toStringAsFixed(1)} MB";
    }
    return "${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB";
  }

  String formatDate(DateTime date) {
    return DateFormat("yyyy-MM-dd HH:mm").format(date);
  }

  void _openFile(FileItem file) {
    if (file.type == "image") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewPage(imagePath: file.path),
        ),
      );
    } else if (file.type == "pdf") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PdfPreviewPage(pdfPath: file.path)),
      );
    } else {
      OpenFilex.open(file.path);
    }
  }

  Future<void> _uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    File file = File(result.files.single.path!);
    String fileName = result.files.single.name;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(file.path, filename: fileName),
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

        // 上传成功后，把文件加入 sentFiles 列表
        sentFiles.add(
          FileItem(
            fileName,
            fileName.endsWith(".pdf")
                ? "pdf"
                : fileName.endsWith(".png") || fileName.endsWith(".jpg")
                ? "image"
                : "text",
            file.lengthSync(),
            DateTime.now(),
            file.path,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _statusMessage = "上传失败: $e";
      });
    }
  }

  List<FileItem> _filterFiles(List<FileItem> files) {
    return files.where((file) {
      final matchesSearch = file.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchesFilter = filterType == "all" || file.type == filterType;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  Widget _buildFileList(List<FileItem> files) {
    final filteredFiles = _filterFiles(files);
    if (filteredFiles.isEmpty) {
      return const Center(child: Text("暂无文件"));
    }
    return ListView.builder(
      itemCount: filteredFiles.length,
      itemBuilder: (context, index) {
        final file = filteredFiles[index];
        return ListTile(
          leading: Icon(
            file.type == "text"
                ? Icons.description
                : file.type == "image"
                ? Icons.image
                : Icons.picture_as_pdf,
            color: Colors.blue,
          ),
          title: Text(file.name),
          subtitle: Text(
            "大小: ${formatFileSize(file.size)}\n修改时间: ${formatDate(file.modified)}",
          ),
          onTap: () => _openFile(file),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("文件管理"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "我发送的"),
            Tab(text: "我接收的"),
          ],
        ),
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "搜索文件",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          // 类型过滤
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: filterType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "all", child: Text("全部类型")),
                DropdownMenuItem(value: "text", child: Text("文本")),
                DropdownMenuItem(value: "image", child: Text("图片")),
                DropdownMenuItem(value: "pdf", child: Text("PDF")),
              ],
              onChanged: (value) {
                setState(() {
                  filterType = value!;
                });
              },
            ),
          ),
          // 文件列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFileList(sentFiles),
                _buildFileList(receivedFiles),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}

// 图片预览
class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  const ImagePreviewPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("图片预览")),
      body: Center(
        child: PhotoView(
          imageProvider: AssetImage(imagePath), // 本地文件可改 FileImage
        ),
      ),
    );
  }
}

// PDF 预览
class PdfPreviewPage extends StatelessWidget {
  final String pdfPath;
  const PdfPreviewPage({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    final pdfController = PdfController(
      document: PdfDocument.openAsset(pdfPath), // 本地文件可改 PdfDocument.openFile
    );

    return Scaffold(
      appBar: AppBar(title: const Text("PDF 预览")),
      body: PdfView(controller: pdfController),
    );
  }
}
