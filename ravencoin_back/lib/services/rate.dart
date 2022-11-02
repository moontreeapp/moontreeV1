import 'package:ravencoin_back/ravencoin_back.dart';

abstract class RateServiceInterface {
  double? get rvnToUSD;
}

class RateService implements RateServiceInterface {
  @override
  double? get rvnToUSD => pros.rates.primaryIndex
      .getOne(pros.securities.RVN, pros.securities.USD)
      ?.rate;
}
