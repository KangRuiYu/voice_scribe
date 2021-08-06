/// Provides a collection of functions for formatting common containers
/// in a pretty format.
/// Intended to be used with the alias 'formatter'.

import 'package:intl/intl.dart';

String formatDuration(Duration duration) {
  // Formats the given duration in the proper format Hours:Minutes:Seconds:Milliseconds
  String hours = duration.inHours.toString().padLeft(2, '0');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  String milliseconds =
      duration.inMilliseconds.remainder(1000).toString().padLeft(3, '0')[0];
  return (hours == '00' ? '' : '$hours:') + '$minutes:$seconds:$milliseconds';
}

String formatDate(DateTime date) {
  // Formats the given DateTime in the proper format
  return DateFormat.yMMMd().format(date);
}
