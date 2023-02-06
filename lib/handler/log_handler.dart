import 'package:logger/logger.dart';

Logger logger = Logger(
    printer: PrettyPrinter(
  methodCount: 10,
  errorMethodCount: 10,
  colors: true,
  lineLength: 120,
  printEmojis: false,
  printTime: false,
));
