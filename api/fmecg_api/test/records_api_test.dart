import 'package:test/test.dart';
import 'package:fmecg_api/fmecg_api.dart';

/// tests for RecordsApi
void main() {
  final instance = FmecgApi().getRecordsApi();

  group(RecordsApi, () {
    // Upload a file and create a record
    //
    //Future<RecordResponse> fmecgWebRecordControllerCreate(MultipartFile file, { JsonObject metadata }) async
    test('test fmecgWebRecordControllerCreate', () async {
      // TODO
    });

    // Get file content as JSON
    //
    //Future<RecordFileResponse> fmecgWebRecordControllerShow(int id) async
    test('test fmecgWebRecordControllerShow', () async {
      // TODO
    });
  });
}
