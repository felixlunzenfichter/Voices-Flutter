import 'package:flutter/cupertino.dart';

class TimeStampText extends StatelessWidget {
  final DateTime timestamp;

  TimeStampText({@required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Text(
        timestamp != null ? getTimestampAsString(timestamp: timestamp) : "",
        style: TextStyle(
          fontSize: 10.0,
        ));
  }

  String getTimestampAsString({@required DateTime timestamp}) {
    DateTime now = DateTime.now();
    if (now.difference(timestamp) < Duration(days: 1) &&
        now.day == timestamp.day) {
      //its today
      return _makeInt2Digits(timestamp.hour) +
          ':' +
          _makeInt2Digits(timestamp.minute);
    } else if (now.difference(timestamp) < Duration(days: 2)) {
      return "Yesterday";
    } else if (now.difference(timestamp) < Duration(days: 7)) {
      return _getWeekdayString(weekdayInt: timestamp.weekday);
    } else {
      return _makeInt2Digits(timestamp.day) +
          ' ' +
          _getMonthString(month: timestamp.month);
    }
  }

  String _makeInt2Digits(int number) {
    if (number < 10) {
      return '0${number.toString()}';
    }
    return number.toString();
  }

  String _getWeekdayString({int weekdayInt}) {
    switch (weekdayInt) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return 'Error';
    }
  }

  String _getMonthString({int month}) {
    switch (month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Okt";
      case 11:
        return "Nov";
      case 12:
        return "Dez";
      default:
        return 'Error';
    }
  }
}
