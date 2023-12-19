import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rich_editor/src/models/enum/bar_position.dart';
import 'package:rich_editor/src/models/rich_editor_options.dart';
import 'package:rich_editor/src/services/local_server.dart';
import 'package:rich_editor/src/utils/javascript_executor_base.dart';
import 'package:rich_editor/src/widgets/editor_tool_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RichEditor extends StatefulWidget {
  final String? value;
  final RichEditorOptions? editorOptions;
  final Function(File image)? getImageUrl;
  final Function(File video)? getVideoUrl;
  final bool? zoom;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  RichEditor({
    Key? key,
    this.value,
    this.editorOptions,
    this.getImageUrl,
    this.getVideoUrl,
    this.zoom,
    this.gestureRecognizers,
    this.decoration,
    this.margin,
  }) : super(key: key);

  @override
  RichEditorState createState() => RichEditorState();
}

class RichEditorState extends State<RichEditor> {
  final Key _mapKey = UniqueKey();
  String assetPath = 'packages/rich_editor/assets/editor/editor.html';
  WebViewController webCon = WebViewController();
  int port = 5321;
  String html = '';
  LocalServer? localServer;
  JavascriptExecutorBase javascriptExecutor = JavascriptExecutorBase();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!kIsWeb && Platform.isIOS) {
        await _initServer();
        await _loadHtmlFromAssets();
      } else {
        webCon = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) async {
                if (url != '') {
                  javascriptExecutor.init(webCon);
                  await _setInitialValues();
                  _addJSListener();
                }
              },
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(
              Uri.parse('file:///android_asset/flutter_assets/$assetPath'));
        await webCon.enableZoom(widget.zoom ?? false);
        await webCon.runJavaScript("""
              var style = document.createElement('style');
              style.innerHTML = "img {border:none;max-width: auto; height: auto;object-fit: contain;pointer-events: none;user-select: none; touch-action: none; touch-action: pan-x pan-y;  overflow: hidden;}"
              document.head.appendChild(style);
          """);
        setState(() {});
      }
    });
  }

  _initServer() async {
    localServer = LocalServer(port);
    await localServer!.start(_handleRequest);
  }

  void _handleRequest(HttpRequest request) {
    try {
      if (request.method == 'GET' &&
          request.uri.queryParameters['query'] == "getRawTeXHTML") {
      } else {}
    } catch (e) {
      print('Exception in handleRequest: $e');
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && !Platform.isAndroid) {
      localServer!.close();
    }
    super.dispose();
  }

  _loadHtmlFromAssets() async {
    final filePath = assetPath;
    await webCon.loadRequest(Uri.parse('http://localhost:$port/$filePath'));
  }

  var loading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: widget.editorOptions!.barPosition == BarPosition.TOP,
          child: _buildToolBar(),
        ),
        Visibility(
          visible: widget.editorOptions!.barPosition == BarPosition.CUSTOM,
          child: _buildToolBar(),
        ),
        Expanded(
          child: Container(
            margin: widget.margin,
            decoration: widget.decoration ??
                BoxDecoration(
                  color: Colors.white,
                ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: WebViewWidget(
                    key: _mapKey,
                    controller: webCon,
                    gestureRecognizers: widget.gestureRecognizers ??
                        [
                          Factory(() => VerticalDragGestureRecognizer()
                            ..onUpdate = (_) {}),
                          Factory(() => HorizontalDragGestureRecognizer()),
                        ].toSet(),
                  ),
                ),
                Positioned.fill(
                  child: Visibility(
                    visible: loading,
                    child: Center(
                        child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    )),
                  ),
                )
              ],
            ),
          ),
        ),
        Visibility(
          visible: widget.editorOptions!.barPosition == BarPosition.BOTTOM,
          child: _buildToolBar(),
        ),
      ],
    );
  }

  _buildToolBar() {
    if (widget.editorOptions!.barPosition == BarPosition.CUSTOM) {
      return EditorToolBar(
        isCustom: true,
        getImageUrl: widget.getImageUrl,
        getVideoUrl: widget.getVideoUrl,
        javascriptExecutor: javascriptExecutor,
        enableVideo: false,
        font: _customIcon('text-italic.svg'),
        italic: _customIcon('text-italic.svg'),
        bold: _customIcon('text-bold.svg'),
        insertLink: _customIcon('link.svg'),
        underLine: _customIcon('text-underline.svg'),
        alignCenter: _customIcon('textalign-center.svg'),
        alignLeft: _customIcon('textalign-left.svg'),
        alignRight: _customIcon('textalign-right.svg'),
        justify: _customIcon('textalign-justifycenter.svg'),
      );
    } else {
      return EditorToolBar(
        isCustom: false,
        getImageUrl: widget.getImageUrl,
        getVideoUrl: widget.getVideoUrl,
        javascriptExecutor: javascriptExecutor,
        enableVideo: widget.editorOptions!.enableVideo,
      );
    }
  }

  SvgPicture _customIcon(String icon) =>
      SvgPicture.asset('../assets/icon/$icon');

  _setInitialValues() async {
    if (widget.value != null) await javascriptExecutor.setHtml(widget.value!);
    if (widget.editorOptions!.padding != null)
      await javascriptExecutor.setPadding(widget.editorOptions!.padding!);
    if (widget.editorOptions!.backgroundColor != null)
      await javascriptExecutor
          .setBackgroundColor(widget.editorOptions!.backgroundColor!);
    if (widget.editorOptions!.baseTextColor != null)
      await javascriptExecutor
          .setBaseTextColor(widget.editorOptions!.baseTextColor!);
    if (widget.editorOptions!.placeholder != null)
      await javascriptExecutor
          .setPlaceholder(widget.editorOptions!.placeholder!);
    if (widget.editorOptions!.baseFontFamily != null)
      await javascriptExecutor
          .setBaseFontFamily(widget.editorOptions!.baseFontFamily!);
  }

  _addJSListener() async {
    // _controller!.addJavaScriptHandler(
    //     handlerName: 'editor-state-changed-callback://',
    //     callback: (c) {
    //       print('Callback $c');
    //     });
  }

  /// Get current HTML from editor
  Future<String?> getHtml() async {
    try {
      html = await javascriptExecutor.getCurrentHtml();
    } catch (e) {}
    return html;
  }

  /// Set your HTML to the editor
  setHtml(String html) async {
    return await javascriptExecutor.setHtml(html);
  }

  /// Hide the keyboard using JavaScript since it's being opened in a WebView
  /// https://stackoverflow.com/a/8263376/10835183
  unFocus() {
    javascriptExecutor.unFocus();
  }

  /// Clear editor content using Javascript
  clear() {
    webCon.runJavaScript('document.getElementById(\'editor\').innerHTML = "";');
  }

  /// Focus and Show the keyboard using JavaScript
  /// https://stackoverflow.com/a/6809236/10835183
  focus() {
    javascriptExecutor.focus();
  }

  /// Add custom CSS code to Editor
  loadCSS(String cssFile) {
    var jsCSSImport = "(function() {" +
        "    var head  = document.getElementsByTagName(\"head\")[0];" +
        "    var link  = document.createElement(\"link\");" +
        "    link.rel  = \"stylesheet\";" +
        "    link.type = \"text/css\";" +
        "    link.href = \"" +
        cssFile +
        "\";" +
        "    link.media = \"all\";" +
        "    head.appendChild(link);" +
        "}) ();";
    webCon.runJavaScript(jsCSSImport);
  }

  /// if html is equal to html RichTextEditor sets by default at start
  /// (<p>​</p>) so that RichTextEditor can be considered as 'empty'.
  Future<bool> isEmpty() async {
    html = await javascriptExecutor.getCurrentHtml();
    return html == '<p>​</p>';
  }

  /// Enable Editing (If editing is disabled)
  enableEditing() async {
    await javascriptExecutor.setInputEnabled(true);
  }

  /// Disable Editing (Could be used for a 'view mode')
  disableEditing() async {
    await javascriptExecutor.setInputEnabled(false);
  }
}
