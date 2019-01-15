typedef DateTime CurrentDateTimeResolver();

final defaultDateTimeResolver = () => DateTime.now();

class Clock {
  static CurrentDateTimeResolver dateTimeResolver = defaultDateTimeResolver;

  static DateTime now() => dateTimeResolver();
}
