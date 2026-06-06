import 'package:chronovisor/main.dart';
import 'package:flutter/material.dart';

class ChatTheme extends StatelessWidget
{
  const ChatTheme({required this.uploadArchive});

  final VoidCallback uploadArchive;

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: 
      [
        AppBar(
          title: Text('Chronovisor'),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: uploadArchive,
              tooltip: 'Upload Archive',
            ),
          ],
        ),

      ],
    );
  }
}