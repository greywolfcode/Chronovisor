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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'archive_handeler/archive_loader.dart';

import 'data_handeler/data_handeler.dart';
import 'data_handeler/drift_setup.dart';

import 'themes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      home: View(),
      theme: ThemeData(fontFamily: 'Google Sans'),
    );
  }
}

class View extends StatefulWidget
{
  const View({super.key});

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View>
{
  final ViewModel viewModel= ViewModel(Model());

  @override
  void initState()
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return ChatTheme(uploadArchive: viewModel.openArchive);
  }
}

class Model
{
  Future<void> openArchive() async
  {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);

    if (result == null)
    {
      return;
    }

    List<String?> paths = result.paths;

    await compute(load, paths);

  }
  
}

void load(List<String?> paths) async
{
  //Don't error when using Messages database multiple times
  driftSetup();

  for (final path in paths)
  {
    if (path == null)
    {
      continue;
    }
    var outputPath = await loadExport(path);
    await addArchive(outputPath, "user");
  }
} 

class ViewModel extends ChangeNotifier
{
  final Model model;

  ViewModel(this.model);

  void openArchive()
  {
    model.openArchive();
  }
}