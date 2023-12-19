import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class TabButton extends StatelessWidget {
  final Widget? icon;
  final Function? onTap;
  final String tooltip;
  final bool selected;

  TabButton({this.icon, this.onTap, this.tooltip = '', this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
      child: Tooltip(
        message: '$tooltip',
        child: Container(
          height: 40.0,
          width: 40.0,
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
              onTap: () => onTap!(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class DropDown extends StatefulWidget {
  DropDown();

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  static final formats = <Map<String, String>>[
    {'id': '1', 'title': '<h1>Heading 1</h1>'},
    {'id': '2', 'title': '<h2>Heading 2</h2>'},
    {'id': '3', 'title': '<h3>Heading 3</h3>'},
    {'id': '4', 'title': '<h4>Heading 4</h4>'},
    {'id': '5', 'title': '<h5>Heading 5</h5>'},
    {'id': '6', 'title': '<h6>Heading 6</h6>'},
  ];
  Map<String, String> dropdownValue = formats.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Map<String, String>>(
        value: dropdownValue,
        onChanged: (Map<String, String>? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
        },
        items: formats.map<DropdownMenuItem<Map<String, String>>>(
            (Map<String, String> value) {
          return DropdownMenuItem<Map<String, String>>(
            value: value,
            child: HtmlWidget(value['title']!),
          );
        }).toList(),
      ),
    );
  }
}
