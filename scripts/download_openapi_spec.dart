import 'dart:io';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  // Configuration
  const String remoteUrl = 'https://api.fmecg.example.com/openapi.yaml';
  const String localSourcePath = 'openapi/api_spec_source.yaml';
  const String outputPath = 'openapi/api_spec.yaml';

  // Parse command line arguments
  String mode = 'remote'; // default to remote
  
  if (args.isNotEmpty) {
    mode = args[0].toLowerCase();
  }

  print('OpenAPI Spec Download Script');
  print('================================');
  print('Mode: $mode');
  print('');

  if (mode == 'local') {
    await useLocalFile(localSourcePath, outputPath);
  } else if (mode == 'remote') {
    await downloadRemoteFile(remoteUrl, outputPath);
  } else {
    printUsage();
    exit(1);
  }
}

Future<void> useLocalFile(String sourcePath, String outputPath) async {
  print('Using local OpenAPI spec file...');
  print('Source: $sourcePath');
  print('Output: $outputPath');
  print('');

  final sourceFile = File(sourcePath);
  
  if (!await sourceFile.exists()) {
    print('✗ Error: Local source file not found at: $sourcePath');
    print('');
    print('Please ensure the file exists at the specified location.');
    exit(1);
  }

  try {
    // Create openapi directory if it doesn't exist
    final directory = Directory('openapi');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('✓ Created openapi directory');
    }

    // Copy file to output location
    final content = await sourceFile.readAsString();
    final outputFile = File(outputPath);
    await outputFile.writeAsString(content);
    
    final fileSize = await outputFile.length();
    print('✓ Successfully copied local OpenAPI spec to: $outputPath');
    print('✓ File size: $fileSize bytes');
    exit(0);
  } catch (e) {
    print('✗ Error copying file: $e');
    exit(1);
  }
}

Future<void> downloadRemoteFile(String url, String outputPath) async {
  print('Downloading OpenAPI spec from remote server...');
  print('URL: $url');
  print('Output: $outputPath');
  print('');

  try {
    // Create openapi directory if it doesn't exist
    final directory = Directory('openapi');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('✓ Created openapi directory');
    }

    // Download the file
    print('Fetching...');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Save to file
      final file = File(outputPath);
      await file.writeAsString(response.body);
      print('✓ Successfully downloaded OpenAPI spec to: $outputPath');
      print('✓ File size: ${response.body.length} bytes');
      exit(0);
    } else {
      print('✗ Error: Failed to download file');
      print('  Status code: ${response.statusCode}');
      print('  Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      print('');
      print('Tip: Check the URL and your internet connection');
      exit(1);
    }
  } catch (e) {
    print('✗ Error: $e');
    print('');
    print('Tip: Check your internet connection or verify the remote URL');
    exit(1);
  }
}

void printUsage() {
  print('✗ Error: Invalid mode specified');
  print('');
  print('Usage:');
  print('  dart scripts/download_openapi_spec.dart [mode]');
  print('');
  print('Modes:');
  print('  remote  - Download OpenAPI spec from remote server (default)');
  print('  local   - Use local OpenAPI spec file');
  print('');
  print('Examples:');
  print('  dart scripts/download_openapi_spec.dart remote');
  print('  dart scripts/download_openapi_spec.dart local');
  print('  dart scripts/download_openapi_spec.dart');
}
