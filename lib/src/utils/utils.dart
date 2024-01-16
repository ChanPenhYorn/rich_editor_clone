String formatUrl({required String link}) {
  var format = '';
  RegExp urlRegex = RegExp(r'^https?');
  RegExp url2Regex = RegExp(r'^http?');
  if (!urlRegex.hasMatch(link) || !url2Regex.hasMatch(link)) {
    format = "https://$link";
  } else {
    format = link;
  }

  return format;
}
