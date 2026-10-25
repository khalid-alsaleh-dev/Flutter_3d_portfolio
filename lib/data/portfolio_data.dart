import 'package:flutter/material.dart';

import '../utils/image_assets.dart';

class Links {
  static const email = 'khalid.alsaleh.dev@gmail.com';
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
enum MockLayout { dashboard, live, deals, shop }

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
  });
  final String title;
  final String description;
  final Color accent;
  final IconData icon;
  final MockLayout layout;
  final List<String> tags;
  final String? url;

  /// Client work is usually private, so a repository link is optional.
  final String? github;
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
    'NestJS Backend Engineer',
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
      'Backend & Flutter Engineer',
      Emblem.image(ImageAssets.flutter),
      'Mar 2024 - Present · Dubai',
      'Production Flutter features for a multi-tenant HR SaaS platform used by multiple organizations, and the backend services behind them.',
      highlights: [
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
      Emblem.image(ImageAssets.nestjs),
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
      'Multi-Tenant HR Platform',
      'Production Flutter app for an HR SaaS used by multiple organizations: tenant-aware sessions, real-time updates from the backend and REST integration with scalable services.',
      accent: Color(0xff6AE99F),
      icon: Icons.badge_rounded,
      layout: MockLayout.dashboard,
      tags: ['Flutter', 'Multi-tenant', 'Real-time', 'Redis'],
    ),
    Project(
      'Real-Time Ops Manager',
      'Enterprise operations management platform with live data, built in Flutter on top of reusable backend modules.',
      accent: Color(0xff5F70F9),
      icon: Icons.monitor_heart_rounded,
      layout: MockLayout.live,
      tags: ['Flutter', 'Real-time', 'Node.js', 'Enterprise'],
    ),
    Project(
      'Deals Marketplace',
      'A deals marketplace delivered end to end: the Flutter mobile app, payment integration and the backend services behind it.',
      accent: Color(0xffDF504A),
      icon: Icons.local_offer_rounded,
      layout: MockLayout.deals,
      tags: ['Flutter', 'Payments', 'Backend', 'Freelance'],
    ),
    Project(
      'Saudi E-Commerce App',
      'E-commerce platform for the Saudi market: a Flutter storefront app with authentication and a Node.js backend.',
      accent: Color(0xffF2B84B),
      icon: Icons.shopping_bag_rounded,
      layout: MockLayout.shop,
      tags: ['Flutter', 'Node.js', 'E-commerce', 'Auth'],
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
