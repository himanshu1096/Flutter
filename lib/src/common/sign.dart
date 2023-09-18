import 'dart:ui';

class ZodiacSign {
  final String name;
  final String cardPath;
  final String logoPath;
  final Color signColor;
  final String signTimeSpan;

  ZodiacSign({
    required this.name,
    required this.cardPath,
    required this.logoPath,
    required this.signColor,
    required this.signTimeSpan,
  });
}

final ZodiacSign aquarius = ZodiacSign(
  name: "Aquarius",
  cardPath: "assets/images/aquarius.png",
  logoPath: "assets/strokes/aquarius.png",
  signColor: Color(0xFF4297C6),
  signTimeSpan: "January 20 to February 18",
);

final ZodiacSign aries = ZodiacSign(
  name: "Aries",
  cardPath: "assets/images/aries.png",
  logoPath: "assets/strokes/aries.png",
  signColor: Color(0xFFEFA91B),
  signTimeSpan: "March 21 to April 19",
);

final ZodiacSign cancer = ZodiacSign(
  name: "Cancer",
  cardPath: "assets/images/cancer.png",
  logoPath: "assets/strokes/cancer.png",
  signColor: Color(0xFFD83554),
  signTimeSpan: "June 21 to July 22",
);

final ZodiacSign capricorn = ZodiacSign(
  name: "Capricorn",
  cardPath: "assets/images/capricorn.png",
  logoPath: "assets/strokes/capricorn.png",
  signColor: Color(0xFF9276B7),
  signTimeSpan: "December 22 to January 19",
);

final ZodiacSign gemini = ZodiacSign(
  name: "Gemini",
  cardPath: "assets/images/gemini.png",
  logoPath: "assets/strokes/gemini.png",
  signColor: Color(0xFFE29A59),
  signTimeSpan: "May 21 to June 20",
);

final ZodiacSign leo = ZodiacSign(
  name: "Leo",
  cardPath: "assets/images/leo.png",
  logoPath: "assets/strokes/leo.png",
  signColor: Color(0xFFDB6412),
  signTimeSpan: "July 23 to August 23",
);

final ZodiacSign libra = ZodiacSign(
  name: "Libra",
  cardPath: "assets/images/libra.png",
  logoPath: "assets/strokes/libra.png",
  signColor: Color(0xFF26AEC4),
  signTimeSpan: "September 23 to October 22",
);

final ZodiacSign pisces = ZodiacSign(
  name: "Pisces",
  cardPath: "assets/images/pisces.png",
  logoPath: "assets/strokes/pisces.png",
  signColor: Color(0xFFDE4A46),
  signTimeSpan: "February 19 to March 20",
);

final ZodiacSign sagittarius = ZodiacSign(
  name: "Sagittarius",
  cardPath: "assets/images/sagittarius.png",
  logoPath: "assets/strokes/sagittarius.png",
  signColor: Color(0xFFB7294B),
  signTimeSpan: "November 22 to December 21",
);

final ZodiacSign scorpio = ZodiacSign(
  name: "Scorpio",
  cardPath: "assets/images/scorpio.png",
  logoPath: "assets/strokes/scorpio.png",
  signColor: Color(0xFFC13A2F),
  signTimeSpan: "October 23 to November 21",
);

final ZodiacSign taurus = ZodiacSign(
  name: "Taurus",
  cardPath: "assets/images/taurus.png",
  logoPath: "assets/strokes/taurus.png",
  signColor: Color(0xFFBF6F47),
  signTimeSpan: "April 20 to May 20",
);

final ZodiacSign virgo = ZodiacSign(
  name: "Virgo",
  cardPath: "assets/images/virgo.png",
  logoPath: "assets/strokes/virgo.png",
  signColor: Color(0xFF179677),
  signTimeSpan: "August 24 to September 22",
);

// Define the rest of the ZodiacSign instances in a similar manner...

final List<ZodiacSign> signs = [
  aquarius,
  aries,
  cancer,
  capricorn,
  gemini,
  leo,
  libra,
  pisces,
  sagittarius,
  scorpio,
  taurus,
  virgo,
  // Include the rest of the ZodiacSign instances here...
];
