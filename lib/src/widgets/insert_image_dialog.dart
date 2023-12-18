import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'custom_dialog_template.dart';

class InsertImageDialog extends StatefulWidget {
  final bool isVideo;

  InsertImageDialog({this.isVideo = false});

  @override
  _InsertImageDialogState createState() => _InsertImageDialogState();
}

class _InsertImageDialogState extends State<InsertImageDialog> {
  TextEditingController link = TextEditingController();

  TextEditingController alt = TextEditingController();
  bool picked = false;

  @override
  Widget build(BuildContext context) {
    return CustomDialogTemplate(
      body: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.isVideo ? 'Video link' : 'Image link'),
            ElevatedButton(
              onPressed: () => getImage(),
              child: Text('...'),
            ),
          ],
        ),
        TextFormField(
          controller: link,
          decoration: InputDecoration(hintText: 'https://...', isDense: true),
        ),
        Visibility(
          visible: !widget.isVideo,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.0),
              Text('Alt text (optional)'),
              TextFormField(
                controller: alt,
                decoration: InputDecoration(
                  hintText: 'optional',
                ),
              ),
            ],
          ),
        ),
      ],
      onDone: () => Navigator.pop(context, [link.text, alt.text, picked]),
      onCancel: () => Navigator.pop(context),
    );
  }

  Future getImage() async {
    final picker = ImagePicker();
    var image;
    if (widget.isVideo) {
      image = await picker.pickVideo(source: ImageSource.gallery);
    } else {
      image = await picker.pickImage(
        source: ImageSource.gallery,
      );
    }

    if (image != null) {
      link.text = image.path;
      picked = true;
    }
  }
}
