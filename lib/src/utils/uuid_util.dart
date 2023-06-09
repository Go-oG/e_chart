

import 'package:uuid/uuid.dart';

const Uuid _uuid=Uuid();

String randomId(){
  return _uuid.v4().replaceAll('-', '');
}