import 'package:flutter/material.dart';

class MenuHomePage extends StatelessWidget {
 const MenuHomePage({super.key});

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   appBar: AppBar(title: const Text('首页菜单'), centerTitle: true),
   body: Padding(
    padding: const EdgeInsets.all(16.0),
    child: GridView.count(
     // 网格布局，每行显示2个按钮
     crossAxisCount: 4,
     crossAxisSpacing: 16,
     mainAxisSpacing: 16,
     childAspectRatio: 1.5, // 按钮宽高比
     children: [
       _buildMenuButton(
       context,
       title: '上传文件',
       icon: Icons.upload_file_outlined,
       route: '/upload',
      ),
      // 商品列表页按钮
      _buildMenuButton(
       context,
       title: '下载文件',
       icon: Icons.download_outlined,
       route: '/download',
      ),
       // 商品列表页按钮
      _buildMenuButton(
       context,
       title: '文件同步',
       icon: Icons.file_copy_outlined,
       route: '/async',
      ),
      // 购物车按钮
      _buildMenuButton(
       context,
       title: '我的购物车',
       icon: Icons.shopping_cart,
       route: '/cart',
      ),
      // 状态组件页按钮
      _buildMenuButton(
       context,
       title: '状态组件示例',
       icon: Icons.widgets,
       route: '/myStatefulWidget',
      ),
      // 二维码扫描页按钮
      _buildMenuButton(
       context,
       title: '二维码扫描',
       icon: Icons.qr_code_scanner,
       route: '/qrcodeScanner',
      ),
      // Scaffold示例页按钮
      _buildMenuButton(
       context,
       title: '底部导航栏示例',
       icon: Icons.login_outlined,
       route: '/Scaffold',
      ),
      // 其他页面按钮（可根据需要添加）
      _buildMenuButton(
       context,
       title: '记事本',
       icon: Icons.arrow_forward,
       route: '/home',
      ),
      // 其他页面按钮（可根据需要添加）
      _buildMenuButton(
       context,
       title: 'Stack布局',
       icon: Icons.abc_rounded,
       route: '/StackDis',
      ),
      _buildMenuButton(
       context,
       title: 'Switch状态管理',
       icon: Icons.switch_access_shortcut,
       route: '/switch',
      ),
      _buildMenuButton(
       context,
       title: '网络检测',
       icon: Icons.network_check_outlined,
       route: '/networkCheck',
      ),
      _buildMenuButton(
       context,
       title: 'webview示例',
       icon: Icons.web,
       route: '/webview',
      ),
      _buildMenuButton(
       context,
       title: 'signalR示例',
       icon: Icons.phone_in_talk,
       route: '/signalR',
      ),
      _buildMenuButton(
       context,
       title: '聊天列表',
       icon: Icons.people,
       route: '/chat',
      ),
      _buildMenuButton(
       context,
       title: '登录',
       icon: Icons.login_outlined,
       route: '/login',
      ),
      _buildMenuButton(
       context,
       title: '方块游戏',
       icon: Icons.gamepad_sharp,
       route: '/squareGame',
      ),
     ],
    ),
   ),
  );
 }

 // 封装菜单按钮组件
 Widget _buildMenuButton(
  BuildContext context, {
  required String title,
  required IconData icon,
  required String route,
 }) {
  return ElevatedButton.icon(
   icon: Icon(icon, size: 24),
   label: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
     title,
     style: const TextStyle(fontSize: 16),
     textAlign: TextAlign.center,
    ),
   ),
   style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(12),
   ),
   onPressed: () {
    // 点击跳转对应路由
    Navigator.pushNamed(context, route);
   },
  );
 }
}

