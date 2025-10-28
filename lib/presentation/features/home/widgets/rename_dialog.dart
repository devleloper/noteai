import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog for renaming a recording
class RenameDialog extends StatefulWidget {
  final String currentTitle;
  final VoidCallback? onCancel;
  final ValueChanged<String>? onSave;

  const RenameDialog({
    Key? key,
    required this.currentTitle,
    this.onCancel,
    this.onSave,
  }) : super(key: key);

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
    _focusNode = FocusNode();
    
    // Auto-select text when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSave() {
    final newTitle = _controller.text.trim();
    
    // Validate input
    if (newTitle.isEmpty) {
      setState(() {
        _errorText = 'Title cannot be empty';
      });
      return;
    }
    
    if (newTitle == widget.currentTitle) {
      // No change, just close dialog
      Navigator.of(context).pop();
      return;
    }
    
    // Clear any previous error
    setState(() {
      _errorText = null;
    });
    
    // Call the save callback and close dialog
    widget.onSave?.call(newTitle);
    Navigator.of(context).pop();
  }

  void _onCancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Recording'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Recording Title',
              hintText: 'Enter a new title',
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onSave(),
            inputFormatters: [
              LengthLimitingTextInputFormatter(100), // Limit title length
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _onCancel,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
