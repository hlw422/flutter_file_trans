import 'package:flutter/material.dart';
import 'package:flutter_file_trans/page/file_download_page.dart';
import 'package:flutter_file_trans/page/file_upload_page.dart';
import 'package:flutter_file_trans/page/menu_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
 const MyApp({super.key});

 @override
 Widget build(BuildContext context) {
  return MaterialApp(
   debugShowCheckedModeBanner: false,
   title: 'Navigation Demo',
   initialRoute: '/menu', // 初始路由改为菜单首页
   routes: {
    '/menu':(context) => const MenuHomePage(),
    '/upload': (context) => FileUploadPage(),
    '/download': (context) => FileDownloadPage(),
   },
  );
 }
}


