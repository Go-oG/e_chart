import 'dart:io';

import 'package:flutter/foundation.dart';

bool isWeb = kIsWeb;

bool isPhone = !kIsWeb && (Platform.isIOS || Platform.isAndroid);

bool isDesktop = kIsWeb || (Platform.isMacOS || Platform.isWindows || Platform.isFuchsia || Platform.isLinux);
