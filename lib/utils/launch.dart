import 'package:url_launcher/url_launcher.dart';

import '../data/portfolio_data.dart';

Future<void> openUrl(String url) =>
    launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

/// Opens the visitor's mail client. Encoded by hand because mail clients show
/// the `+` that [Uri.queryParameters] uses for spaces literally.
Future<void> sendEmail({String subject = '', String body = ''}) {
  final query = [
    if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
    if (body.isNotEmpty) 'body=${Uri.encodeComponent(body)}',
  ].join('&');
  return launchUrl(
      Uri.parse('mailto:${Links.email}${query.isEmpty ? '' : '?$query'}'));
}
