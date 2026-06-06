import 'package:flutter/material.dart';

import 'package:resizable_widget/resizable_widget.dart';

class ChatTheme extends StatelessWidget
{
  const ChatTheme({super.key, required this.uploadArchive});

  final VoidCallback uploadArchive;

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
          title: Text('Chronovisor'),
          actions: [
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: uploadArchive,
              tooltip: 'Upload Archive',
            ),
          ],
        ),
      body: ResizableWidget(
        children: [
          Column( //dms & spaces bar
            children: [
              const Text('dms & spaces'),
            ],
          ),
          Column( //feed bar
            children: [
              Text('feed'),
            ],
          ),
          Column( //selected chat
            children: [
              Text('chat'),
            ],
            )
        ],
      ),
    );
  }
}