/// The user's gender for the sake of ad targeting using [MobileAdTargetingInfo].
// Warning: the index values of the enums must match the values of the corresponding
// AdMob constants. For example MobileAdGender.female.index == kGADGenderFemale.
@Deprecated('This functionality is deprecated in AdMob without replacement.')
enum MobileAdGender {
  unknown,
  male,
  female,
}

/// Targeting info per the native AdMob API.
///
/// This class's properties mirror the native AdRequest API. See for example:
/// [AdRequest.Builder for Android](https://firebase.google.com/docs/reference/android/com/google/android/gms/ads/AdRequest.Builder).
class MobileAdTargetingInfo {
  const MobileAdTargetingInfo(
      {this.keywords,
      this.contentUrl,
      @Deprecated('This functionality is deprecated in AdMob without replacement.')
          this.birthday,
      @Deprecated('This functionality is deprecated in AdMob without replacement.')
          this.gender,
      @Deprecated('Use `childDirected` instead.')
          this.designedForFamilies,
      this.childDirected,
      this.testDevices,
      this.nonPersonalizedAds});

  final List<String> keywords;
  final String contentUrl;
  @Deprecated('This functionality is deprecated in AdMob without replacement.')
  final DateTime birthday;
  @Deprecated('This functionality is deprecated in AdMob without replacement.')
  final MobileAdGender gender;
  @Deprecated(
      'This functionality is deprecated in AdMob.  Use `childDirected` instead.')
  final bool designedForFamilies;
  final bool childDirected;
  final List<String> testDevices;
  final bool nonPersonalizedAds;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'requestAgent': 'flutter-alpha',
    };

    if (keywords != null && keywords.isNotEmpty) {
      assert(keywords.every((String s) => s != null && s.isNotEmpty));
      json['keywords'] = keywords;
    }
    if (nonPersonalizedAds != null) {
      json['nonPersonalizedAds'] = nonPersonalizedAds;
    }
    if (contentUrl != null && contentUrl.isNotEmpty) {
      json['contentUrl'] = contentUrl;
    }
    if (birthday != null) json['birthday'] = birthday.millisecondsSinceEpoch;
    if (gender != null) json['gender'] = gender.index;
    if (designedForFamilies != null) {
      json['designedForFamilies'] = designedForFamilies;
    }
    if (childDirected != null) json['childDirected'] = childDirected;
    if (testDevices != null && testDevices.isNotEmpty) {
      assert(testDevices.every((String s) => s != null && s.isNotEmpty));
      json['testDevices'] = testDevices;
    }

    return json;
  }
}
