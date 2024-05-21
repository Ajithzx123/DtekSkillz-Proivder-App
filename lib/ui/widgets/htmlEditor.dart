import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class CustomHTMLEditor extends StatelessWidget {
  final HtmlEditorController controller;
  final bool shouldAutoExpand;
  final String hint;
  final String? initialHTML;
  const CustomHTMLEditor({
    super.key,
    required this.controller,
    required this.initialHTML,
    required this.hint,
    this.shouldAutoExpand = true,
  });

  @override
  Widget build(BuildContext context) {
    return HtmlEditor(
      controller: controller,
      htmlEditorOptions: HtmlEditorOptions(
        hint: hint,
        shouldEnsureVisible: true,
        initialText: initialHTML,
      ),
      callbacks: Callbacks(
        onInit: () {
          controller.setFullScreen();
        },
      ),
      htmlToolbarOptions: const HtmlToolbarOptions(
        toolbarPosition: ToolbarPosition.aboveEditor,
        toolbarType: ToolbarType.nativeExpandable,
        renderSeparatorWidget: false,
        defaultToolbarButtons: [
          StyleButtons(),
          FontSettingButtons(fontSizeUnit: true),
          FontButtons(clearAll: false),
          ColorButtons(),
          ListButtons(listStyles: false),
          ParagraphButtons(
            textDirection: true,
            lineHeight: true,
            caseConverter: false,
          ),
          InsertButtons(
            video: false,
            audio: false,
            table: true,
            hr: true,
            otherFile: false,
          ),
          OtherButtons(
            fullscreen: false,
            help: false,
            copy: false,
            paste: false,
          ),
        ],
      ),
    );
  }
}
