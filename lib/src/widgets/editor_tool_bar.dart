import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rich_editor/src/utils/javascript_executor_base.dart';
import 'package:rich_editor/src/widgets/check_dialog.dart';
import 'package:rich_editor/src/widgets/insert_image_dialog.dart';
import 'package:rich_editor/src/widgets/insert_link_dialog.dart';
import 'package:rich_editor/src/widgets/tab_button.dart';
import 'font_size_dialog.dart';
import 'heading_dialog.dart';

class EditorToolBar extends StatelessWidget {
  final Function(File image)? getImageUrl;
  final Function(File video)? getVideoUrl;
  final JavascriptExecutorBase javascriptExecutor;
  final bool? enableVideo;
  final bool isCustom;
  final Widget? video,
      image,
      bold,
      italic,
      insertLink,
      insertImage,
      underLine,
      strikeThrough,
      superSubscript,
      subScript,
      clearFormat,
      undo,
      redo,
      blockQuote,
      font,
      fontSize,
      txtColor,
      bgColor,
      increaseIndent,
      decreaseIndent,
      alignLeft,
      alignRight,
      alignCenter,
      justifyLeft,
      justifyRight,
      justify;

  EditorToolBar({
    this.getImageUrl,
    this.getVideoUrl,
    required this.javascriptExecutor,
    this.bold,
    this.italic,
    this.insertLink,
    this.insertImage,
    this.underLine,
    this.strikeThrough,
    this.superSubscript,
    this.subScript,
    this.clearFormat,
    this.undo,
    this.redo,
    this.blockQuote,
    this.font,
    this.fontSize,
    this.txtColor,
    this.bgColor,
    this.increaseIndent,
    this.decreaseIndent,
    this.video,
    this.enableVideo,
    this.image,
    this.alignLeft,
    this.alignRight,
    this.alignCenter,
    this.justifyLeft,
    this.justifyRight,
    this.justify,
    required this.isCustom,
  });

  @override
  Widget build(BuildContext context) {
    if (isCustom) {
      return Column(
        children: [
          Wrap(
            children: [
              TabButton(
                tooltip: 'Bold',
                icon: bold ??
                    Icon(
                      Icons.format_bold,
                    ),
                onTap: () async {
                  await javascriptExecutor.setBold();
                },
              ),
              TabButton(
                tooltip: 'Italic',
                icon: italic ?? Icon(Icons.format_italic),
                onTap: () async {
                  await javascriptExecutor.setItalic();
                },
              ),
              TabButton(
                tooltip: 'Insert Link',
                icon: insertLink ??
                    Icon(
                      Icons.link,
                    ),
                onTap: () async {
                  var link = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) {
                      return InsertLinkDialog();
                    },
                  );
                  if (link != null)
                    await javascriptExecutor.insertLink(link[0], link[1]);
                },
              ),
              TabButton(
                tooltip: 'Insert Image',
                icon: image ??
                    Icon(
                      Icons.image,
                    ),
                onTap: () async {
                  var link = await showDialog(
                    context: context,
                    builder: (_) {
                      return InsertImageDialog();
                    },
                  );
                  if (link != null) {
                    if (getImageUrl != null && link[2]) {
                      link[0] = await getImageUrl!(File(link[0]));
                    }
                    await javascriptExecutor.insertImage(
                      link[0],
                      alt: link[1],
                    );
                  }
                },
              ),
              Visibility(
                visible: enableVideo!,
                child: TabButton(
                  tooltip: 'Insert video',
                  icon: video ?? Icon(Icons.video_call_sharp),
                  onTap: () async {
                    var link = await showDialog(
                      context: context,
                      builder: (_) {
                        return InsertImageDialog(isVideo: true);
                      },
                    );
                    if (link != null) {
                      if (getVideoUrl != null && link[2]) {
                        link[0] = await getVideoUrl!(File(link[0]));
                      }
                      await javascriptExecutor.insertVideo(
                        link[0],
                        fromDevice: link[2],
                      );
                    }
                  },
                ),
              ),
              TabButton(
                tooltip: 'Font format',
                icon: font ??
                    Icon(
                      Icons.text_format,
                    ),
                onTap: () async {
                  var command = await showDialog(
                    // isScrollControlled: true,
                    context: context,
                    builder: (_) {
                      return HeadingDialog();
                    },
                  );
                  if (command != null) {
                    if (command == 'p') {
                      await javascriptExecutor.setFormattingToParagraph();
                    } else if (command == 'pre') {
                      await javascriptExecutor.setPreformat();
                    } else if (command == 'blockquote') {
                      await javascriptExecutor.setBlockQuote();
                    } else {
                      await javascriptExecutor
                          .setHeading(int.tryParse(command)!);
                    }
                  }
                },
              ),
              // TODO: Show font button on iOS
              // Visibility(
              //   visible: (!kIsWeb && Platform.isAndroid),
              //   child: TabButton(
              //     tooltip: 'Font face',
              //     icon: Icon(Icons.font_download),,
              //     onTap: () async {
              //       var command = await showDialog(
              //         // isScrollControlled: true,
              //         context: context,
              //         builder: (_) {
              //           return FontsDialog();
              //         },
              //       );
              //       if (command != null)
              //         await javascriptExecutor.setFontName(command);
              //     },
              //   ),
              // ),

              // TabButton(
              //   icon: fontSize ??
              //       Icon(
              //         Icons.format_size,
              //       ),
              //   tooltip: 'Font Size',
              //   onTap: () async {
              //     String? command = await showDialog(
              //       // isScrollControlled: true,
              //       context: context,
              //       builder: (_) {
              //         return FontSizeDialog();
              //       },
              //     );
              //     if (command != null)
              //       await javascriptExecutor.setFontSize(int.tryParse(command)!);
              //   },
              // ),
              // TabButton(
              //   tooltip: 'Text Color',
              //   icon: Icon(Icons.format_color_),text,
              //   onTap: () async {
              //     var color = await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return ColorPickerDialog(color: Colors.blue);
              //       },
              //     );
              //     if (color != null)
              //       await javascriptExecutor.setTextColor(color);
              //   },
              // ),
              // TabButton(
              //   tooltip: 'Background Color',
              //   icon: Icon(Icons.format_color_),fill,
              //   onTap: () async {
              //     var color = await showDialog(
              //       context: context,
              //       builder: (BuildContext context) {
              //         return ColorPickerDialog(color: Colors.blue);
              //       },
              //     );
              //     if (color != null)
              //       await javascriptExecutor.setTextBackgroundColor(color);
              //   },
              // ),

              TabButton(
                tooltip: 'Underline',
                icon: underLine ?? Icon(Icons.format_underline),
                onTap: () async {
                  await javascriptExecutor.setUnderline();
                },
              ),
              TabButton(
                tooltip: 'Strike through',
                icon: strikeThrough ?? Icon(Icons.format_strikethrough),
                onTap: () async {
                  await javascriptExecutor.setStrikeThrough();
                },
              ),
              // TabButton(
              //   tooltip: 'Superscript',
              //   icon: Icon(Icons.superscript,
              //   onTap: () async {
              //     await javascriptExecutor.setSuperscript();
              //   },
              // ),
              // TabButton(
              //   tooltip: 'Subscript',
              //   icon: Icon(Icons.subscript,
              //   onTap: () async {
              //     await javascriptExecutor.setSubscript();
              //   },
              // ),
              // TabButton(
              //   tooltip: 'Clear format',
              //   icon: Icon(Icons.format_clear,),
              //   onTap: () async {
              //     await javascriptExecutor.removeFormat();
              //   },
              // ),
              TabButton(
                tooltip: 'Undo',
                icon: undo ??
                    Icon(
                      Icons.undo,
                    ),
                onTap: () async {
                  await javascriptExecutor.undo();
                },
              ),
              TabButton(
                tooltip: 'Redo',
                icon: redo ??
                    Icon(
                      Icons.redo,
                    ),
                onTap: () async {
                  await javascriptExecutor.redo();
                },
              ),
              // TabButton(
              //   tooltip: 'Blockquote',
              //   icon: Icon(Icons.format_quote,),
              //   onTap: () async {
              //     await javascriptExecutor.setBlockQuote();
              //   },
              // ),

              // TabButton(
              //   tooltip: 'Increase Indent',
              //   icon: Icon(Icons.format_indent),_increase,
              //   onTap: () async {
              //     await javascriptExecutor.setIndent();
              //   },
              // ),
              // TabButton(
              //   tooltip: 'Decrease Indent',
              //   icon: Icon(Icons.format_indent),_decrease,
              //   onTap: () async {
              //     await javascriptExecutor.setOutdent();
              //   },
              // ),
              TabButton(
                tooltip: 'Align Left',
                icon: alignLeft ?? Icon(Icons.format_align_left_outlined),
                onTap: () async {
                  await javascriptExecutor.setJustifyLeft();
                },
              ),
              TabButton(
                tooltip: 'Align Center',
                icon: alignCenter ?? Icon(Icons.format_align_center),
                onTap: () async {
                  await javascriptExecutor.setJustifyCenter();
                },
              ),
              TabButton(
                tooltip: 'Align Right',
                icon: alignRight ?? Icon(Icons.format_align_right),
                onTap: () async {
                  await javascriptExecutor.setJustifyRight();
                },
              ),
              TabButton(
                tooltip: 'Justify',
                icon: justify ?? Icon(Icons.format_align_justify),
                onTap: () async {
                  await javascriptExecutor.setJustifyFull();
                },
              ),
              TabButton(
                tooltip: 'Bullet List',
                icon: Icon(Icons.format_list_bulleted),
                onTap: () async {
                  await javascriptExecutor.insertBulletList();
                },
              ),
              TabButton(
                tooltip: 'Numbered List',
                icon: Icon(Icons.format_list_numbered),
                onTap: () async {
                  await javascriptExecutor.insertNumberedList();
                },
              ),
              TabButton(
                tooltip: 'Checkbox',
                icon: Icon(Icons.check_box_outlined),
                onTap: () async {
                  var text = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CheckDialog();
                    },
                  );
                  if (text != null)
                    await javascriptExecutor.insertCheckbox(text);
                },
              ),

              /// TODO: Implement Search feature
              // TabButton(
              //   tooltip: 'Search',
              //   icon: Icon(Icons.search,
              //   onTap: () async {
              //     // await javascriptExecutor.insertNumberedList();
              //   },
              // ),
            ],
          ),
        ],
      );
    } else {
      return Container(
        height: 54.0,
        child: Column(
          children: [
            Flexible(
              child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  TabButton(
                    tooltip: 'Bold',
                    icon: bold ??
                        Icon(
                          Icons.format_bold,
                        ),
                    onTap: () async {
                      await javascriptExecutor.setBold();
                    },
                  ),
                  TabButton(
                    tooltip: 'Italic',
                    icon: italic ?? Icon(Icons.format_italic),
                    onTap: () async {
                      await javascriptExecutor.setItalic();
                    },
                  ),
                  TabButton(
                    tooltip: 'Insert Link',
                    icon: insertLink ??
                        Icon(
                          Icons.link,
                        ),
                    onTap: () async {
                      var link = await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) {
                          return InsertLinkDialog();
                        },
                      );
                      if (link != null)
                        await javascriptExecutor.insertLink(link[0], link[1]);
                    },
                  ),
                  TabButton(
                    tooltip: 'Insert Image',
                    icon: image ??
                        Icon(
                          Icons.image,
                        ),
                    onTap: () async {
                      var link = await showDialog(
                        context: context,
                        builder: (_) {
                          return InsertImageDialog();
                        },
                      );
                      if (link != null) {
                        if (getImageUrl != null && link[2]) {
                          link[0] = await getImageUrl!(File(link[0]));
                        }
                        await javascriptExecutor.insertImage(
                          link[0],
                          alt: link[1],
                        );
                      }
                    },
                  ),
                  Visibility(
                    visible: enableVideo!,
                    child: TabButton(
                      tooltip: 'Insert video',
                      icon: video ?? Icon(Icons.video_call_sharp),
                      onTap: () async {
                        var link = await showDialog(
                          context: context,
                          builder: (_) {
                            return InsertImageDialog(isVideo: true);
                          },
                        );
                        if (link != null) {
                          if (getVideoUrl != null && link[2]) {
                            link[0] = await getVideoUrl!(File(link[0]));
                          }
                          await javascriptExecutor.insertVideo(
                            link[0],
                            fromDevice: link[2],
                          );
                        }
                      },
                    ),
                  ),
                  TabButton(
                    tooltip: 'Font format',
                    icon: font ??
                        Icon(
                          Icons.text_format,
                        ),
                    onTap: () async {
                      var command = await showDialog(
                        // isScrollControlled: true,
                        context: context,
                        builder: (_) {
                          return HeadingDialog();
                        },
                      );
                      if (command != null) {
                        if (command == 'p') {
                          await javascriptExecutor.setFormattingToParagraph();
                        } else if (command == 'pre') {
                          await javascriptExecutor.setPreformat();
                        } else if (command == 'blockquote') {
                          await javascriptExecutor.setBlockQuote();
                        } else {
                          await javascriptExecutor
                              .setHeading(int.tryParse(command)!);
                        }
                      }
                    },
                  ),
                  // TODO: Show font button on iOS
                  // Visibility(
                  //   visible: (!kIsWeb && Platform.isAndroid),
                  //   child: TabButton(
                  //     tooltip: 'Font face',
                  //     icon: Icon(Icons.font_download),,
                  //     onTap: () async {
                  //       var command = await showDialog(
                  //         // isScrollControlled: true,
                  //         context: context,
                  //         builder: (_) {
                  //           return FontsDialog();
                  //         },
                  //       );
                  //       if (command != null)
                  //         await javascriptExecutor.setFontName(command);
                  //     },
                  //   ),
                  // ),

                  TabButton(
                    icon: fontSize ??
                        Icon(
                          Icons.format_size,
                        ),
                    tooltip: 'Font Size',
                    onTap: () async {
                      String? command = await showDialog(
                        // isScrollControlled: true,
                        context: context,
                        builder: (_) {
                          return FontSizeDialog();
                        },
                      );
                      if (command != null)
                        await javascriptExecutor
                            .setFontSize(int.tryParse(command)!);
                    },
                  ),
                  // TabButton(
                  //   tooltip: 'Text Color',
                  //   icon: Icon(Icons.format_color_),text,
                  //   onTap: () async {
                  //     var color = await showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return ColorPickerDialog(color: Colors.blue);
                  //       },
                  //     );
                  //     if (color != null)
                  //       await javascriptExecutor.setTextColor(color);
                  //   },
                  // ),
                  // TabButton(
                  //   tooltip: 'Background Color',
                  //   icon: Icon(Icons.format_color_),fill,
                  //   onTap: () async {
                  //     var color = await showDialog(
                  //       context: context,
                  //       builder: (BuildContext context) {
                  //         return ColorPickerDialog(color: Colors.blue);
                  //       },
                  //     );
                  //     if (color != null)
                  //       await javascriptExecutor.setTextBackgroundColor(color);
                  //   },
                  // ),

                  TabButton(
                    tooltip: 'Underline',
                    icon: underLine ?? Icon(Icons.format_underline),
                    onTap: () async {
                      await javascriptExecutor.setUnderline();
                    },
                  ),
                  TabButton(
                    tooltip: 'Strike through',
                    icon: strikeThrough ?? Icon(Icons.format_strikethrough),
                    onTap: () async {
                      await javascriptExecutor.setStrikeThrough();
                    },
                  ),
                  // TabButton(
                  //   tooltip: 'Superscript',
                  //   icon: Icon(Icons.superscript,
                  //   onTap: () async {
                  //     await javascriptExecutor.setSuperscript();
                  //   },
                  // ),
                  // TabButton(
                  //   tooltip: 'Subscript',
                  //   icon: Icon(Icons.subscript,
                  //   onTap: () async {
                  //     await javascriptExecutor.setSubscript();
                  //   },
                  // ),
                  // TabButton(
                  //   tooltip: 'Clear format',
                  //   icon: Icon(Icons.format_clear,),
                  //   onTap: () async {
                  //     await javascriptExecutor.removeFormat();
                  //   },
                  // ),
                  TabButton(
                    tooltip: 'Undo',
                    icon: undo ??
                        Icon(
                          Icons.undo,
                        ),
                    onTap: () async {
                      await javascriptExecutor.undo();
                    },
                  ),
                  TabButton(
                    tooltip: 'Redo',
                    icon: redo ??
                        Icon(
                          Icons.redo,
                        ),
                    onTap: () async {
                      await javascriptExecutor.redo();
                    },
                  ),
                  // TabButton(
                  //   tooltip: 'Blockquote',
                  //   icon: Icon(Icons.format_quote,),
                  //   onTap: () async {
                  //     await javascriptExecutor.setBlockQuote();
                  //   },
                  // ),

                  // TabButton(
                  //   tooltip: 'Increase Indent',
                  //   icon: Icon(Icons.format_indent),_increase,
                  //   onTap: () async {
                  //     await javascriptExecutor.setIndent();
                  //   },
                  // ),
                  // TabButton(
                  //   tooltip: 'Decrease Indent',
                  //   icon: Icon(Icons.format_indent),_decrease,
                  //   onTap: () async {
                  //     await javascriptExecutor.setOutdent();
                  //   },
                  // ),
                  TabButton(
                    tooltip: 'Align Left',
                    icon: alignLeft ?? Icon(Icons.format_align_left_outlined),
                    onTap: () async {
                      await javascriptExecutor.setJustifyLeft();
                    },
                  ),
                  TabButton(
                    tooltip: 'Align Center',
                    icon: alignCenter ?? Icon(Icons.format_align_center),
                    onTap: () async {
                      await javascriptExecutor.setJustifyCenter();
                    },
                  ),
                  TabButton(
                    tooltip: 'Align Right',
                    icon: alignRight ?? Icon(Icons.format_align_right),
                    onTap: () async {
                      await javascriptExecutor.setJustifyRight();
                    },
                  ),
                  TabButton(
                    tooltip: 'Justify',
                    icon: justify ?? Icon(Icons.format_align_justify),
                    onTap: () async {
                      await javascriptExecutor.setJustifyFull();
                    },
                  ),
                  TabButton(
                    tooltip: 'Bullet List',
                    icon: Icon(Icons.format_list_bulleted),
                    onTap: () async {
                      await javascriptExecutor.insertBulletList();
                    },
                  ),
                  TabButton(
                    tooltip: 'Numbered List',
                    icon: Icon(Icons.format_list_numbered),
                    onTap: () async {
                      await javascriptExecutor.insertNumberedList();
                    },
                  ),
                  TabButton(
                    tooltip: 'Checkbox',
                    icon: Icon(Icons.check_box_outlined),
                    onTap: () async {
                      var text = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CheckDialog();
                        },
                      );
                      if (text != null)
                        await javascriptExecutor.insertCheckbox(text);
                    },
                  ),

                  /// TODO: Implement Search feature
                  // TabButton(
                  //   tooltip: 'Search',
                  //   icon: Icon(Icons.search,
                  //   onTap: () async {
                  //     // await javascriptExecutor.insertNumberedList();
                  //   },
                  // ),
                ],
              ),
            )
          ],
        ),
      );
    }
  }
}
