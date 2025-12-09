import 'dart:typed_data';

// conditional imports:
import 'picker_stub.dart'
    if (dart.library.html) 'picker_web.dart'
    if (dart.library.io) 'picker_mobile.dart';

abstract class PickerService {
  Future<Uint8List?> pickImageBytes();
}

final pickerService = createPickerService();
