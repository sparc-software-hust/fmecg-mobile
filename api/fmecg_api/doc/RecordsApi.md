# fmecg_api.api.RecordsApi

## Load the API package
```dart
import 'package:fmecg_api/api.dart';
```

All URIs are relative to *https://localhost:4000*

Method | HTTP request | Description
------------- | ------------- | -------------
[**fmecgWebRecordControllerCreate**](RecordsApi.md#fmecgwebrecordcontrollercreate) | **POST** /api/records | Upload a file and create a record
[**fmecgWebRecordControllerShow**](RecordsApi.md#fmecgwebrecordcontrollershow) | **GET** /api/records/{id}/file | Get file content as JSON


# **fmecgWebRecordControllerCreate**
> RecordResponse fmecgWebRecordControllerCreate(file, metadata)

Upload a file and create a record

### Example
```dart
import 'package:fmecg_api/api.dart';

final api = FmecgApi().getRecordsApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | File to upload
final JsonObject metadata = Object; // JsonObject | Optional metadata (JSON string)

try {
    final response = api.fmecgWebRecordControllerCreate(file, metadata);
    print(response);
} catch on DioException (e) {
    print('Exception when calling RecordsApi->fmecgWebRecordControllerCreate: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**| File to upload | 
 **metadata** | [**JsonObject**](JsonObject.md)| Optional metadata (JSON string) | [optional] 

### Return type

[**RecordResponse**](RecordResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **fmecgWebRecordControllerShow**
> RecordFileResponse fmecgWebRecordControllerShow(id)

Get file content as JSON

### Example
```dart
import 'package:fmecg_api/api.dart';

final api = FmecgApi().getRecordsApi();
final int id = 1; // int | Record ID

try {
    final response = api.fmecgWebRecordControllerShow(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling RecordsApi->fmecgWebRecordControllerShow: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| Record ID | 

### Return type

[**RecordFileResponse**](RecordFileResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

