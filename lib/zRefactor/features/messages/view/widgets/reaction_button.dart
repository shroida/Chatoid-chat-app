// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

List<String> reactions = ['like', 'laugh', 'love', 'fire', 'evil', 'none'];

typedef OnButtonPressedCallback = void Function(String newReaction);

class ReactionButton extends StatefulWidget {
  const ReactionButton({
    super.key,
    this.reactFromDatabase,
    this.onReactionChanged,
  });

  final String? reactFromDatabase;
  final OnButtonPressedCallback? onReactionChanged;

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  String _reaction = 'none'; // Default reaction
  bool _reactionView = false;

  late OverlayEntry overlayEntry;

  void onCloseOverlay() {
    overlayEntry.remove();
  }

  void _showReactionPopUp(BuildContext context, Offset tapPosition) {
    final overlay = Overlay.of(context);

    final screenWidth = MediaQuery.of(context).size.width;
    double left = tapPosition.dx;
    if ((screenWidth - left) < 100) {
      left = left - 250;
    } else {
      left = left - 20;
    }

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: left - 60,
        top: tapPosition.dy - 60,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
              color: const Color.fromARGB(225, 235, 232, 232),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: const Color.fromARGB(255, 207, 204, 204),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: reactions.length,
              itemBuilder: (BuildContext context, int index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 350),
                  child: SlideAnimation(
                    verticalOffset: 20 + index * 10,
                    child: FadeInAnimation(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _reaction = reactions[index];
                            if (widget.onReactionChanged != null) {
                              widget.onReactionChanged!(_reaction);
                            }
                            _reactionView = false;
                          });
                          onCloseOverlay();
                        },
                        icon: ReactionIcon(reaction: reactions[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
  }

  @override
  void initState() {
    super.initState();
    // Initialize _reaction based on reactFromDatabase or default to 'none'
    _reaction = widget.reactFromDatabase ?? 'none';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showReactionPopUp(context, details.globalPosition);
        setState(() {
          _reactionView = true;
        });
      },
      onTap: () {
        if (_reactionView) {
          onCloseOverlay();
          _reactionView = false;
        } else {
          if (_reaction == 'none') {
            _reaction = 'like';
            if (widget.onReactionChanged != null) {
              widget.onReactionChanged!(_reaction);
            }
          } else {
            _reaction = 'none';
            if (widget.onReactionChanged != null) {
              widget.onReactionChanged!(_reaction);
            }
          }
        }
        setState(() {});
      },
      child:
          ReactionIcon(reaction: _reaction), // Pass the initialized _reaction
    );
  }
}

class ReactionIcon extends StatelessWidget {
  const ReactionIcon({super.key, required this.reaction});
  final String reaction;

  @override
  Widget build(BuildContext context) {
    switch (reaction) {
      case 'like':
        return const Text(
          '👍',
          style: TextStyle(fontSize: 24),
        );
      case 'love':
        return const Text(
          '❤️',
          style: TextStyle(fontSize: 24),
        );
      case 'laugh':
        return const Text(
          '😂',
          style: TextStyle(fontSize: 24),
        );
      case 'fire':
        return const Text(
          '🔥',
          style: TextStyle(fontSize: 24),
        );
      case 'evil':
        return const Text(
          '😈',
          style: TextStyle(fontSize: 24),
        );
      case 'none':
      default:
        return const Icon(
          Icons.emoji_emotions,
          color: Colors.grey,
        );
    }
  }
}
