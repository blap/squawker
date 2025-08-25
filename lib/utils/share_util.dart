import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

// The following is a workaround because of an issue with the share_plus package which uses the faulty mime_type library.
// When the issue is resolved (the PR https://github.com/dart-lang/mime/pull/81 is merged),
// then it should be replaced by the original code:
// SharePlus.instance.share(ShareParams(files: [XFile.fromData(fileBytes, mimeType: 'image/jpeg')]));
Future<void> shareJpegData(Uint8List data) async {
  const uuid = Uuid();

  final String tempPath = (await getTemporaryDirectory()).path;
  final name = uuid.v4();
  final path = '$tempPath/$name.jpg';

  final file = File(path);
  await file.writeAsBytes(data);

  final xFile = XFile(path, mimeType: 'image/jpeg');

  SharePlus.instance.share(ShareParams(files: [xFile])).then((value) => file.delete());
}
