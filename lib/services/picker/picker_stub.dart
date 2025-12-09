import 'dart:typed_data';
import 'picker_service.dart';

PickerService createPickerService() => _StubPicker();

class _StubPicker implements PickerService {
  @override
  Future<Uint8List?> pickImageBytes() async {
    throw UnsupportedError('No picker implementation for this platform.');
  }
}
