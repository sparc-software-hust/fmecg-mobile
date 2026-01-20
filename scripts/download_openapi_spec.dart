import 'dart:io';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  // Configuration
  const String remoteUrl = 'https://api.fmecg.example.com/openapi.yaml';
  const String localhostUrl = 'http://localhost:4000/api/openapi/index.yaml';
  const String outputPath = 'lib/openapi/api_spec.yaml';

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
    await downloadFromServer(localhostUrl, outputPath, 'localhost');
  } else if (mode == 'remote') {
    await downloadFromServer(remoteUrl, outputPath, 'remote');
  } else {
    printUsage();
    exit(1);
  }
}

Future<void> downloadFromServer(String url, String outputPath, String serverType) async {
  print('Downloading OpenAPI spec from $serverType server...');
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
      if (serverType == 'localhost') {
        print('Tip: Make sure your local server is running on port 4000');
      }
      exit(1);
    }
  } catch (e) {
    print('✗ Error: $e');
    print('');
    if (serverType == 'localhost') {
      print('Tip: Make sure your local server is running and accessible at $url');
    } else {
      print('Tip: Check your internet connection or verify the remote URL');
    }
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
  print('  remote - Download OpenAPI spec from remote server (default)');
  print('  local  - Download OpenAPI spec from localhost server');
  print('');
  print('Examples:');
  print('  dart scripts/download_openapi_spec.dart remote');
  print('  dart scripts/download_openapi_spec.dart local');
  print('  dart scripts/download_openapi_spec.dart');
  print('');
  print('Configuration:');
  print('  Remote URL: Edit remoteUrl in the script');
  print('  Local URL: Edit localhostUrl in the script (default: http://localhost:4000/api/openapi/index.yaml)');
}
