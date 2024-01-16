import 'package:flutter/material.dart';

import '../utils/utils.dart';
import 'custom_dialog_template.dart';

class InsertLinkDialog extends StatefulWidget {
  const InsertLinkDialog();
  @override
  State<InsertLinkDialog> createState() => _InsertLinkDialogState();
}

class _InsertLinkDialogState extends State<InsertLinkDialog> {
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
              if (value!.trim().isEmpty) {
                return "Please input link";
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              hintText: 'https://...',
            ),
          ),
          SizedBox(height: 20.0),
          Text('Label'),
          TextFormField(
            controller: label,
            validator: (value) {
              if (value!.trim().isEmpty) {
                return "Please input label";
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              hintText: 'type label text here',
            ),
          ),
        ],
        onDone: () {
          _key.currentState!.validate();
          if (label.text.trim().isNotEmpty && link.text.trim().isNotEmpty) {
            debugPrint("Link : ${formatUrl(link: link.text)}");
            Navigator.pop(context, [formatUrl(link: link.text), label.text]);
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
