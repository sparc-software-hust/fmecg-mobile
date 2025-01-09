import 'dart:math' as math;


class ECGDataController {
  static const double referenceVoltage = 4.5;
  static const int channelsLength = 6;
  static const List<int> channelsNumber = [1, 2, 3, 4];
  /// Explanation for handling data ECG

  /// bytes (1 row data) variable: 1 list int include 16 numbers corresponding to 16 bytes (uint8).
  /// - first 3 bytes: status bytes
  /// - 12 next bytes: 3 bytes correspond to 1 channel and the last channel is test channel
  /// - last bytes: counting bytes
  static List<double> handleDataRowFromBluetooth(List<int> bytes) {
    // final List<int> statusBytes = getStatusBytes(bytes);
    final List<int> channelsBytes = getChannelsBytes(bytes);
    // final int countByte = getCountByte(bytes);

    /// 1 row include calculated figure for each channel like sample: [figureChannel1, figureChannel2, figureChannel3, figureChannel4]
    final List<double> row = [];
    for (int i = 1; i <= channelsLength; i++) {
      List<int> channelBytes = getChannelsSplittedBytes(channelsBytes, i);
      double channelFigure = calculateByteToDecimal(channelBytes);
      row.add(channelFigure);
    }
    return row;
  }

  static List<int> getStatusBytes(List<int> bytes) {
    if (bytes.length >= 3) {
      final List<int> statusBytes = bytes.sublist(0,3);
      return statusBytes;
    } else {
      // error data
      return List.generate(3, (_) => -1);
    }
  }

  static List<int> getChannelsBytes(List<int> bytes) {
    if (bytes.length < 12) return bytes.sublist(3, bytes.length); 
    if (bytes.length == 16) return bytes.sublist(3, 15);
    if (bytes.length == 24) return bytes.sublist(3, 21); //do bytes thu 21, 22 khong dung
    return List.generate(12, (_) => -1);
  }

  static int getCountByte(List<int> bytes) {
    if (bytes.isNotEmpty) {
      final int statusBytes = bytes.last;
      return statusBytes;
    } else {
      // error data
      return -1;
    }
  }

  static List<int> getChannelsSplittedBytes(List<int> bytes, int order) {
    final int offset = order - 1;
    if (offset < 0) return List.generate(3, (_) => -1);
    final int start = offset * 3;
    return bytes.sublist(start, start + 3);
    // switch (order) {
    //   case 1: // first channel 
    //     List<int> firstChannel = bytes.sublist(0,3);
    //     return firstChannel;
    //   case 2: // second channel 
    //     List<int> secondChannel = bytes.sublist(3,6);
    //     return secondChannel;
    //   case 3: // third channel 
    //     List<int> thirdChannel = bytes.sublist(6,9);
    //     return thirdChannel;
    //   case 4: // fourth channel (test channel)
    //     List<int> testChannel = bytes.sublist(9,12);
    //     return testChannel;
    //   default:
    //     // error bytes
    //     return List.generate(3, (_) => -1);
    // }
  }

  static double calculateByteToDecimal(List<int> threeBytes) {
    num finalDecimal = 0;
    if (threeBytes.isNotEmpty && threeBytes.length == 3) {
      num decimalValue = threeBytes[0] * math.pow(2, 16) + threeBytes[1] * math.pow(2, 8) + threeBytes[2];
      if (decimalValue >= (math.pow(2, 23) - 1)) {
        finalDecimal = decimalValue - math.pow(2, 24);
      } else {
        finalDecimal = decimalValue;
      }
      return finalDecimal.toDouble();
    } else {
      return -1.0;
    }
  }

  // tính điện áp để vẽ ra biểu đồ
  static List calculateDataPointToShow(List row) {
    List dataPoints = row.map((decimalValue) => (decimalValue * referenceVoltage) / (math.pow(2, 23) - 1).toDouble()).toList();
    return dataPoints;
  }

  // static List handlePacketData(List<int> bytes) {
  //   final int numberSample = bytes[9] / 4 ~/ 3;
  //   final int countPacket = bytes[10];
  //   final rowLength = bytes.length;
  //   final dataECG = bytes.sublist(11, rowLength);
  //
  //   final Map<int, List<int>> dataSeperated = separateDataIntoEachSample(dataECG, numberSample);
  //   List dataToSave = [];
  //
  //   dataSeperated.forEach((key, sample) {
  //     List rowToSave = [];
  //     if (key == 1) {
  //       rowToSave.add(countPacket);
  //     }
  //     final rowData = processSampleToSave(sample);
  //     rowToSave = [key, ...rowData, ...rowToSave];
  //     dataToSave.add(rowToSave);
  //   });
  //   return dataToSave;
  // }

  // static List<double> processSampleToSave(List<int> bytes) {
  //   /// 1 row include calculated figure for each channel like sample:
  //   /// [figureChannel1, figureChannel2, figureChannel3, figureChannel4]
  //   final List<double> row = [];
  //
  //   for (var channelNumber in channelsNumber) {
  //     List<int> channelBytes = getChannelsSplittedBytes(bytes, channelNumber);
  //     double channelFigure = calculateByteToDecimal(channelBytes);
  //     row.add(channelFigure);
  //   }
  //
  //   return row;
  // }

  // static separateDataIntoEachSample(List<int> data, int numberSample) {
  //   Map<int, List<int>> dataSeperated = {};
  //   for (int i = 1; i <= numberSample; i++) {
  //     List<int> row = data.sublist((i-1) * 12, (i-1) * 12 + 12);
  //     dataSeperated.addAll({
  //       i: row
  //     });
  //   }
  //   return dataSeperated;
  // }

  static verifyPacketLength(List<int> packet) {

  }
}