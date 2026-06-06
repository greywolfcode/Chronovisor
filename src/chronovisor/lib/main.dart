import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:archive_handeler/main.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final viewModel = ViewModel(Model());

    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: viewModel.openArchive,
            child: Text('open archive'),
          )
        ),
      ),
    );
  }
}

class Model
{
  Future<void> openArchive() async
  {
    FilePicker.pickFiles();
    FilePickerResult? result = await FilePicker.pickFiles(allowedExtensions: ['.zip']);

    if (result == null)
    {
      return;
    }

    List<String?> paths = result.paths;

    for (final path in paths)
    {
      if (path == null)
      {
        continue;
      }

      ChatArchive archives = loadExport(path);

      
    }
  } 
}