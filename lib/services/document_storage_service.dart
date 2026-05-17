import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class DocumentStorageService {
  DocumentStorageService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickAndStoreImage({
    required ImageSource source,
    required String roomId,
    required String category,
  }) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 88);
    if (picked == null) return null;
    return importFileToStorage(picked.path, roomId: roomId, category: category);
  }

  Future<String> importFileToStorage(
    String sourcePath, {
    required String roomId,
    required String category,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Selected file does not exist.');
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final vaultDirectory = Directory(
      '${documentsDirectory.path}/document_vault',
    );
    if (!await vaultDirectory.exists()) {
      await vaultDirectory.create(recursive: true);
    }

    final sourceName = source.path.split(Platform.pathSeparator).last;
    final sourceExtension = sourceName.contains('.')
        ? sourceName.substring(sourceName.lastIndexOf('.'))
        : '';
    final safeCategory = category.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]+'),
      '_',
    );
    final targetName =
        '${roomId}_${safeCategory}_${DateTime.now().microsecondsSinceEpoch}$sourceExtension';
    final targetPath = '${vaultDirectory.path}/$targetName';
    final copied = await source.copy(targetPath);
    return copied.path;
  }

  Future<void> deleteIfManaged(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return;
    final documentsDirectory = await getApplicationDocumentsDirectory();
    if (!filePath.startsWith(documentsDirectory.path)) return;
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
