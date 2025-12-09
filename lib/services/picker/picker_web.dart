import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html; // <-- lives only in web build
import 'picker_service.dart';

PickerService createPickerService() => _WebPicker();

class _WebPicker implements PickerService {
  @override
  Future<Uint8List?> pickImageBytes() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    final c = Completer<Uint8List?>();
    input.onChange.listen((_) async {
      final f = input.files?.first;
      if (f == null) return c.complete(null);
      final r = html.FileReader()..readAsArrayBuffer(f);
      await r.onLoad.first;
      c.complete(r.result as Uint8List);
    });
    input.click();
    return c.future;
  }
}
