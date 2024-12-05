import 'package:flutter/material.dart';
import 'package:chatoid/constants.dart'; // Adjust the import as needed

class MessageInputArea extends StatefulWidget {
  final String username; // The friend's username
  final String? messageTextToReply; // The message text to reply
  final TextEditingController
      messageController; // Controller for the text field
  final bool iWillReply; // Pass the reply state here
  final VoidCallback onCloseReply; // Callback to close reply state

  const MessageInputArea({
    Key? key,
    required this.username,
    required this.onCloseReply, // Required callback for closing
    this.messageTextToReply,
    required this.iWillReply, // Updated to use the passed value
    required this.messageController,
  }) : super(key: key);

  @override
  _MessageInputAreaState createState() => _MessageInputAreaState();
}

class _MessageInputAreaState extends State<MessageInputArea> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Automatically focus the TextField to keep the keyboard open when the screen is loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.iWillReply) {
        _focusNode.requestFocus(); // Keep the keyboard open
      }
    });
  }

  // Function to control whether to keep the keyboard open based on true/false
  void toggleKeyboard(bool keepOpen) {
    if (keepOpen) {
      _focusNode
          .requestFocus(); // Keep the TextField focused and the keyboard open
    } else {
      _focusNode.unfocus(); // Close the keyboard
    }
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose of the focus node to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.iWillReply)
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(144, 3, 86, 168),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              height: 90,
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    height: 45,
                    child: VerticalDivider(
                      thickness: 5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                            height:
                                4), // Space between username and message text
                        Text(
                          widget.messageTextToReply ?? '',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 37, 35, 35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onCloseReply();
                    },
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: ChatAppColors.chatBubbleColorReceiver,
              borderRadius: widget.iWillReply
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    )
                  : BorderRadius.circular(30),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: TextField(
              controller: widget.messageController,
              focusNode: _focusNode, // Attach the focus node to the TextField
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Type a message',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}
