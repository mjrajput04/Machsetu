import 'package:flutter/material.dart';

class MachineSpec {
  const MachineSpec({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;
}

class Machine {
  const Machine({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.note,
    required this.ctaLabel,
    required this.specs,
    required this.year,
    this.icon = Icons.precision_manufacturing,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String note;
  final String ctaLabel;
  final List<MachineSpec> specs;
  final String year;
  final IconData icon;
}

/// Static catalogue used until the listings API is connected.
class MachineData {
  MachineData._();

  static const List<Machine> featured = [
    Machine(
      title: 'Haas VF-2 Super Speed',
      subtitle: 'Vertical Machining Center',
      badge: 'EXCELLENT CONDITION',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      year: '2019',
      icon: Icons.precision_manufacturing,
      specs: [
        MachineSpec(icon: Icons.factory_outlined, label: 'BRAND', value: 'HAAS'),
        MachineSpec(icon: Icons.calendar_today_outlined, label: 'YEAR', value: '2019'),
        MachineSpec(icon: Icons.speed_outlined, label: 'RPM', value: '15,000'),
      ],
    ),
    Machine(
      title: 'DMG MORI NHX 5000',
      subtitle: 'Horizontal Machining Center',
      badge: 'CERTIFIED 2024',
      note: 'INSTALL INCLUDED',
      ctaLabel: 'View Configuration Sheet',
      year: '2021',
      icon: Icons.settings_suggest_outlined,
      specs: [
        MachineSpec(icon: Icons.factory_outlined, label: 'BRAND', value: 'DMG MORI'),
        MachineSpec(icon: Icons.calendar_today_outlined, label: 'YEAR', value: '2021'),
        MachineSpec(icon: Icons.straighten, label: 'TRAVEL', value: '730mm'),
      ],
    ),
  ];

  static const List<Machine> recent = [
    Machine(
      title: 'Mazak Quick Turn 200',
      subtitle: 'CNC Turning Center',
      badge: 'VERIFIED',
      note: '',
      ctaLabel: 'View',
      year: '2016',
      icon: Icons.rotate_right,
      specs: [],
    ),
    Machine(
      title: 'Fanuc RoboDrill A-D21',
      subtitle: 'Compact Machining Center',
      badge: 'VERIFIED',
      note: '',
      ctaLabel: 'View',
      year: '2018',
      icon: Icons.smart_toy_outlined,
      specs: [],
    ),
    Machine(
      title: 'Doosan Lynx 2100',
      subtitle: 'CNC Lathe',
      badge: 'VERIFIED',
      note: '',
      ctaLabel: 'View',
      year: '2020',
      icon: Icons.hardware_outlined,
      specs: [],
    ),
    Machine(
      title: 'Okuma Genos M560',
      subtitle: 'Vertical Machining Center',
      badge: 'VERIFIED',
      note: '',
      ctaLabel: 'View',
      year: '2017',
      icon: Icons.build_circle_outlined,
      specs: [],
    ),
  ];

  static const List<(IconData, String)> categories = [
    (Icons.view_week_outlined, 'CNC Machines'),
    (Icons.auto_awesome_mosaic_outlined, 'VMC Centers'),
    (Icons.rotate_90_degrees_ccw, 'Lathes'),
    (Icons.blur_circular, 'Grinders'),
    (Icons.electric_bolt_outlined, 'EDM'),
  ];
}
