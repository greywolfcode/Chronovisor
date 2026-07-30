/*
  Chronovisor chat archive viewer tool.
  Copyright (C) 2026  greywolfcode

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published byl
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

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
              ChatMessage(
                text: "Lorem ipsum dolor sit amet.", 
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 186, 187, 188),
                  borderRadius: BorderRadius.circular(12.0)
                )
              )
            ],
          )
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget
{
  final String text;
  final BoxDecoration decoration; 

  const ChatMessage({super.key, required this.decoration, required this.text});

  @override
  Widget build(BuildContext context)
  {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ), 
      child: Padding( 
        padding: const EdgeInsetsDirectional.only(
          //it appears that the padding looks the same
          //when verticle padding is half horizontal
          start: 8.0, //left
          top: 4.0,
          end: 8.0, //right
          bottom: 4.0
        ),
        child: RichText(
          text: TextSpan(
            text: text,
            style: DefaultTextStyle.of(context).style
          )
        )
      )
    );
  }
}