import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  final Color? iconColor, bgColor;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final double imageRaduis;
  final String? javaScript;
  final Widget? customLoading;
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
      font,
      fontSize,
      alignLeft,
      alignRight,
      alignCenter,
      justifyLeft,
      justifyRight,
      bulletList,
      numList,
      checkBox,
      justify;
  RichEditor({
    Key? key,
    this.value,
    this.editorOptions,
    this.getImageUrl,
    this.getVideoUrl,
    this.gestureRecognizers,
    this.decoration,
    this.margin,
    this.iconColor,
    this.video,
    this.image,
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
    this.font,
    this.fontSize,
    this.alignLeft,
    this.alignRight,
    this.alignCenter,
    this.justifyLeft,
    this.justifyRight,
    this.justify,
    this.imageRaduis = 5,
    this.javaScript,
    this.customLoading,
    this.bulletList,
    this.numList,
    this.checkBox,
    this.bgColor,
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
        _initWebView('file:///android_asset/flutter_assets/$assetPath');
        setState(() {});
      }
    });
  }

  void _initWebView(String url) {
    webCon = WebViewController()
      ..clearCache()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
        widget.bgColor ?? Theme.of(context).scaffoldBackgroundColor,
      )
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            setState(() {
              loading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              loading = false;
            });
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
      ..loadRequest(Uri.parse(url));
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
    if (!kIsWeb && Platform.isIOS) {
      localServer!.close();
    }
    super.dispose();
  }

  _loadHtmlFromAssets() async {
    final filePath = assetPath;
    _initWebView('http://localhost:$port/$filePath');
  }

  var loading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            children: [
              Visibility(
                visible: widget.editorOptions!.barPosition == BarPosition.TOP,
                child: _buildToolBar(),
              ),
              Visibility(
                visible:
                    widget.editorOptions!.barPosition == BarPosition.CUSTOM,
                child: _buildToolBar(),
              ),
              Expanded(
                child: Container(
                  margin: widget.margin,
                  decoration: widget.decoration ??
                      BoxDecoration(
                        color: Colors.white,
                      ),
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
              ),
              Visibility(
                visible:
                    widget.editorOptions!.barPosition == BarPosition.BOTTOM,
                child: _buildToolBar(),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Visibility(
            visible: loading,
            child: widget.customLoading ??
                Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                  ),
                ),
          ),
        ),
      ],
    );
  }

  _buildToolBar() {
    if (widget.editorOptions!.barPosition == BarPosition.CUSTOM) {
      return EditorToolBar(
        isCustom: true,
        iconColor: widget.iconColor,
        getImageUrl: widget.getImageUrl,
        getVideoUrl: widget.getVideoUrl,
        javascriptExecutor: javascriptExecutor,
        enableVideo: false,
        font: widget.font,
        italic: widget.italic,
        bold: widget.bold,
        insertLink: widget.insertLink,
        underLine: widget.underLine,
        alignCenter: widget.alignCenter,
        alignLeft: widget.alignLeft,
        alignRight: widget.alignRight,
        justify: widget.justify,
        redo: widget.redo,
        undo: widget.undo,
        image: widget.image,
        insertImage: widget.insertImage,
        fontSize: widget.fontSize,
        clearFormat: widget.clearFormat,
        strikeThrough: widget.strikeThrough,
        numList: widget.numList,
        bulletList: widget.bulletList,
        checkBox: widget.checkBox,
      );
    } else {
      return EditorToolBar(
        isCustom: false,
        iconColor: widget.iconColor,
        getImageUrl: widget.getImageUrl,
        getVideoUrl: widget.getVideoUrl,
        javascriptExecutor: javascriptExecutor,
        enableVideo: widget.editorOptions!.enableVideo,
        font: widget.font,
        italic: widget.italic,
        bold: widget.bold,
        insertLink: widget.insertLink,
        underLine: widget.underLine,
        alignCenter: widget.alignCenter,
        alignLeft: widget.alignLeft,
        alignRight: widget.alignRight,
        justify: widget.justify,
        redo: widget.redo,
        image: widget.image,
        undo: widget.undo,
        insertImage: widget.insertImage,
        fontSize: widget.fontSize,
        clearFormat: widget.clearFormat,
        strikeThrough: widget.strikeThrough,
        numList: widget.numList,
        bulletList: widget.bulletList,
        checkBox: widget.checkBox,
      );
    }
  }

  _setInitialValues() async {
    await webCon.runJavaScript('''var style = document.createElement('style');
              style.innerHTML = "img{ width: auto;height: auto;pointer-events: none; user-select: none;touch-action: none;overflow: hidden; border: none;border-radius: ${widget.imageRaduis}px;}"
              document.head.appendChild(style);
         ''');
    if (widget.javaScript != null) {
      await webCon.runJavaScript(widget.javaScript!);
    }
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
    } catch (e) {
      debugPrint("Error getting current HTML $e");
    }
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
    return html == '';
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
