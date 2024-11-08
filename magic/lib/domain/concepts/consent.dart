enum ConsentDocument {
  userAgreement,
  privacyPolicy,
  riskDisclosures;

  String get urlName {
    switch (this) {
      case ConsentDocument.userAgreement:
        return 'user_agreement';
      case ConsentDocument.privacyPolicy:
        return 'privacy_policy';
      case ConsentDocument.riskDisclosures:
        return 'risk_disclosures';
    }
  }
}

class Consent {
  //Consent() : client = Client('$moontreeUrl/');
  static const String moontreeUrl = 'https://api.moontree.com';
  static const String textUrl = 'https://moontree.com';

  //final Client client;

  //Future<void> given(String deviceId, ConsentDocument consentDocument) async =>
  //    client.consent.given(deviceId, consentDocument.name);
  //
  //Future<bool> haveIConsented(
  //        String deviceId, ConsentDocument consentDocument) async =>
  //    client.hasGiven.consent(deviceId, consentDocument.name);
}

String documentEndpoint(ConsentDocument consentDocument) =>
    '${Consent.textUrl}/${consentDocument.name}.html';

//Future<bool> discoverConsent(String deviceId) async {
//  final Consent consent = Consent();
//  final bool userAgreement = await consent.haveIConsented(
//    deviceId,
//    ConsentDocument.userAgreement,
//  );
//  final bool privacyPolicy = await consent.haveIConsented(
//    deviceId,
//    ConsentDocument.privacyPolicy,
//  );
//  final bool riskDisclosure = await consent.haveIConsented(
//    deviceId,
//    ConsentDocument.riskDisclosures,
//  );
//  return userAgreement && privacyPolicy && riskDisclosure;
//}

/// only for dev use
//Future<void> uploadNewDocument() async {
//  final Consent consent = Consent();
//  await consent.client.document.upload(
//      'QmbjXoq2jj3ikqtJVUCAPhzmSdQY1QderYYNiDxABbMVoY',
//      ConsentDocument.userAgreement.urlName,
//      'June 17, 2022');
//  await consent.client.document.upload(
//      'QmfXjUQyEPxkn9ShSxtSQH8tNVhrzoLfSNtbTYm7PfKVsc',
//      ConsentDocument.privacyPolicy.urlName,
//      'June 17, 2022');
//  await consent.client.document.upload(
//      'Qmb86hqUJNCUrpwukZtuWUqunL7GhrkwjZErmWNMbhf5HE',
//      ConsentDocument.riskDisclosures.urlName,
//      null);
//}

//Future<bool> consentToAgreements(String deviceId) async {
//  //uploadNewDocument();
//  // consent just once
//  try {
//    final Consent consent = Consent();
//    await consent.given(deviceId, ConsentDocument.userAgreement);
//    await consent.given(deviceId, ConsentDocument.privacyPolicy);
//    await consent.given(deviceId, ConsentDocument.riskDisclosures);
//    return true;
//  } catch (e) {
//    see('unable $e');
//  }
//  return false;
//}
