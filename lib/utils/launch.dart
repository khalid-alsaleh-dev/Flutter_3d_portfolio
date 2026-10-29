import 'package:url_launcher/url_launcher.dart';

import '../data/portfolio_data.dart';

Future<void> openUrl(String url) =>
    launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');

/// Starts a phone call (on desktop, hands off to the system's calling app).
Future<void> callPhone() => launchUrl(Uri.parse('tel:${Links.phone}'));

/// Opens a WhatsApp chat with a greeting already typed.
Future<void> openWhatsApp() => openUrl(
    '${Links.whatsapp}?text=${Uri.encodeComponent('Hello Khalid!')}');

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
