import 'dart:math' as math;

class ECGDataController {
  static const double referenceVoltage = 4.5;
  static const int totalChannelsCount = 6;
  static const int bytesPerChannel = 3;
  static const int statusBytesCount = 3;
  static const int dataBytesCount = 18; // 6 channels * 3 bytes each
  static const int countByteSize = 1;
  static const int totalPacketSize = 22; // 3 + 18 + 1
  static const List<int> activeChannelNumbers = [1, 2, 3, 4, 5, 6];

  /// Processes a complete ECG data packet from Bluetooth and extracts channel values
  /// 
  /// The packet structure (22 bytes total):
  /// - Bytes 0-2: Status bytes (3 bytes)
  /// - Bytes 3-20: Channel data (18 bytes = 6 channels × 3 bytes each)
  /// - Byte 21: Count byte (1 byte)
  /// 
  /// Returns a list of decimal values for each of the 6 channels
  static List<double> processECGDataPacketFromBluetooth(List<int> bluetoothDataPacket) {
    final List<int> channelDataBytes = extractChannelDataBytes(bluetoothDataPacket);
    
    final List<double> channelDecimalValues = [];
    for (int channelIndex = 1; channelIndex <= totalChannelsCount; channelIndex++) {
      List<int> singleChannelBytes = extractSingleChannelBytes(channelDataBytes, channelIndex);
      double channelDecimalValue = convertThreeBytesToSignedDecimal(singleChannelBytes);
      channelDecimalValues.add(channelDecimalValue);
    }
    return channelDecimalValues;
  }

  /// Extracts the first 3 bytes which contain status information
  static List<int> extractStatusBytes(List<int> bluetoothDataPacket) {
    if (bluetoothDataPacket.length >= statusBytesCount) {
      return bluetoothDataPacket.sublist(0, statusBytesCount);
    } else {
      // Return error indicator for invalid data
      return List.generate(statusBytesCount, (_) => -1);
    }
  }

  /// Extracts the 18 bytes containing data for all 6 channels (3 bytes per channel)
  static List<int> extractChannelDataBytes(List<int> bluetoothDataPacket) {
    print('Bluetooth packet length: ${bluetoothDataPacket.length}');
    
    if (bluetoothDataPacket.length < statusBytesCount + dataBytesCount) {
      // If packet is too short, return what we can
      if (bluetoothDataPacket.length > statusBytesCount) {
        return bluetoothDataPacket.sublist(statusBytesCount, bluetoothDataPacket.length);
      }
      return List.generate(dataBytesCount, (_) => -1);
    }
    
    // For the correct 22-byte packet, extract bytes 3-20 (18 bytes)
    if (bluetoothDataPacket.length == totalPacketSize) {
      return bluetoothDataPacket.sublist(statusBytesCount, statusBytesCount + dataBytesCount);
    }
    
    // Handle legacy packet sizes for backward compatibility
    if (bluetoothDataPacket.length == 16) {
      return bluetoothDataPacket.sublist(3, 15);
    }
    if (bluetoothDataPacket.length == 24) {
      return bluetoothDataPacket.sublist(3, 21);
    }
    
    return List.generate(dataBytesCount, (_) => -1);
  }

  /// Extracts the last byte which contains the packet count information
  static int extractCountByte(List<int> bluetoothDataPacket) {
    if (bluetoothDataPacket.isNotEmpty) {
      return bluetoothDataPacket.last;
    } else {
      // Return error indicator for empty data
      return -1;
    }
  }

  /// Extracts 3 bytes for a specific channel from the channel data bytes
  /// 
  /// channelNumber: 1-based channel number (1, 2, 3, 4, 5, 6)
  /// Returns 3 bytes representing the raw data for that channel
  static List<int> extractSingleChannelBytes(List<int> allChannelDataBytes, int channelNumber) {
    final int channelOffset = channelNumber - 1;
    if (channelOffset < 0 || channelOffset >= totalChannelsCount) {
      return List.generate(bytesPerChannel, (_) => -1);
    }
    
    final int startByteIndex = channelOffset * bytesPerChannel;
    final int endByteIndex = startByteIndex + bytesPerChannel;
    
    if (endByteIndex <= allChannelDataBytes.length) {
      return allChannelDataBytes.sublist(startByteIndex, endByteIndex);
    } else {
      return List.generate(bytesPerChannel, (_) => -1);
    }
  }

  /// Converts 3 bytes to a signed 24-bit decimal value
  /// 
  /// The 3 bytes represent a 24-bit signed integer in big-endian format:
  /// - Byte 0: Most significant byte (MSB)
  /// - Byte 1: Middle byte  
  /// - Byte 2: Least significant byte (LSB)
  /// 
  /// Handles two's complement representation for negative values
  static double convertThreeBytesToSignedDecimal(List<int> threeChannelBytes) {
    if (threeChannelBytes.isEmpty || threeChannelBytes.length != bytesPerChannel) {
      return -1.0;
    }
    
    // Combine the 3 bytes into a 24-bit unsigned integer
    // MSB * 2^16 + middle byte * 2^8 + LSB
    int unsignedDecimalValue = threeChannelBytes[0] * math.pow(2, 16).toInt() + 
                               threeChannelBytes[1] * math.pow(2, 8).toInt() + 
                               threeChannelBytes[2];
    
    // Convert to signed value using two's complement
    // If the value is >= 2^23, it represents a negative number
    int maxPositiveValue = math.pow(2, 23).toInt() - 1;
    int signedDecimalValue;
    
    if (unsignedDecimalValue > maxPositiveValue) {
      // Convert from two's complement: subtract 2^24 to get the negative value
      signedDecimalValue = unsignedDecimalValue - math.pow(2, 24).toInt();
    } else {
      signedDecimalValue = unsignedDecimalValue;
    }
    
    return signedDecimalValue.toDouble();
  }

  /// Converts decimal channel values to voltage values for display on charts
  /// 
  /// Formula: voltage = (decimal_value * reference_voltage) / (2^23 - 1)
  static List<double> convertDecimalValuesToVoltageForDisplay(List<double> channelDecimalValues) {
    double maxDecimalValue = (math.pow(2, 23) - 1).toDouble();
    
    List<double> voltageDataPoints = channelDecimalValues
        .map((decimalValue) => (decimalValue * referenceVoltage) / maxDecimalValue)
        .toList();
        
    return voltageDataPoints;
  }

  /// Validates that the packet has the expected length
  static bool validatePacketLength(List<int> bluetoothDataPacket) {
    return bluetoothDataPacket.length == totalPacketSize;
  }
}
