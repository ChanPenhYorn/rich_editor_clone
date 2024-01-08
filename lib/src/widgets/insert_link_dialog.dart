import 'package:flutter/material.dart';

import 'custom_dialog_template.dart';

class InsertLinkDialog extends StatelessWidget {
  final link = TextEditingController();
  final label = TextEditingController();
  final _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: CustomDialogTemplate(
        body: [
          Text('Link'),
          TextFormField(
            controller: link,
            validator: (value) {
              return "Please input link";
            },
            decoration: InputDecoration(
              hintText: 'type link here',
            ),
          ),
          SizedBox(height: 20.0),
          Text('Label'),
          TextFormField(
            controller: label,
            validator: (value) {
              return "Please input label";
            },
            decoration: InputDecoration(
              hintText: 'type label text here',
            ),
          ),
        ],
        onDone: () {
          _key.currentState!.validate();
          if (label.text.trim().isNotEmpty) {
            Navigator.pop(context, [link.text, label.text]);
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
