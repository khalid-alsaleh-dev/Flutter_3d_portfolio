import 'package:flutter/material.dart';

import '../utils/image_assets.dart';

class Links {
  static const email = 'khalid.alsaleh.dev@gmail.com';
  static const phone = '+971542469465';
  static const phoneLabel = '+971 54 246 9465';
  static const whatsapp = 'https://wa.me/971542469465';
  static const github = 'https://github.com/khalid-alsaleh-dev';
  static const linkedin =
      'https://www.linkedin.com/in/khalid-al-saleh-3561881a8/';
  static const facebook = 'https://www.facebook.com/khalid.alsaleh.52090/';
}

/// A small visual mark: either a bundled logo or a Material icon.
class Emblem {
  const Emblem.image(String this.asset) : icon = null;
  const Emblem.icon(IconData this.icon) : asset = null;
  final String? asset;
  final IconData? icon;
}

class Role {
  const Role(this.title, this.emblem);
  final String title;
  final Emblem emblem;
}

class Job {
  const Job(
    this.title,
    this.emblem,
    this.time,
    this.summary, {
    this.highlights = const [],
    this.stack = const [],
  });
  final String title;
  final Emblem emblem;
  final String time;
  final String summary;
  final List<String> highlights;
  final List<String> stack;
}

class SkillGroup {
  const SkillGroup(this.title, this.skills);
  final String title;
  final List<String> skills;
}

/// Which kind of screen the project's phone mockup shows.
enum MockLayout { dashboard, live, deals, shop, course }

class Project {
  const Project(
    this.title,
    this.description, {
    required this.accent,
    required this.icon,
    required this.layout,
    this.tags = const [],
    this.url,
    this.github,
    this.appStore,
    this.playStore,
    this.note = 'Private client project',
    this.preview,
    this.previewAspect = 1,
    this.previewHost,
    this.reel,
    this.formReel,
  });
  final String title;
  final String description;
  final Color accent;
  final IconData icon;
  final MockLayout layout;
  final List<String> tags;

  /// Public website.
  final String? url;

  /// Client work is usually private, so a repository link is optional.
  final String? github;
  final String? appStore;
  final String? playStore;

  /// Shown instead of links when a project has none.
  final String note;

  /// Full-page website screenshot played as a scrolling preview, and its
  /// height-to-width ratio. Without one, the card shows a phone mockup.
  final String? preview;
  final double previewAspect;

  /// Address shown in the preview's browser bar when there is no [url] to
  /// link to (for example, a platform that is no longer online).
  final String? previewHost;

  /// Two real app screens played as a short looping walkthrough on a phone.
  /// Takes the place of the phone mockup.
  final AppReel? reel;

  /// One website screenshot played as a screen recording of filling in its
  /// form. Takes the place of [preview].
  final FormReel? formReel;

  bool get hasLinks =>
      url != null || github != null || appStore != null || playStore != null;
}

/// A walkthrough of an app from two screenshots: the list screen, a tap on
/// one item, its detail screen, a tap on its like button, and back.
class AppReel {
  const AppReel({
    required this.list,
    required this.detail,
    required this.open,
    required this.like,
    required this.stamp,
    required this.items,
    this.chip,
  });

  /// Screenshots of the app screen only (no device frame), 9:16.
  final String list;
  final String detail;

  /// Where the finger taps, as fractions of the screen: the item opened on
  /// [list], and the like button on [detail].
  final Offset open;
  final Offset like;

  /// Badge stamped onto the detail screen, e.g. a discount.
  final String stamp;

  /// Items from the list screen, shown as tickets beside the phone: a short
  /// label and its name. The last one is the item that gets opened.
  final List<(String, String)> items;

  /// Small label in the corner, e.g. the app's languages.
  final String? chip;
}

/// A screen recording made from one website screenshot: the cursor clicks
/// [connect], the view zooms in on the form, each field is typed in, [submit]
/// is clicked and a confirmation pops up.
///
/// Every rect is a fraction of the screenshot (left, top, right, bottom).
class FormReel {
  const FormReel({
    required this.shot,
    required this.aspect,
    required this.connect,
    required this.connected,
    required this.badge,
    required this.fields,
    required this.submit,
    required this.done,
    this.shine,
    this.colors = const FormReelColors(),
  });

  final String shot;

  /// Screenshot height divided by width.
  final double aspect;

  /// The button clicked first, and the label it shows afterwards. The label
  /// also appears in [badge] (e.g. the connected account on a card).
  final Rect connect;
  final String connected;
  final Rect badge;

  /// Area that shines once the form is sent (e.g. the card holding [badge]).
  final Rect? shine;

  /// Each input and the text typed into it.
  final List<(Rect, String)> fields;
  final Rect submit;

  /// Confirmation shown once the form is sent.
  final String done;
  final FormReelColors colors;
}

/// The site's own colours, so drawn-on states blend with the screenshot.
class FormReelColors {
  const FormReelColors({
    this.field = const Color(0xff232746),
    this.button = const Color(0xff2952E3),
    this.panel = const Color(0xff191C2F),
  });

  final Color field;
  final Color button;
  final Color panel;
}

class PortfolioData {
  static const name = 'Khalid';
  static const surname = 'Al-Saleh';

  static const location = 'Dubai, UAE';

  static const tagline =
      'Dubai-based Senior Flutter Engineer with 5+ years building production mobile apps and the backend systems behind them.';

  static const typedRoles = [
    'Senior Flutter Engineer',
    'Mobile Architect',
    'Backend Lead (NestJS)',
    'Engineering Team Lead',
  ];

  static const overview = [
    'Senior Flutter Engineer based in Dubai, UAE, shipping production mobile applications and the backend systems that support them since 2019.',
    'Specialized in Flutter and Dart: enterprise and multi-tenant SaaS apps, real-time experiences, authentication flows, API integrations and Firebase-based services.',
    'A strong backend side in NestJS, Node.js, TypeScript, PostgreSQL, MongoDB and Redis, so the apps I build sit on reliable, scalable APIs and real-time communication.',
    'I own features from technical design through implementation, testing and production release, and I have led teams through architecture decisions, code reviews and mentoring.',
    'Bachelor of Computer Science, Aleppo University (2023). Arabic native, English fluent.',
  ];

  static const roles = [
    Role('Senior Flutter Engineer', Emblem.image(ImageAssets.greenFlutter)),
    Role('Backend Engineer', Emblem.image(ImageAssets.backend)),
    Role('Real-Time Systems', Emblem.icon(Icons.bolt_rounded)),
    Role('Technical Leadership', Emblem.icon(Icons.groups_rounded)),
  ];

  static const jobs = [
    Job(
      'Backend Lead & Flutter Engineer',
      Emblem.image(ImageAssets.nestjs),
      'Mar 2024 - Present · Dubai',
      'Led the backend for two production platforms, an AI-powered multi-tenant HR SaaS and a video-learning platform, while building Flutter features on the mobile side.',
      highlights: [
        'Led backend architecture and delivery for the HR platform and the video-learning platform.',
        'Built secure, banking-integrated APIs for course payments and commission withdrawals.',
        'Build and maintain production Flutter features backed by scalable backend services and REST APIs.',
        'Implement real-time communication between the Flutter apps and backend services.',
        'Improved API response times by ~35% through Redis caching and database query optimization.',
        'Cut deployment time by ~40% with Docker-based workflows and CI/CD automation.',
        'Diagnose integration, performance and production issues across the whole stack.',
        'Shape architecture and technical decisions across mobile and backend, and take features from requirements to production.',
      ],
      stack: [
        'Flutter',
        'Dart',
        'NestJS',
        'TypeScript',
        'Redis',
        'PostgreSQL',
        'Docker',
        'CI/CD',
      ],
    ),
    Job(
      'Engineering Team Lead',
      Emblem.icon(Icons.groups_rounded),
      '2023 - Early 2024',
      'Led the engineering team delivering a trend-intelligence platform for a major real-estate developer.',
      highlights: [
        'Owned technical direction, architecture decisions, sprint planning and engineering standards.',
        'Guided implementation quality through code reviews and hands-on technical support.',
        'Mentored developers and established consistent engineering practices across the team.',
        'Translated stakeholder requirements into practical technical solutions.',
        'Balanced delivery pace with maintainability, scalability and engineering quality.',
      ],
      stack: [
        'Architecture',
        'Code Reviews',
        'Mentoring',
        'Sprint Planning',
        'Agile',
      ],
    ),
    Job(
      'Freelance Flutter / Full-Stack Developer',
      Emblem.icon(Icons.public_rounded),
      '2021 - 2024',
      'Designed and delivered production apps for clients across Europe and the Middle East.',
      highlights: [
        'Built a deals marketplace app end to end: mobile client, payment integration and supporting backend services.',
        'Developed a Saudi e-commerce platform with Flutter and Node.js.',
        'Designed app architecture, authentication flows, API integrations and cloud-connected services.',
        'Worked directly with clients from requirements and technical planning through production deployment.',
        'Adapted architecture and implementation to each business domain.',
      ],
      stack: ['Flutter', 'Node.js', 'Payments', 'Auth', 'Firebase', 'REST'],
    ),
    Job(
      'Flutter & Backend Developer',
      Emblem.image(ImageAssets.flutter),
      '2019 - 2021',
      'Enterprise mobile applications and the backend modules behind them.',
      highlights: [
        'Developed enterprise mobile applications with Flutter and Dart.',
        'Built a real-time operations management platform.',
        'Integrated mobile apps with REST APIs and backend services, and built reusable backend modules.',
        'Improved application performance and deployment workflows across mobile and backend.',
      ],
      stack: ['Flutter', 'Dart', 'Node.js', 'REST', 'Real-time'],
    ),
  ];

  static const projects = [
    Project(
      'MAI HRMS',
      'Backend lead for an AI-powered, multi-tenant HR platform for UAE businesses. I led the NestJS backend: strict tenant data isolation, payroll, attendance and leave services, real-time communication with the apps, and Redis caching that cut API response times by ~35%. I also build its Flutter mobile app.',
      accent: Color(0xff8B7CFF),
      icon: Icons.badge_rounded,
      layout: MockLayout.dashboard,
      tags: ['Backend lead', 'NestJS', 'Multi-tenant', 'Redis', 'Flutter'],
      url: 'https://maihrms.com',
      preview: 'assets/images/previews/maihrms.webp',
      previewAspect: 7000 / 720,
      appStore: 'https://apps.apple.com/ae/app/mai-hrms/id6760653604',
      playStore:
          'https://play.google.com/store/apps/details?id=com.softbuilders.maihrms',
    ),
    Project(
      'Skillami',
      'Backend lead for an online video-learning platform. I led the backend behind video streaming, authentication, course management and real-time progress tracking, plus secure banking-integrated APIs for course payments and commission withdrawals, shipped through CI/CD pipelines.',
      accent: Color(0xffE5383B),
      icon: Icons.play_lesson_rounded,
      layout: MockLayout.course,
      tags: ['Backend lead', 'Video streaming', 'Payments', 'CI/CD'],
      note: 'Web platform · no longer online',
      preview: 'assets/images/previews/skillami.webp',
      previewAspect: 1837 / 720,
      previewHost: 'skillami.com',
    ),
    Project(
      'Deals Marketplace',
      'A deals marketplace delivered end to end: the Flutter mobile app, payment integration and the backend services behind it.',
      accent: Color(0xffDF504A),
      icon: Icons.local_offer_rounded,
      layout: MockLayout.deals,
      tags: ['Flutter', 'Payments', 'Backend', 'Freelance'],
      reel: AppReel(
        list: 'assets/images/reels/deals_feed.webp',
        detail: 'assets/images/reels/deals_detail.webp',
        open: Offset(0.5, 0.88),
        like: Offset(0.66, 0.975),
        stamp: '−67%',
        items: [
          ('−40%', 'Vileda Steam'),
          ('−29%', 'Dell Inspiron'),
          ('−67%', 'Puma Basket'),
        ],
        chip: 'DE · AR',
      ),
    ),
    Project(
      'EthKrypto',
      'A Web3 app for sending Ethereum. A Solidity smart contract, built and deployed with Hardhat, records every transfer on chain with a message and a keyword. The React and TypeScript frontend connects to MetaMask through ethers.js, sends ETH and lists the latest transfers, each with a GIF matched to its keyword.',
      accent: Color(0xff2952E3),
      icon: Icons.account_balance_wallet_rounded,
      layout: MockLayout.shop,
      tags: ['Web3', 'Solidity', 'React', 'TypeScript', 'ethers.js'],
      github: 'https://github.com/khalid-alsaleh-dev/Ethkrypto',
      previewHost: 'localhost:3000',
      formReel: FormReel(
        shot: 'assets/images/previews/ethkrypto.webp',
        aspect: 969 / 1892,
        connect: Rect.fromLTRB(0.2738, 0.3973, 0.4915, 0.4469),
        connected: '0x8a3F…c9D1',
        badge: Rect.fromLTRB(0.5518, 0.2704, 0.6342, 0.2910),
        shine: Rect.fromLTRB(0.5449, 0.1703, 0.6971, 0.3354),
        fields: [
          (Rect.fromLTRB(0.5307, 0.3860, 0.7114, 0.4231), '0x5aE0…41f2'),
          (Rect.fromLTRB(0.5307, 0.4396, 0.7114, 0.4768), '0.05'),
          (Rect.fromLTRB(0.5307, 0.4933, 0.7114, 0.5304), 'to the moon'),
          (Rect.fromLTRB(0.5307, 0.5470, 0.7114, 0.5841), 'Coffee is on me'),
        ],
        submit: Rect.fromLTRB(0.5307, 0.6182, 0.7114, 0.6574),
        done: 'Sent 0.05 ETH · confirmed',
      ),
    ),
  ];
  static const skills = [
    SkillGroup('Mobile', [
      'Flutter',
      'Dart',
      'Android (Java)',
      'Firebase',
      'bloc',
      'GetX',
      'Mobile architecture',
      'Real-time apps',
    ]),
    SkillGroup('Backend', [
      'NestJS',
      'Node.js',
      'TypeScript',
      'JavaScript',
      'REST APIs',
      'GraphQL',
      'Real-time systems',
      'Authentication',
    ]),
    SkillGroup('Data', [
      'PostgreSQL',
      'MongoDB',
      'Redis',
      'TypeORM',
      'Caching',
      'Query optimization',
    ]),
    SkillGroup('DevOps', [
      'Docker',
      'GitHub Actions',
      'CI/CD',
      'Git',
      'Production releases',
    ]),
    SkillGroup('AI', [
      'TensorFlow Lite',
      'Face recognition',
      'AI integrations',
    ]),
    SkillGroup('Leadership', [
      'Technical leadership',
      'Architecture',
      'Code reviews',
      'Mentoring',
      'Agile delivery',
    ]),
  ];
}
