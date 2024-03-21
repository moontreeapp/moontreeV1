import 'package:moontree/domain/utils/flags.dart';

class CountryPhoneNumber {
  final String languageAbriviation;
  final String countryAbriviation;
  final String? countryName;
  final String countryCode;
  final RegExp countryRegex;
  final RegExp fullRegex;
  const CountryPhoneNumber({
    required this.languageAbriviation,
    required this.countryAbriviation,
    this.countryName,
    required this.countryCode,
    required this.countryRegex,
    required this.fullRegex,
  });

  String get name =>
      countryName ??
      countryIconsCodes[countryAbriviation] ??
      countryAbriviation;
}

Map<String, CountryPhoneNumber> _phonesFormats = {
  'am-AM': CountryPhoneNumber(
      languageAbriviation: 'am',
      countryAbriviation: 'am',
      countryCode: '+374',
      countryRegex: RegExp(r'^(\+374)'),
      fullRegex: RegExp(r'^(\+?374|0)((10|[9|7][0-9])\d{6}$|[2-4]\d{7}$)')),
  'ar-AE': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'ae',
      countryCode: '+971',
      countryRegex: RegExp(r'^(\+971)'),
      fullRegex: RegExp(r'^((\+?971)|0)?5[024568]\d{7}$')),
  'ar-BH': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'bh',
      countryCode: '+973',
      countryRegex: RegExp(r'^(\+973)'),
      fullRegex: RegExp(r'^(\+?973)?(3|6)\d{7}$')),
  'ar-DZ': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'dz',
      countryCode: '+213',
      countryRegex: RegExp(r'^(\+213)'),
      fullRegex: RegExp(r'^(\+?213|0)(5|6|7)\d{8}$')),
  'ar-EG': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'eg',
      countryCode: '+20',
      countryRegex: RegExp(r'^(\+20)'),
      fullRegex: RegExp(r'^((\+?20)|0)?1[0125]\d{8}$')),
  'ar-EH': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'eh',
      countryCode: '+212',
      countryRegex: RegExp(r'^(\+212)'),
      fullRegex: RegExp(r'^(\+?212|0)[\s\-]?(5288|5289)[\s\-]?\d{5}$')),
  'ar-IQ': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'iq',
      countryCode: '+964',
      countryRegex: RegExp(r'^(\+964)'),
      fullRegex: RegExp(r'^(\+?964|0)?7[0-9]\d{8}$')),
  'ar-JO': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'jo',
      countryCode: '+962',
      countryRegex: RegExp(r'^(\+962)'),
      fullRegex: RegExp(r'^(\+?962|0)?7[789]\d{7}$')),
  'ar-KW': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'kw',
      countryCode: '+965',
      countryRegex: RegExp(r'^(\+965)'),
      fullRegex: RegExp(r'^(\+?965)([569]\d{7}|41\d{6})$')),
  'ar-LB': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'lb',
      countryCode: '+961',
      countryRegex: RegExp(r'^(\+961)'),
      fullRegex: RegExp(r'^(\+?961)?((3|81)\d{6}|7\d{7})$')),
  'ar-LY': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'ly',
      countryCode: '+218',
      countryRegex: RegExp(r'^(\+218)'),
      fullRegex: RegExp(r'^((\+?218)|0)?(9[1-6]\d{7}|[1-8]\d{7,9})$')),
  'ar-MA': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'ma',
      countryCode: '+212',
      countryRegex: RegExp(r'^(\+212)'),
      fullRegex: RegExp(r'^(?:(?:\+|00)212|0)[5-7]\d{8}$')),
  'ar-OM': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'om',
      countryCode: '+968',
      countryRegex: RegExp(r'^(\+968)'),
      fullRegex: RegExp(r'^((\+|00)968)?(9[1-9])\d{6}$')),
  'ar-PS': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'ps',
      countryCode: '+970',
      countryRegex: RegExp(r'^(\+970)'),
      fullRegex: RegExp(r'^(\+?970|0)5[6|9](\d{7})$')),
  'ar-SA': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'sa',
      countryCode: '+966',
      countryRegex: RegExp(r'^(\+966)'),
      fullRegex: RegExp(r'^(!?(\+?966)|0)?5\d{8}$')),
  'ar-SY': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'sy',
      countryCode: '+963',
      countryRegex: RegExp(r'^(\+963)'),
      fullRegex: RegExp(r'^(!?(\+?963)|0)?9\d{8}$')),
  'ar-TN': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'tn',
      countryCode: '+216',
      countryRegex: RegExp(r'^(\+216)'),
      fullRegex: RegExp(r'^(\+?216)?[2459]\d{7}$')),
  'ar-YE': CountryPhoneNumber(
      languageAbriviation: 'ar',
      countryAbriviation: 'ye',
      countryCode: '+967',
      countryRegex: RegExp(r'^(\+967)'),
      fullRegex:
          RegExp(r'^(((\+|00)9677|0?7)[0137]\d{7}|((\+|00)967|0)[1-7]\d{6})$')),
  'az-AZ': CountryPhoneNumber(
      languageAbriviation: 'az',
      countryAbriviation: 'az',
      countryCode: '+994',
      countryRegex: RegExp(r'^(\+994)'),
      fullRegex: RegExp(r'^(\+994|0)(10|5[015]|7[07]|99)\d{7}$')),
  'be-BY': CountryPhoneNumber(
      languageAbriviation: 'be',
      countryAbriviation: 'by',
      countryCode: '+375',
      countryRegex: RegExp(r'^(\+375)'),
      fullRegex: RegExp(r'^(\+?375)?(24|25|29|33|44)\d{7}$')),
  'bg-BG': CountryPhoneNumber(
      languageAbriviation: 'bg',
      countryAbriviation: 'bg',
      countryCode: '+359',
      countryRegex: RegExp(r'^(\+359)'),
      fullRegex: RegExp(r'^(\+?359|0)?8[789]\d{7}$')),
  'bn-BD': CountryPhoneNumber(
      languageAbriviation: 'bn',
      countryAbriviation: 'bd',
      countryCode: '+880',
      countryRegex: RegExp(r'^(\+880)'),
      fullRegex: RegExp(r'^(\+?880|0)1[13456789][0-9]{8}$')),
  'bs-BA': CountryPhoneNumber(
      languageAbriviation: 'bs',
      countryAbriviation: 'ba',
      countryCode: '+387',
      countryRegex: RegExp(r'^(\+387)'),
      fullRegex:
          RegExp(r'^((((\+|00)3876)|06))((([0-3]|[5-6])\d{6})|(4\d{7}))$')),
  'ca-AD': CountryPhoneNumber(
      languageAbriviation: 'ca',
      countryAbriviation: 'ad',
      countryCode: '+376',
      countryRegex: RegExp(r'^(\+376)'),
      fullRegex: RegExp(r'^(\+376)?[346]\d{5}$')),
  'cs-CZ': CountryPhoneNumber(
      languageAbriviation: 'cs',
      countryAbriviation: 'cz',
      countryCode: '+420',
      countryRegex: RegExp(r'^(\+420)'),
      fullRegex: RegExp(r'^(\+?420)? ?[1-9][0-9]{2} ?[0-9]{3} ?[0-9]{3}$')),
  'da-DK': CountryPhoneNumber(
      languageAbriviation: 'da',
      countryAbriviation: 'dk',
      countryCode: '+45',
      countryRegex: RegExp(r'^(\+45)'),
      fullRegex: RegExp(r'^(\+?45)?\s?\d{2}\s?\d{2}\s?\d{2}\s?\d{2}$')),
  'de-AT': CountryPhoneNumber(
      languageAbriviation: 'de',
      countryAbriviation: 'at',
      countryCode: '+43',
      countryRegex: RegExp(r'^(\+43)'),
      fullRegex: RegExp(r'^(\+43|0)\d{1,4}\d{3,12}$')),
  'de-CH': CountryPhoneNumber(
      languageAbriviation: 'de',
      countryAbriviation: 'ch',
      countryCode: '+41',
      countryRegex: RegExp(r'^(\+41)'),
      fullRegex: RegExp(r'^(\+41|0)([1-9])\d{1,9}$')),
  'de-DE': CountryPhoneNumber(
      languageAbriviation: 'de',
      countryAbriviation: 'de',
      countryCode: '+49',
      countryRegex: RegExp(r'^(\+49)'),
      fullRegex: RegExp(
          r'^((\+49|0)1)(5[0-25-9]\d|6([23]|0\d?)|7([0-57-9]|6\d))\d{7,9}$')),
  'de-LU': CountryPhoneNumber(
      languageAbriviation: 'de',
      countryAbriviation: 'lu',
      countryCode: '+352',
      countryRegex: RegExp(r'^(\+352)'),
      fullRegex: RegExp(r'^(\+352)?((6\d1)\d{6})$')),
  'dv-MV': CountryPhoneNumber(
      languageAbriviation: 'dv',
      countryAbriviation: 'mv',
      countryCode: '+960',
      countryRegex: RegExp(r'^(\+960)'),
      fullRegex: RegExp(r'^(\+?960)?(7[2-9]|9[1-9])\d{5}$')),
  'dz-BT': CountryPhoneNumber(
      languageAbriviation: 'dz',
      countryAbriviation: 'bt',
      countryCode: '+975',
      countryRegex: RegExp(r'^(\+975)'),
      fullRegex: RegExp(r'^(\+?975|0)?(17|16|77|02)\d{6}$')),
  'el-CY': CountryPhoneNumber(
      languageAbriviation: 'el',
      countryAbriviation: 'cy',
      countryCode: '+357',
      countryRegex: RegExp(r'^(\+357)'),
      fullRegex: RegExp(r'^(\+?357?)?(9(9|6)\d{6})$')),
  'el-GR': CountryPhoneNumber(
      languageAbriviation: 'el',
      countryAbriviation: 'gr',
      countryCode: '+30',
      countryRegex: RegExp(r'^(\+30)'),
      fullRegex: RegExp(r'^(\+?30|0)?6(8[5-9]|9(?![26])[0-9])\d{7}$')),
  'en-AG': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ag',
      countryCode: '+1268',
      countryRegex: RegExp(r'^(\+1268)'),
      fullRegex: RegExp(
          r'^(?:\+1|1)268(?:464|7(?:1[3-9]|[28]\d|3[0246]|64|7[0-689]))\d{4}$')),
  'en-AI': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ai',
      countryCode: '+1264',
      countryRegex: RegExp(r'^(\+1264)'),
      fullRegex: RegExp(
          r'^(\+?1|0)264(?:2(35|92)|4(?:6[1-2]|76|97)|5(?:3[6-9]|8[1-4])|7(?:2(4|9)|72))\d{4}$')),
  'en-AU': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'au',
      countryCode: '+61',
      countryRegex: RegExp(r'^(\+61)'),
      fullRegex: RegExp(r'^(\+?61|0)4\d{8}$')),
  'en-BM': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'bm',
      countryCode: '+1441',
      countryRegex: RegExp(r'^(\+1441)'),
      fullRegex:
          RegExp(r'^(\+?1)?441(((3|7)\d{6}$)|(5[0-3][0-9]\d{4}$)|(59\d{5}$))')),
  'en-BS': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'bs',
      countryCode: '+1242',
      countryRegex: RegExp(r'^(\+1242)'),
      fullRegex: RegExp(r'^(\+?1[-\s]?|0)?\(?242\)?[-\s]?\d{3}[-\s]?\d{4}$')),
  'en-BW': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'bw',
      countryCode: '+267',
      countryRegex: RegExp(r'^(\+267)'),
      fullRegex: RegExp(r'^(\+?267)?(7[1-8]{1})\d{6}$')),
  'en-GB': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'gb',
      countryCode: '+44',
      countryRegex: RegExp(r'^(\+44)'),
      fullRegex: RegExp(r'^(\+?44|0)7\d{9}$')),
  'en-GG': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'gg',
      countryCode: '+44',
      countryRegex: RegExp(r'^(\+44)'),
      fullRegex: RegExp(r'^(\+?44|0)1481\d{6}$')),
  'en-GH': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'gh',
      countryCode: '+233',
      countryRegex: RegExp(r'^(\+233)'),
      fullRegex:
          RegExp(r'^(\+233|0)(20|50|24|54|27|57|26|56|23|28|55|59)\d{7}$')),
  'en-GY': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'gy',
      countryCode: '+592',
      countryRegex: RegExp(r'^(\+592)'),
      fullRegex: RegExp(r'^(\+592|0)6\d{6}$')),
  'en-HK': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'hk',
      countryCode: '+852',
      countryRegex: RegExp(r'^(\+852)'),
      fullRegex: RegExp(r'^(\+?852[-\s]?)?[456789]\d{3}[-\s]?\d{4}$')),
  'en-IE': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ie',
      countryCode: '+353',
      countryRegex: RegExp(r'^(\+353)'),
      fullRegex: RegExp(r'^(\+?353|0)8[356789]\d{7}$')),
  'en-IN': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'in',
      countryCode: '+91',
      countryRegex: RegExp(r'^(\+91)'),
      fullRegex: RegExp(r'^(\+?91|0)?[6789]\d{9}$')),
  'en-JM': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'jm',
      countryCode: '+1876',
      countryRegex: RegExp(r'^(\+1876)'),
      fullRegex: RegExp(r'^(\+?876)?\d{7}$')),
  'en-KE': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ke',
      countryCode: '+254',
      countryRegex: RegExp(r'^(\+254)'),
      fullRegex: RegExp(r'^(\+?254|0)(7|1)\d{8}$')),
  'en-KI': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ki',
      countryCode: '+686',
      countryRegex: RegExp(r'^(\+686)'),
      fullRegex: RegExp(r'^((\+686|686)?)?( )?((6|7)(2|3|8)[0-9]{6})$')),
  'en-KN': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'kn',
      countryCode: '+1869',
      countryRegex: RegExp(r'^(\+1869)'),
      fullRegex:
          RegExp(r'^(?:\+1|1)869(?:46\d|48[89]|55[6-8]|66\d|76[02-7])\d{4}$')),
  'en-LS': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ls',
      countryCode: '+266',
      countryRegex: RegExp(r'^(\+266)'),
      fullRegex: RegExp(r'^(\+?266)(22|28|57|58|59|27|52)\d{6}$')),
  'en-MO': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'mo',
      countryCode: '+853',
      countryRegex: RegExp(r'^(\+853)'),
      fullRegex: RegExp(r'^(\+?853[-\s]?)?[6]\d{3}[-\s]?\d{4}$')),
  'en-MT': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'mt',
      countryCode: '+356',
      countryRegex: RegExp(r'^(\+356)'),
      fullRegex: RegExp(r'^(\+?356|0)?(99|79|77|21|27|22|25)[0-9]{6}$')),
  'en-MU': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'mu',
      countryCode: '+230',
      countryRegex: RegExp(r'^(\+230)'),
      fullRegex: RegExp(r'^(\+?230|0)?\d{8}$')),
  'en-NA': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'na',
      countryCode: '+264',
      countryRegex: RegExp(r'^(\+264)'),
      fullRegex: RegExp(r'^(\+?264|0)(6|8)\d{7}$')),
  'en-NG': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ng',
      countryCode: '+234',
      countryRegex: RegExp(r'^(\+234)'),
      fullRegex: RegExp(r'^(\+?234|0)?[789]\d{9}$')),
  'en-NZ': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'nz',
      countryCode: '+64',
      countryRegex: RegExp(r'^(\+64)'),
      fullRegex: RegExp(r'^(\+?64|0)[28]\d{7,9}$')),
  'en-PG': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'pg',
      countryCode: '+675',
      countryRegex: RegExp(r'^(\+675)'),
      fullRegex: RegExp(r'^(\+?675|0)?(7\d|8[18])\d{6}$')),
  'en-PH': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ph',
      countryCode: '+63',
      countryRegex: RegExp(r'^(\+63)'),
      fullRegex: RegExp(r'^(09|\+639)\d{9}$')),
  'en-PK': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'pk',
      countryCode: '+92',
      countryRegex: RegExp(r'^(\+92)'),
      fullRegex: RegExp(r'^((00|\+)?92|0)3[0-6]\d{8}$')),
  'en-RW': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'rw',
      countryCode: '+250',
      countryRegex: RegExp(r'^(\+250)'),
      fullRegex: RegExp(r'^(\+?250|0)?[7]\d{8}$')),
  'en-SG': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'sg',
      countryCode: '+65',
      countryRegex: RegExp(r'^(\+65)'),
      fullRegex: RegExp(r'^(\+65)?[3689]\d{7}$')),
  'en-SL': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'sl',
      countryCode: '+232',
      countryRegex: RegExp(r'^(\+232)'),
      fullRegex: RegExp(r'^(\+?232|0)\d{8}$')),
  'en-SS': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ss',
      countryCode: '+211',
      countryRegex: RegExp(r'^(\+211)'),
      fullRegex: RegExp(r'^(\+?211|0)(9[1257])\d{7}$')),
  'en-TZ': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'tz',
      countryCode: '+255',
      countryRegex: RegExp(r'^(\+255)'),
      fullRegex: RegExp(r'^(\+?255|0)?[67]\d{8}$')),
  'en-UG': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'ug',
      countryCode: '+256',
      countryRegex: RegExp(r'^(\+256)'),
      fullRegex: RegExp(r'^(\+?256|0)?[7]\d{8}$')),
  'en-US': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'us',
      countryCode: '+1',
      countryRegex: RegExp(r'^(\+1)'),
      fullRegex: RegExp(
          r'^((\+1|1)?( |-)?)?(\([2-9][0-9]{2}\)|[2-9][0-9]{2})( |-)?([2-9][0-9]{2}( |-)?[0-9]{4})$')),
  'en-ZA': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'za',
      countryCode: '+27',
      countryRegex: RegExp(r'^(\+27)'),
      fullRegex: RegExp(r'^(\+?27|0)\d{9}$')),
  'en-ZM': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'zm',
      countryCode: '+260',
      countryRegex: RegExp(r'^(\+260)'),
      fullRegex: RegExp(r'^(\+?26)?09[567]\d{7}$')),
  'en-ZW': CountryPhoneNumber(
      languageAbriviation: 'en',
      countryAbriviation: 'zw',
      countryCode: '+263',
      countryRegex: RegExp(r'^(\+263)'),
      fullRegex: RegExp(r'^(\+263)[0-9]{9}$')),
  'es-AR': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'ar',
      countryCode: '+54',
      countryRegex: RegExp(r'^(\+54)'),
      fullRegex: RegExp(r'^\+?549(11|[2368]\d)\d{8}$')),
  'es-BO': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'bo',
      countryCode: '+591',
      countryRegex: RegExp(r'^(\+591)'),
      fullRegex: RegExp(r'^(\+?591)?(6|7)\d{7}$')),
  'es-CL': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'cl',
      countryCode: '+56',
      countryRegex: RegExp(r'^(\+56)'),
      fullRegex: RegExp(r'^(\+?56|0)[2-9]\d{1}\d{7}$')),
  'es-CO': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'co',
      countryCode: '+57',
      countryRegex: RegExp(r'^(\+57)'),
      fullRegex: RegExp(r'^(\+?57)?3(0(0|1|2|4|5)|1\d|2[0-4]|5(0|1))\d{7}$')),
  'es-CR': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'cr',
      countryCode: '+506',
      countryRegex: RegExp(r'^(\+506)'),
      fullRegex: RegExp(r'^(\+506)?[2-8]\d{7}$')),
  'es-CU': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'cu',
      countryCode: '+53',
      countryRegex: RegExp(r'^(\+53)'),
      fullRegex: RegExp(r'^(\+53|0053)?5\d{7}$')),
  'es-DO': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'do',
      countryCode: '+1809, +1829, +1849',
      countryRegex: RegExp(r'^(?:\+1\s?(?:\(809\)|\(829\)|\(849\)))'),
      fullRegex: RegExp(r'^(\+?1)?8[024]9\d{7}$')),
  'es-EC': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'ec',
      countryCode: '+593',
      countryRegex: RegExp(r'^(\+593)'),
      fullRegex: RegExp(r'^(\+?593|0)([2-7]|9[2-9])\d{7}$')),
  'es-ES': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'es',
      countryCode: '+34',
      countryRegex: RegExp(r'^(\+34)'),
      fullRegex: RegExp(r'^(\+?34)?[6|7]\d{8}$')),
  'es-HN': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'hn',
      countryCode: '+504',
      countryRegex: RegExp(r'^(\+504)'),
      fullRegex: RegExp(r'^(\+?504)?[9|8|3|2]\d{7}$')),
  'es-MX': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'mx',
      countryCode: '+52',
      countryRegex: RegExp(r'^(\+52)'),
      fullRegex: RegExp(r'^(\+?52)?(1|01)?\d{10,11}$')),
  'es-NI': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'ni',
      countryCode: '+505',
      countryRegex: RegExp(r'^(\+505)'),
      fullRegex: RegExp(r'^(\+?505)\d{7,8}$')),
  'es-PA': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'pa',
      countryCode: '+507',
      countryRegex: RegExp(r'^(\+507)'),
      fullRegex: RegExp(r'^(\+?507)\d{7,8}$')),
  'es-PE': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'pe',
      countryCode: '+51',
      countryRegex: RegExp(r'^(\+51)'),
      fullRegex: RegExp(r'^(\+?51)?9\d{8}$')),
  'es-PY': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'py',
      countryCode: '+595',
      countryRegex: RegExp(r'^(\+595)'),
      fullRegex: RegExp(r'^(\+?595|0)9[9876]\d{7}$')),
  'es-SV': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'sv',
      countryCode: '+503',
      countryRegex: RegExp(r'^(\+503)'),
      fullRegex: RegExp(r'^(\+?503)?[67]\d{7}$')),
  'es-UY': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 'uy',
      countryCode: '+598',
      countryRegex: RegExp(r'^(\+598)'),
      fullRegex: RegExp(r'^(\+598|0)9[1-9][\d]{6}$')),
  'es-VE': CountryPhoneNumber(
      languageAbriviation: 'es',
      countryAbriviation: 've',
      countryCode: '+58',
      countryRegex: RegExp(r'^(\+58)'),
      fullRegex: RegExp(r'^(\+?58)?(2|4)\d{9}$')),
  'et-EE': CountryPhoneNumber(
      languageAbriviation: 'et',
      countryAbriviation: 'ee',
      countryCode: '+372',
      countryRegex: RegExp(r'^(\+372)'),
      fullRegex: RegExp(r'^(\+?372)?\s?(5|8[1-4])\s?([0-9]\s?){6,7}$')),
  'fa-AF': CountryPhoneNumber(
      languageAbriviation: 'fa',
      countryAbriviation: 'af',
      countryCode: '+93',
      countryRegex: RegExp(r'^(\+93)'),
      fullRegex: RegExp(r'^(\+93|0)?(2{1}[0-8]{1}|[3-5]{1}[0-4]{1})(\d{7})$')),
  'fa-IR': CountryPhoneNumber(
      languageAbriviation: 'fa',
      countryAbriviation: 'ir',
      countryCode: '+98',
      countryRegex: RegExp(r'^(\+98)'),
      fullRegex:
          RegExp(r'^(\+?98[\-\s]?|0)9[0-39]\d[\-\s]?\d{3}[\-\s]?\d{4}$')),
  'fi-FI': CountryPhoneNumber(
      languageAbriviation: 'fi',
      countryAbriviation: 'fi',
      countryCode: '+358',
      countryRegex: RegExp(r'^(\+358)'),
      fullRegex: RegExp(r'^(\+?358|0)\s?(4[0-6]|50)\s?(\d\s?){4,8}$')),
  'fj-FJ': CountryPhoneNumber(
      languageAbriviation: 'fj',
      countryAbriviation: 'fj',
      countryCode: '+679',
      countryRegex: RegExp(r'^(\+679)'),
      fullRegex: RegExp(r'^(\+?679)?\s?\d{3}\s?\d{4}$')),
  'fo-FO': CountryPhoneNumber(
      languageAbriviation: 'fo',
      countryAbriviation: 'fo',
      countryCode: '+298',
      countryRegex: RegExp(r'^(\+298)'),
      fullRegex: RegExp(r'^(\+?298)?\s?\d{2}\s?\d{2}\s?\d{2}$')),
  'fr-BF': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'bf',
      countryCode: '+226',
      countryRegex: RegExp(r'^(\+226)'),
      fullRegex: RegExp(r'^(\+226|0)[67]\d{7}$')),
  'fr-BJ': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'bj',
      countryCode: '+229',
      countryRegex: RegExp(r'^(\+229)'),
      fullRegex: RegExp(r'^(\+229)\d{8}$')),
  'fr-CD': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'cd',
      countryCode: '+243',
      countryRegex: RegExp(r'^(\+243)'),
      fullRegex: RegExp(r'^(\+?243|0)?(8|9)\d{8}$')),
  'fr-CF': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'cf',
      countryCode: '+236',
      countryRegex: RegExp(r'^(\+236)'),
      fullRegex: RegExp(r'^(\+?236| ?)(70|75|77|72|21|22)\d{6}$')),
  'fr-CM': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'cm',
      countryCode: '+237',
      countryRegex: RegExp(r'^(\+237)'),
      fullRegex: RegExp(r'^(\+?237)6[0-9]{8}$')),
  'fr-FR': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'fr',
      countryCode: '+33',
      countryRegex: RegExp(r'^(\+33)'),
      fullRegex: RegExp(r'^(\+?33|0)[67]\d{8}$')),
  'fr-GF': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'gf',
      countryCode: '+594',
      countryRegex: RegExp(r'^(\+594)'),
      fullRegex: RegExp(r'^(\+?594|0|00594)[67]\d{8}$')),
  'fr-GP': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'gp',
      countryCode: '+590',
      countryRegex: RegExp(r'^(\+590)'),
      fullRegex: RegExp(r'^(\+?590|0|00590)[67]\d{8}$')),
  'fr-MQ': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'mq',
      countryCode: '+596',
      countryRegex: RegExp(r'^(\+596)'),
      fullRegex: RegExp(r'^(\+?596|0|00596)[67]\d{8}$')),
  'fr-PF': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'pf',
      countryCode: '+689',
      countryRegex: RegExp(r'^(\+689)'),
      fullRegex: RegExp(r'^(\+?689)?8[789]\d{6}$')),
  'fr-RE': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 're',
      countryCode: '+262',
      countryRegex: RegExp(r'^(\+262)'),
      fullRegex: RegExp(r'^(\+?262|0|00262)[67]\d{8}$')),
  'fr-WF': CountryPhoneNumber(
      languageAbriviation: 'fr',
      countryAbriviation: 'wf',
      countryCode: '+681',
      countryRegex: RegExp(r'^(\+681)'),
      fullRegex: RegExp(r'^(\+681)?\d{6}$')),
  'he-IL': CountryPhoneNumber(
      languageAbriviation: 'he',
      countryAbriviation: 'il',
      countryCode: '+972',
      countryRegex: RegExp(r'^(\+972)'),
      fullRegex: RegExp(r'^(\+972|0)([23489]|5[012345689]|77)[1-9]\d{6}$')),
  'hu-HU': CountryPhoneNumber(
      languageAbriviation: 'hu',
      countryAbriviation: 'hu',
      countryCode: '+36',
      countryRegex: RegExp(r'^(\+36)'),
      fullRegex: RegExp(r'^(\+?36|06)(20|30|31|50|70)\d{7}$')),
  'id-ID': CountryPhoneNumber(
      languageAbriviation: 'id',
      countryAbriviation: 'id',
      countryCode: '+62',
      countryRegex: RegExp(r'^(\+62)'),
      fullRegex: RegExp(
          r'^(\+?62|0)8(1[123456789]|2[1238]|3[1238]|5[12356789]|7[78]|9[56789]|8[123456789])([\s?|\d]{5,11})$')),
  'ir-IR': CountryPhoneNumber(
      languageAbriviation: 'ir',
      countryAbriviation: 'ir',
      countryCode: '+98',
      countryRegex: RegExp(r'^(\+98)'),
      fullRegex: RegExp(r'^(\+98|0)?9\d{9}$')),
  'it-IT': CountryPhoneNumber(
      languageAbriviation: 'it',
      countryAbriviation: 'it',
      countryCode: '+39',
      countryRegex: RegExp(r'^(\+39)'),
      fullRegex: RegExp(r'^(\+?39)?\s?3\d{2} ?\d{6,7}$')),
  'it-SM': CountryPhoneNumber(
      languageAbriviation: 'it',
      countryAbriviation: 'sm',
      countryCode: '+378',
      countryRegex: RegExp(r'^(\+378)'),
      fullRegex: RegExp(r'^((\+378)|(0549)|(\+390549)|(\+3780549))?6\d{5,9}$')),
  'ja-JP': CountryPhoneNumber(
      languageAbriviation: 'ja',
      countryAbriviation: 'jp',
      countryCode: '+81',
      countryRegex: RegExp(r'^(\+81)'),
      fullRegex:
          RegExp(r'^(\+81[ \-]?(\(0\))?|0)[6789]0[ \-]?\d{4}[ \-]?\d{4}$')),
  'ka-GE': CountryPhoneNumber(
      languageAbriviation: 'ka',
      countryAbriviation: 'ge',
      countryCode: '+995',
      countryRegex: RegExp(r'^(\+995)'),
      fullRegex: RegExp(r'^(\+?995)?(79\d{7}|5\d{8})$')),
  'kk-KZ': CountryPhoneNumber(
      languageAbriviation: 'kk',
      countryAbriviation: 'kz',
      countryCode: '+7',
      countryRegex: RegExp(r'^(\+7)'),
      fullRegex: RegExp(r'^(\+?7|8)?7\d{9}$')),
  'kl-GL': CountryPhoneNumber(
      languageAbriviation: 'kl',
      countryAbriviation: 'gl',
      countryCode: '+299',
      countryRegex: RegExp(r'^(\+299)'),
      fullRegex: RegExp(r'^(\+?299)?\s?\d{2}\s?\d{2}\s?\d{2}$')),
  'ko-KR': CountryPhoneNumber(
      languageAbriviation: 'ko',
      countryAbriviation: 'kr',
      countryCode: '+82',
      countryRegex: RegExp(r'^(\+82)'),
      fullRegex: RegExp(
          r'^((\+?82)[ \-]?)?0?1([0|1|6|7|8|9]{1})[ \-]?\d{3,4}[ \-]?\d{4}$')),
  'ky-KG': CountryPhoneNumber(
      languageAbriviation: 'ky',
      countryAbriviation: 'kg',
      countryCode: '+996',
      countryRegex: RegExp(r'^(\+996)'),
      fullRegex: RegExp(r'^(\+?7\s?\+?7|0)\s?\d{2}\s?\d{3}\s?\d{4}$')),
  'lt-LT': CountryPhoneNumber(
      languageAbriviation: 'lt',
      countryAbriviation: 'lt',
      countryCode: '+370',
      countryRegex: RegExp(r'^(\+370)'),
      fullRegex: RegExp(r'^(\+370|8)\d{8}$')),
  'lv-LV': CountryPhoneNumber(
      languageAbriviation: 'lv',
      countryAbriviation: 'lv',
      countryCode: '+371',
      countryRegex: RegExp(r'^(\+371)'),
      fullRegex: RegExp(r'^(\+?371)2\d{7}$')),
  'mg-MG': CountryPhoneNumber(
      languageAbriviation: 'mg',
      countryAbriviation: 'mg',
      countryCode: '+261',
      countryRegex: RegExp(r'^(\+261)'),
      fullRegex: RegExp(r'^((\+?261|0)(2|3)\d)?\d{7}$')),
  'mn-MN': CountryPhoneNumber(
      languageAbriviation: 'mn',
      countryAbriviation: 'mn',
      countryCode: '+976',
      countryRegex: RegExp(r'^(\+976)'),
      fullRegex: RegExp(r'^(\+|00|011)?976(77|81|88|91|94|95|96|99)\d{6}$')),
  'ms-MY': CountryPhoneNumber(
      languageAbriviation: 'ms',
      countryAbriviation: 'my',
      countryCode: '+60',
      countryRegex: RegExp(r'^(\+60)'),
      fullRegex: RegExp(
          r'^(\+?60|0)1(([0145](-|\s)?\d{7,8})|([236-9](-|\s)?\d{7}))$')),
  'my-MM': CountryPhoneNumber(
      languageAbriviation: 'my',
      countryAbriviation: 'mm',
      countryCode: '+95',
      countryRegex: RegExp(r'^(\+95)'),
      fullRegex: RegExp(
          r'^(\+?959|09|9)(2[5-7]|3[1-2]|4[0-5]|6[6-9]|7[5-9]|9[6-9])[0-9]{7}$')),
  'mz-MZ': CountryPhoneNumber(
      languageAbriviation: 'mz',
      countryAbriviation: 'mz',
      countryCode: '+258',
      countryRegex: RegExp(r'^(\+258)'),
      fullRegex: RegExp(r'^(\+?258)?8[234567]\d{7}$')),
  'nb-NO': CountryPhoneNumber(
      languageAbriviation: 'nb',
      countryAbriviation: 'no',
      countryCode: '+47',
      countryRegex: RegExp(r'^(\+47)'),
      fullRegex: RegExp(r'^(\+?47)?[49]\d{7}$')),
  'ne-NP': CountryPhoneNumber(
      languageAbriviation: 'ne',
      countryAbriviation: 'np',
      countryCode: '+977',
      countryRegex: RegExp(r'^(\+977)'),
      fullRegex: RegExp(r'^(\+?977)?9[78]\d{8}$')),
  'nl-AW': CountryPhoneNumber(
      languageAbriviation: 'nl',
      countryAbriviation: 'aw',
      countryCode: '+297',
      countryRegex: RegExp(r'^(\+297)'),
      fullRegex: RegExp(r'^(\+)?297(56|59|64|73|74|99)\d{5}$')),
  'nl-BE': CountryPhoneNumber(
      languageAbriviation: 'nl',
      countryAbriviation: 'be',
      countryCode: '+32',
      countryRegex: RegExp(r'^(\+32)'),
      fullRegex: RegExp(r'^(\+?32|0)4\d{8}$')),
  'nl-NL': CountryPhoneNumber(
      languageAbriviation: 'nl',
      countryAbriviation: 'nl',
      countryCode: '+31',
      countryRegex: RegExp(r'^(\+31)'),
      fullRegex: RegExp(r'^(((\+|00)?31\(0\))|((\+|00)?31)|0)6{1}\d{8}$')),
  'nn-NO': CountryPhoneNumber(
      languageAbriviation: 'nn',
      countryAbriviation: 'no',
      countryCode: '+47',
      countryRegex: RegExp(r'^(\+47)'),
      fullRegex: RegExp(r'^(\+?47)?[49]\d{7}$')),
  'pl-PL': CountryPhoneNumber(
      languageAbriviation: 'pl',
      countryAbriviation: 'pl',
      countryCode: '+48',
      countryRegex: RegExp(r'^(\+48)'),
      fullRegex: RegExp(r'^(\+?48)? ?[5-8]\d ?\d{3} ?\d{2} ?\d{2}$')),
  'pt-AO': CountryPhoneNumber(
      languageAbriviation: 'pt',
      countryAbriviation: 'ao',
      countryCode: '+244',
      countryRegex: RegExp(r'^(\+244)'),
      fullRegex: RegExp(r'^(\+244)\d{9}$')),
  'pt-BR': CountryPhoneNumber(
      languageAbriviation: 'pt',
      countryAbriviation: 'br',
      countryCode: '+55',
      countryRegex: RegExp(r'^(\+55)'),
      fullRegex: RegExp(
          r'^((\+?55\ ?[1-9]{2}\ ?)|(\+?55\ ?\([1-9]{2}\)\ ?)|(0[1-9]{2}\ ?)|(\([1-9]{2}\)\ ?)|([1-9]{2}\ ?))((\d{4}\-?\d{4})|(9[1-9]{1}\d{3}\-?\d{4}))$')),
  'pt-PT': CountryPhoneNumber(
      languageAbriviation: 'pt',
      countryAbriviation: 'pt',
      countryCode: '+351',
      countryRegex: RegExp(r'^(\+351)'),
      fullRegex: RegExp(r'^(\+?351)?9[1236]\d{7}$')),
  'ro-MD': CountryPhoneNumber(
      languageAbriviation: 'ro',
      countryAbriviation: 'md',
      countryCode: '+373',
      countryRegex: RegExp(r'^(\+373)'),
      fullRegex: RegExp(r'^(\+?373|0)((6(0|1|2|6|7|8|9))|(7(6|7|8|9)))\d{6}$')),
  'ro-RO': CountryPhoneNumber(
      languageAbriviation: 'ro',
      countryAbriviation: 'ro',
      countryCode: '+40',
      countryRegex: RegExp(r'^(\+40)'),
      fullRegex:
          RegExp(r'^(\+?40|0)\s?7\d{2}(\/|\s|\.|-)?\d{3}(\s|\.|-)?\d{3}$')),
  'ru-RU': CountryPhoneNumber(
      languageAbriviation: 'ru',
      countryAbriviation: 'ru',
      countryCode: '+7',
      countryRegex: RegExp(r'^(\+7)'),
      fullRegex: RegExp(r'^(\+?7|8)?9\d{9}$')),
  'si-LK': CountryPhoneNumber(
      languageAbriviation: 'si',
      countryAbriviation: 'lk',
      countryCode: '+94',
      countryRegex: RegExp(r'^(\+94)'),
      fullRegex: RegExp(r'^(?:0|94|\+94)?(7(0|1|2|4|5|6|7|8)( |-)?)\d{7}$')),
  'sk-SK': CountryPhoneNumber(
      languageAbriviation: 'sk',
      countryAbriviation: 'sk',
      countryCode: '+421',
      countryRegex: RegExp(r'^(\+421)'),
      fullRegex: RegExp(r'^(\+?421)? ?[1-9][0-9]{2} ?[0-9]{3} ?[0-9]{3}$')),
  'sl-SI': CountryPhoneNumber(
      languageAbriviation: 'sl',
      countryAbriviation: 'si',
      countryCode: '+386',
      countryRegex: RegExp(r'^(\+386)'),
      fullRegex: RegExp(
          r'^(\+386\s?|0)(\d{1}\s?\d{3}\s?\d{2}\s?\d{2}|\d{2}\s?\d{3}\s?\d{3})$')),
  'so-SO': CountryPhoneNumber(
      languageAbriviation: 'so',
      countryAbriviation: 'so',
      countryCode: '+252',
      countryRegex: RegExp(r'^(\+252)'),
      fullRegex: RegExp(r'^(\+?252|0)((6[0-9])\d{7}|(7[1-9])\d{7})$')),
  'sq-AL': CountryPhoneNumber(
      languageAbriviation: 'sq',
      countryAbriviation: 'al',
      countryCode: '+355',
      countryRegex: RegExp(r'^(\+355)'),
      fullRegex: RegExp(r'^(\+355|0)6[789]\d{6}$')),
  'sr-RS': CountryPhoneNumber(
      languageAbriviation: 'sr',
      countryAbriviation: 'rs',
      countryCode: '+381',
      countryRegex: RegExp(r'^(\+381)'),
      fullRegex: RegExp(r'^(\+3816|06)[- \d]{5,9}$')),
  'sv-SE': CountryPhoneNumber(
      languageAbriviation: 'sv',
      countryAbriviation: 'se',
      countryCode: '+46',
      countryRegex: RegExp(r'^(\+46)'),
      fullRegex: RegExp(r'^(\+?46|0)[\s\-]?7[\s\-]?[02369]([\s\-]?\d){7}$')),
  'tg-TJ': CountryPhoneNumber(
      languageAbriviation: 'tg',
      countryAbriviation: 'tj',
      countryCode: '+992',
      countryRegex: RegExp(r'^(\+992)'),
      fullRegex: RegExp(r'^(\+?992)?[5][5]\d{7}$')),
  'th-TH': CountryPhoneNumber(
      languageAbriviation: 'th',
      countryAbriviation: 'th',
      countryCode: '+66',
      countryRegex: RegExp(r'^(\+66)'),
      fullRegex: RegExp(r'^(\+66|66|0)\d{9}$')),
  'tk-TM': CountryPhoneNumber(
      languageAbriviation: 'tk',
      countryAbriviation: 'tm',
      countryCode: '+993',
      countryRegex: RegExp(r'^(\+993)'),
      fullRegex: RegExp(r'^(\+993|993|8)\d{8}$')),
  'tr-TR': CountryPhoneNumber(
      languageAbriviation: 'tr',
      countryAbriviation: 'tr',
      countryCode: '+90',
      countryRegex: RegExp(r'^(\+90)'),
      fullRegex: RegExp(r'^(\+?90|0)?5\d{9}$')),
  'uk-UA': CountryPhoneNumber(
      languageAbriviation: 'uk',
      countryAbriviation: 'ua',
      countryCode: '+380',
      countryRegex: RegExp(r'^(\+380)'),
      fullRegex: RegExp(r'^(\+?38|8)?0\d{9}$')),
  'uz-UZ': CountryPhoneNumber(
      languageAbriviation: 'uz',
      countryAbriviation: 'uz',
      countryCode: '+998',
      countryRegex: RegExp(r'^(\+998)'),
      fullRegex: RegExp(r'^(\+?998)?(6[125-79]|7[1-69]|88|9\d)\d{7}$')),
  'vi-VN': CountryPhoneNumber(
      languageAbriviation: 'vi',
      countryAbriviation: 'vn',
      countryCode: '+84',
      countryRegex: RegExp(r'^(\+84)'),
      fullRegex: RegExp(
          r'^((\+?84)|0)((3([2-9]))|(5([25689]))|(7([0|6-9]))|(8([1-9]))|(9([0-9])))([0-9]{7})$')),
  'zh-CN': CountryPhoneNumber(
      languageAbriviation: 'zh',
      countryAbriviation: 'cn',
      countryCode: '+86',
      countryRegex: RegExp(r'^(\+86)'),
      fullRegex: RegExp(r'^((\+|00)86)?(1[3-9]|9[28])\d{9}$')),
  'zh-TW': CountryPhoneNumber(
      languageAbriviation: 'zh',
      countryAbriviation: 'tw',
      countryCode: '+886',
      countryRegex: RegExp(r'^(\+886)'),
      fullRegex: RegExp(r'^(\+?886\-?|0)?9\d{8}$')),

  /// Supports numbers with or without spaces, periods, or dashes
  //'mostBasic': RegExp(r'^\+?\d+([ .-]?\d+)*$').hasMatch(text);
};

String? extractCountryCode(String country) => _phonesFormats[[
      for (final x in _phonesFormats.keys)
        if (x.split('-').last.toLowerCase() == country) x
    ].firstOrNull]
        ?.countryCode;

Set get phoneFormatRegions =>
    _phonesFormats.keys.map((k) => k.split('-').last.toLowerCase()).toSet();

String removePlus(String number) =>
    number.startsWith('+') ? number.substring(1) : number;

bool isPhoneNumber(String number) {
  number = removePlus(number);
  return _phonesFormats.values
      .any((pattern) => pattern.fullRegex.hasMatch(number));
}

bool isCountryNumber(String number) {
  number = removePlus(number);
  return _phonesFormats.values
      .any((pattern) => pattern.countryRegex.hasMatch(number));
}

String? detectPhoneFormat(String number) {
  number = removePlus(number);
  for (final MapEntry<String, CountryPhoneNumber> entry
      in _phonesFormats.entries) {
    if (entry.value.fullRegex.hasMatch(number)) {
      return entry.key;
    }
  }
  return null;
}

String? detectCountryFormat(String number) {
  for (final MapEntry<String, CountryPhoneNumber> entry
      in _phonesFormats.entries) {
    if (entry.value.countryRegex.hasMatch(number)) {
      return entry.key;
    }
  }
  return null;
}
