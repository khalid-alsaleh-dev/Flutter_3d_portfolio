import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../effects/scroll_progress.dart';
import '../effects/slash_heading.dart';
import '../utils/custom_colors.dart';
import '../utils/launch.dart';
import '../widgets/blade_button.dart';
import '../widgets/planet.dart';
import '../widgets/section_frame.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) return;
    sendEmail(
      subject: 'Portfolio message from ${_name.text.trim()}',
      body: '${_message.text.trim()}\n\n${_name.text.trim()} · ${_email.text.trim()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final form = _form();
    final planet = AspectRatio(aspectRatio: 1, child: const Planet());
    return SectionFrame(
      child: Padding(
        padding: const EdgeInsets.only(top: 120, bottom: 60),
        child: ScrollProgress(builder: (context, p, _) {
          final t = interval(p, 0.05, 0.35, Curves.easeOutCubic);
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 80 * (1 - t)),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: form),
                        const SizedBox(width: 48),
                        Expanded(flex: 4, child: planet),
                      ],
                    )
                  : Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: planet,
                        ),
                        const SizedBox(height: 32),
                        form,
                      ],
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _form() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: CustomColors.glass,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: CustomColors.primary.withValues(alpha: 0.35)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SlashHeading(eyebrow: 'Get in touch', title: 'Contact.'),
            const SizedBox(height: 28),
            _field(_name, 'Your name', validator: _required),
            const SizedBox(height: 18),
            _field(_email, 'Your email', validator: (v) {
              if (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            }),
            const SizedBox(height: 18),
            _field(_message, 'What would you like to build?',
                maxLines: 6, validator: _required),
            const SizedBox(height: 26),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                BladeButton(
                  label: 'Send',
                  icon: Icons.send_rounded,
                  filled: true,
                  onPressed: _send,
                ),
                const BladeButton(
                  label: 'WhatsApp',
                  icon: Icons.chat_rounded,
                  onPressed: openWhatsApp,
                ),
                const BladeButton(
                  label: Links.phoneLabel,
                  icon: Icons.call_rounded,
                  onPressed: callPhone,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  Widget _field(TextEditingController controller, String hint,
      {int maxLines = 1, String? Function(String?)? validator}) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color),
        );
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      cursorColor: CustomColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        filled: true,
        fillColor: CustomColors.textForm,
        contentPadding: const EdgeInsets.all(18),
        enabledBorder: border(Colors.white.withValues(alpha: 0.06)),
        focusedBorder: border(CustomColors.primary),
        errorBorder: border(CustomColors.secondary),
        focusedErrorBorder: border(CustomColors.secondary),
      ),
    );
  }
}
