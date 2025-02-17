import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rich_editor/rich_editor.dart';

class BasicDemo extends StatelessWidget {
  GlobalKey<RichEditorState> keyEditor = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Basic Demo'),
        actions: [
          PopupMenuButton(
            child: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: null,
              disabledColor: Colors.white,
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Get HTML'),
                  value: 0,
                ),
                PopupMenuItem(
                  child: Text('Clear content'),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text('Hide keyboard'),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text('Show Keyboard'),
                  value: 3,
                ),
              ];
            },
            onSelected: (val) async {
              switch (val) {
                case 0:
                  String? html = await keyEditor.currentState?.getHtml();
                  print(html);
                  break;
                case 1:
                  await keyEditor.currentState?.clear();
                  break;
                case 2:
                  await keyEditor.currentState?.unFocus();
                  break;
                case 3:
                  await keyEditor.currentState?.focus();
                  break;
              }
            },
          ),
        ],
      ),
      body: RichEditor(
        key: keyEditor,
        value: '''
      
      <p>​
        <img src="https://i.pinimg.com/736x/dd/e0/fc/dde0fcc5632f23bbe3548cb94941882a.jpg">
        <img src="https://i.pinimg.com/736x/dd/e0/fc/dde0fcc5632f23bbe3548cb94941882a.jpg">
      </p>
      Setec Instit
          ''', // initial HTML data
        editorOptions: RichEditorOptions(
          placeholder: 'Start typing',
          // backgroundColor: Colors.blueGrey, // Editor's bg color
          // baseTextColor: Colors.white,
          // editor padding
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          // font name
          baseFontFamily: 'sans-serif',
          // Position of the editing bar (BarPosition.TOP or BarPosition.BOTTOM)
          barPosition: BarPosition.TOP,
        ),

        // You can return a Link (maybe you need to upload the image to your
        // storage before displaying in the editor or you can also use base64
        getImageUrl: (image) {
          String link = 'https://avatars.githubusercontent.com/u/24323581?v=4';
          String base64 = base64Encode(image.readAsBytesSync());
          String base64String = 'data:image/png;base64, $base64';
          return base64String;
        },
        getVideoUrl: (video) {
          String link = 'https://file-examples-com.github.io/uploads/2017/'
              '04/file_example_MP4_480_1_5MG.mp4';
          return link;
        },
        onLoadStop: () {},
        onLoadStart: () {},
      ),
    );
  }
}
