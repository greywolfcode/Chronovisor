import 'package:flutter/foundation.dart';
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
    return Scaffold(
      body: ListenableBuilder(
        listenable: viewModel, 
        builder: ((context, child) {
          return ElevatedButton(
            onPressed: viewModel.openArchive,
            child: const Text('Load archive'),
          );
        }),
      ),
    );
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
  void load(List<String?> paths)
  {
    for (final path in paths)
    {
      if (path == null)
      {
        continue;
      }

      loadExport(path);
    }

  } 
}

class ViewModel extends ChangeNotifier
{
  final Model model;

  ViewModel(this.model);

  Future<void> openArchive() async
  {
    await model.openArchive();
  }
}