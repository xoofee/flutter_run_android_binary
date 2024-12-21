import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Run HTTP Server',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Run HTTP Server'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: _runHttpServer,
            child: Text('Run HTTP Server'),
          ),
        ),
      ),
    );
  }

  // Function to extract and run the HTTP server executable
  Future<void> _runHttpServer() async {
    try {
      // Get the path to the local directory
      final directory = await getApplicationDocumentsDirectory();
      // final executablePath = '${directory.path}/http_server';
      final executablePath = '/data/data/com.example.flutter_application_1/http_server';

      // Load the ELF executable from assets
      final byteData = await rootBundle.load('assets/http_server');
      final buffer = byteData.buffer.asUint8List();

      // Write the ELF executable to local storage
      final file = File(executablePath);
      await file.writeAsBytes(buffer);

      // Make the executable file executable by using chmod command
      await _makeFileExecutable(file);

      // Run the executable using Process
      final result = await Process.start(executablePath, []);

      result.stdout.listen((data) {
        print('stdout: ${String.fromCharCodes(data)}');
      });

      result.stderr.listen((data) {
        print('stderr: ${String.fromCharCodes(data)}');
      });

      result.exitCode.then((exitCode) {
        print('Process exited with code: $exitCode');
      });
    } catch (e) {
      print('Error running HTTP server: $e');
    }
  }

  // Function to set the file as executable using chmod
  Future<void> _makeFileExecutable(File file) async {
    try {
      final result = await Process.run(
        'chmod',
        ['+x', file.path], // This adds execute permission
      );
      if (result.exitCode != 0) {
        print('Failed to set executable permission: ${result.stderr}');
      } else {
        print('Successfully set file as executable.');
      }
    } catch (e) {
      print('Error setting file executable: $e');
    }
  }
}
