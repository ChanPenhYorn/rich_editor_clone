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
<p><img src=\"http://192.168.90.34:3000/assets/source/98/scaled_1000001587.jpg\" width=\"0\" height=\"0\" data-x=\"0\" data-y=\"0\" style=\"width: 374.314px; height: 582.19px;\"><br></p><p><img src=\"http://192.168.90.34:3000/assets/source/a1/scaled_1000004626__02.png\" width=\"600\" height=\"600\"><br></p><p><a href=\"https://www.youtube.com\">click on link to view YouTube&nbsp;</a><br></p><blockquote><span style=\"color: rgb(33, 243, 158);\">Yes<span style=\"font-size: xx-large; font-family: serif;\">gh</span></span></blockquote>
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
      ),
    );
  }
}
