import 'dart:io';
import 'package:get_cli/common/utils/logger/LogUtils.dart';
import 'package:meta/meta.dart';
//import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import '../models/file_model.dart';

class Structure {
  static final Map<String, String> _paths = {
    'page': Directory(
                replaceAsExpected(path: Directory.current.path + '/lib/pages/'))
            .existsSync()
        ? replaceAsExpected(path: 'lib/pages')
        : replaceAsExpected(path: 'lib/app/modules'),
    'widget': replaceAsExpected(path: 'lib/widgets/'),
    'model': replaceAsExpected(path: 'lib/data/models/'),
    'init': replaceAsExpected(path: 'lib/'),
    'route': replaceAsExpected(path: 'lib/routes/'),
    'repository': replaceAsExpected(path: 'lib/data/repositories/'),
    'provider': replaceAsExpected(path: 'lib/data/providers/'),
    'controller': replaceAsExpected(path: 'lib/app/controllers/'),
    'view': replaceAsExpected(path: 'lib/app/views/'),
    //artekko files
    'screen': replaceAsExpected(path: 'lib/presentation'),
    'navigation': replaceAsExpected(
        path: 'lib/infrastructure/navigation/navigation.dart'),
    //generator files
    'generate_locales': replaceAsExpected(path: 'lib/generated'),
    'generate_model': replaceAsExpected(path: 'lib/generated/models/'),
  };

  static FileModel model(String name, String command, bool wrapperFolder,
      {String on, String folderName}) {
    if (on != null) {
      on = replaceAsExpected(path: on).replaceAll('\\\\', '\\');
      Directory current = Directory('./lib');
      final list = current.listSync(recursive: true, followLinks: false);
      final contains = list.firstWhere((element) {
        if (element is File) {
          return false;
        }

        return '${element.path}/'.contains('$on/');
      }, orElse: () {
        return list.firstWhere((element) {
          //Fix erro ao encontrar arquivo com nome
          if (element is File) {
            return false;
          }
          return element.path.contains(on);
        }, orElse: () {
          LogService.error('Folder $on not found');
          if (!Platform.isWindows) exit(0);
          return;
        });
      });
      print(contains);

      return FileModel(
        name: name,
        path: Structure.getPathWithName(
          contains.path,
          ReCase(name).snakeCase,
          createWithWrappedFolder: wrapperFolder,
          folderName: folderName,
        ),
        commandName: command,
      );
    }
    return FileModel(
      name: name,
      path: Structure.getPathWithName(
        _paths[command],
        ReCase(name).snakeCase,
        createWithWrappedFolder: wrapperFolder,
        folderName: folderName,
      ),
      commandName: command,
    );
  }

  static String replaceAsExpected({String path, String replaceChar}) {
    if (path.contains('\\')) {
      if (Platform.isLinux || Platform.isMacOS) {
        return path.replaceAll('\\', '/');
      } else {
        return path;
      }
    } else if (path.contains('/')) {
      if (Platform.isWindows) {
        return path.replaceAll('/', '\\\\');
      } else {
        return path;
      }
    } else {
      return path;
    }
  }

  static String getPathWithName(String firstPath, String secondPath,
      {bool createWithWrappedFolder = false, @required String folderName}) {
    String betweenPaths;
    if (Platform.isWindows) {
      betweenPaths = '\\\\';
    } else if (Platform.isMacOS || Platform.isLinux) {
      betweenPaths = '/';
    }
    if (betweenPaths.isNotEmpty) {
      if (createWithWrappedFolder) {
        return firstPath +
            betweenPaths +
            folderName +
            betweenPaths +
            secondPath;
      } else {
        return firstPath + betweenPaths + secondPath;
      }
    }
    return null;
  }

  static List<String> safeSplitPath(String path) {
    return path.replaceAll('\\', '/').split('/')
      ..removeWhere((element) => element == null || element.isEmpty);
  }
}
