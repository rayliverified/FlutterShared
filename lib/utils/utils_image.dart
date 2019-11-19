class ImageUtils {
  /// Create Cloudinary image URL from [imagePublicId].
  static String getCloudinaryThumbnail(String imagePublicId) {
    String res = "w_1080,c_limit";
    String cloudinaryApi = "v1530986461";
    return "https://res.cloudinary.com/nocdcloud/image/upload/$res/$cloudinaryApi/$imagePublicId";
  }

  /// Create Cloudinary clinician image URL from [imagePublicId].
  /// Set resolution in pixels with [res].
  static String getCloudinaryThumbnailClinician(String imagePublicId,
      {int res = 256}) {
    String resHolder = "c_crop,g_custom,r_max/w_$res";
    if (imagePublicId.endsWith('.jpg')) {
      imagePublicId =
          imagePublicId.substring(0, imagePublicId.lastIndexOf('.jpg')) +
              '.png';
    }
    return "https://res.cloudinary.com/nocdcloud/image/upload/$resHolder/$imagePublicId";
  }
}
