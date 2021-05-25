import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:one_chat_rebuild/widgets/app_bar_widget.dart';

class ImageDetail extends StatelessWidget {
  final String url;
  final String name;
  final String chatRoomId;
  final String photoName;
  ImageDetail({
    @required this.url,
    @required this.name,
    @required this.chatRoomId,
    @required this.photoName,
  });
  Future<void> _download() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FlutterDownloader.initialize(debug: true);
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: 'Downloads',
      showNotification: true,
      openFileFromNotification: true,
    );
    print(taskId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: CustomAppBar(name, [
        IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () {
              _download();
            })
      ]),
      body: Center(
        child: Container(
          child: Image.network(url),
        ),
      ),
    );
  }
}
