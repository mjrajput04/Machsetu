import 'package:flutter/material.dart';

class MachineSpec {
  const MachineSpec({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class Machine {
  const Machine({
    required this.title,
    required this.brand,
    required this.subtitle,
    required this.category,
    required this.year,
    required this.price,
    required this.location,
    required this.condition,
    required this.hours,
    required this.origin,
    required this.badge,
    required this.note,
    required this.ctaLabel,
    required this.specs,
    required this.images,
    required this.machineDetails,
    required this.specifications,
    required this.overview,
    required this.features,
    this.icon = Icons.precision_manufacturing,
  });

  final String title;

  /// Manufacturer, e.g. "DMG MORI".
  final String brand;

  /// Machine type, e.g. "5-Axis Universal Machining Center".
  final String subtitle;

  /// One of [MachineData.categories], excluding "All".
  final String category;
  final String year;

  /// Asking price, pre-formatted in the Indian lakh/crore grouping.
  final String price;
  final String location;
  final String condition;

  /// Spindle hours on the clock.
  final String hours;

  /// Country of manufacture.
  final String origin;

  /// Corner ribbon on the featured card.
  final String badge;

  /// Small qualifier under the price — "EXCL. SHIPPING", …
  final String note;
  final String ctaLabel;

  /// Three headline figures shown on the featured card strip.
  final List<MachineSpec> specs;

  /// Photos — the first is the card thumbnail and the detail-page hero.
  final List<String> images;

  /// Registration-form section 2 rows for the detail page.
  final List<(String, String)> machineDetails;

  /// Registration-form section 4 rows for the detail page.
  final List<(String, String)> specifications;

  /// Prose paragraphs for the Overview block.
  final List<String> overview;

  /// Capability chips.
  final List<String> features;
  final IconData icon;

  String? get image => images.isEmpty ? null : images.first;
}

/// Static catalogue used until the listings API is connected.
///
/// Specifications are representative of each model as published by the
/// manufacturer; verify against the machine's own plate before quoting.
class MachineData {
  MachineData._();

  static const String _p = 'assets/images/machines';

  /// "All" is a filter, not a category a machine can belong to.
  static const String allCategory = 'All';

  static const List<(IconData, String)> categories = [
    (Icons.grid_view_rounded, allCategory),
    (Icons.view_week_outlined, 'CNC Machines'),
    (Icons.auto_awesome_mosaic_outlined, 'VMC Centers'),
    (Icons.rotate_90_degrees_ccw, 'Lathes'),
    (Icons.blur_circular, 'Grinders'),
    (Icons.electric_bolt_outlined, 'EDM'),
  ];

  /// Wide workshop shot behind the home-page promo banner.
  static const String bannerPhoto = '$_p/workshop_banner.jpg';

  static List<Machine> forCategory(String category) {
    if (category == allCategory) return all;
    return all.where((m) => m.category == category).toList();
  }

  /// Newest six, for the "Recently Added" grid.
  static List<Machine> get recent {
    final sorted = [...all]..sort((a, b) => b.year.compareTo(a.year));
    return sorted.take(6).toList();
  }

  static const List<Machine> all = [
    // ------------------------------------------------------ CNC Machines
    Machine(
      title: 'DMG MORI DMU 50',
      brand: 'DMG MORI',
      subtitle: '5-Axis Universal Machining Center',
      category: 'CNC Machines',
      year: '2019',
      price: '₹1,45,00,000',
      location: 'Pune, MH',
      condition: 'Excellent',
      hours: '6,400',
      origin: 'Germany',
      badge: 'EXCELLENT CONDITION',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.precision_manufacturing,
      images: ['$_p/dmg_cmx_1100v.jpg', '$_p/workshop_banner.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'DMG MORI',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2019',
        ),
        MachineSpec(icon: Icons.speed_outlined, label: 'RPM', value: '20,000'),
      ],
      machineDetails: [
        ('Machine Type', '5-Axis Universal Machining Center'),
        ('Controller', 'Siemens 840D solutionline'),
        ('No. of Axis', '5 Axis (simultaneous)'),
        ('Travels X/Y/Z', '650 / 520 / 475 mm'),
        ('Table Diameter', 'Ø 630 mm swivel rotary'),
        ('Max Table Load', '300 kg'),
        ('Power Requirement', '3-Phase 415V, 30 kVA'),
        ('Weight of Machine', '5,200 kg'),
        ('Country of Origin', 'Germany'),
      ],
      specifications: [
        ('Spindle Speed', '20,000 rpm'),
        ('Spindle Taper', 'HSK-A63'),
        ('Tool Magazine Capacity', '30 tools'),
        ('Tool Changer Type', 'Chain magazine'),
        ('Rapid Traverse', '30 m/min'),
        ('Positioning Accuracy', '±0.005 mm'),
        ('Coolant System', 'Through spindle 40 bar'),
        ('Guideways', 'Linear roller guides'),
      ],
      overview: [
        'The DMU 50 is DMG MORI\'s workhorse 5-axis universal machining '
            'center, built around a swivel rotary table that lets you finish '
            'complex parts in a single setup.',
        'This unit has been in a temperature-controlled toolroom since new, '
            'runs Siemens 840D, and comes with the through-spindle coolant '
            'package and full documentation.',
      ],
      features: [
        '5-Axis Simultaneous',
        'Through Spindle Coolant',
        'HSK-A63',
        'Chip Conveyor',
      ],
    ),
    Machine(
      title: 'Mazak INTEGREX i-200ST',
      brand: 'Yamazaki Mazak',
      subtitle: 'Multi-Tasking Turning Center',
      category: 'CNC Machines',
      year: '2018',
      price: '₹2,10,00,000',
      location: 'Bengaluru, KA',
      condition: 'Good',
      hours: '11,800',
      origin: 'Japan',
      badge: 'CERTIFIED',
      note: 'INSTALL INCLUDED',
      ctaLabel: 'View Configuration Sheet',
      icon: Icons.settings_suggest_outlined,
      images: ['$_p/integrex_i200.jpg', '$_p/okuma_genos.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'MAZAK',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2018',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'SWING',
          value: '658mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Multi-Tasking Turning Center'),
        ('Controller', 'Mazatrol Matrix 2'),
        ('No. of Axis', '6 Axis (X/Y/Z/B/C1/C2)'),
        ('Max Turning Diameter', 'Ø 658 mm'),
        ('Max Turning Length', '1,011 mm'),
        ('Bar Capacity', 'Ø 65 mm'),
        ('Power Requirement', '3-Phase 415V, 45 kVA'),
        ('Weight of Machine', '9,800 kg'),
        ('Country of Origin', 'Japan'),
      ],
      specifications: [
        ('Turning Spindle Speed', '5,000 rpm'),
        ('Milling Spindle Speed', '12,000 rpm'),
        ('Milling Spindle Taper', 'CAPTO C6'),
        ('Tool Magazine Capacity', '36 tools'),
        ('Y-Axis Travel', '±105 mm'),
        ('Sub Spindle', 'Yes, synchronised'),
        ('Coolant System', 'High pressure 70 bar'),
        ('Chip Conveyor', 'Hinged belt'),
      ],
      overview: [
        'The INTEGREX i-200ST combines full turning capability with a B-axis '
            'milling spindle and a second turning spindle, so shafts and '
            'complex prismatic parts come off complete.',
        'Ideal for job shops moving from multi-operation routing to done-in-'
            'one manufacturing. Under AMC until 2027.',
      ],
      features: [
        'Done-In-One',
        'Y-Axis',
        'Sub Spindle',
        'Bar Feeder Ready',
      ],
    ),
    Machine(
      title: 'Mazak HCN-4000',
      brand: 'Yamazaki Mazak',
      subtitle: 'Horizontal Machining Center',
      category: 'CNC Machines',
      year: '2017',
      price: '₹1,05,00,000',
      location: 'Chennai, TN',
      condition: 'Good',
      hours: '14,200',
      origin: 'Japan',
      badge: 'VERIFIED',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.view_week_outlined,
      images: ['$_p/hmc_horizontal.jpg', '$_p/dmg_mori_nhx.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'MAZAK',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2017',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'PALLET',
          value: '400mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Horizontal Machining Center'),
        ('Controller', 'Mazatrol SmoothG'),
        ('No. of Axis', '4 Axis (X/Y/Z/B)'),
        ('Pallet Size', '400 x 400 mm'),
        ('Travels X/Y/Z', '560 / 640 / 640 mm'),
        ('Number of Pallets', '2 (APC)'),
        ('Max Pallet Load', '400 kg'),
        ('Weight of Machine', '11,500 kg'),
        ('Country of Origin', 'Japan'),
      ],
      specifications: [
        ('Spindle Speed', '12,000 rpm'),
        ('Spindle Taper', 'CAT 40'),
        ('Tool Magazine Capacity', '40 tools'),
        ('Tool Changer Type', 'Chain, random access'),
        ('B-Axis Indexing', '1° / optional 0.001°'),
        ('Rapid Traverse', '50 m/min'),
        ('Coolant System', 'Through spindle 20 bar'),
        ('Chip Conveyor', 'Screw + hinged belt'),
      ],
      overview: [
        'A twin-pallet horizontal machining center built for unattended '
            'production runs — load one pallet while the other cuts.',
        'This example has run a single-part family since installation and has '
            'complete AMC history from the Mazak service centre in Chennai.',
      ],
      features: [
        'Twin Pallet Changer',
        'Through Spindle Coolant',
        'Rigid Tapping',
        'Tool Breakage Detection',
      ],
    ),

    // ------------------------------------------------------- VMC Centers
    Machine(
      title: 'Haas VF-2SS',
      brand: 'Haas Automation',
      subtitle: 'Super-Speed Vertical Machining Center',
      category: 'VMC Centers',
      year: '2021',
      price: '₹70,50,000',
      location: 'Rajkot, GJ',
      condition: 'Excellent',
      hours: '4,200',
      origin: 'USA',
      badge: 'EXCELLENT CONDITION',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.precision_manufacturing,
      images: ['$_p/haas_vf2ss.jpg', '$_p/haas_vf2.jpg'],
      specs: [
        MachineSpec(icon: Icons.factory_outlined, label: 'BRAND', value: 'HAAS'),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2021',
        ),
        MachineSpec(icon: Icons.speed_outlined, label: 'RPM', value: '12,000'),
      ],
      machineDetails: [
        ('Machine Type', 'Vertical Machining Center'),
        ('Controller', 'Haas Next Generation Control'),
        ('No. of Axis', '3 Axis'),
        ('Travels X/Y/Z', '762 / 406 / 508 mm'),
        ('Table Size', '914 x 356 mm'),
        ('Max Table Load', '1,361 kg'),
        ('Power Requirement', '3-Phase 415V, 22.4 kVA'),
        ('Weight of Machine', '3,175 kg'),
        ('Country of Origin', 'USA'),
      ],
      specifications: [
        ('Spindle Speed', '12,000 rpm'),
        ('Spindle Taper', 'CT 40'),
        ('Spindle Power', '22.4 kW'),
        ('Tool Magazine Capacity', '24+1 side mount'),
        ('Tool Change Time', '2.8 s (tool to tool)'),
        ('Rapid Traverse', '35.5 m/min'),
        ('Coolant System', 'Through spindle 300 psi'),
        ('Guideways', 'Linear guideways'),
      ],
      overview: [
        'The VF-2SS is the super-speed variant of Haas\'s best-selling VMC — '
            'a 12,000 rpm inline direct-drive spindle and 35.5 m/min rapids '
            'make it a strong fit for high-mix aluminium work.',
        'Spindle replaced under warranty in 2024. Regular maintenance logged; '
            'minor cosmetic scratches on the front door panel.',
      ],
      features: [
        'Through Spindle Coolant',
        'Programmable Coolant',
        'Rigid Tapping',
        'High-Speed Machining',
      ],
    ),
    Machine(
      title: 'Okuma GENOS M560-V',
      brand: 'Okuma',
      subtitle: 'Vertical Machining Center',
      category: 'VMC Centers',
      year: '2019',
      price: '₹92,00,000',
      location: 'Coimbatore, TN',
      condition: 'Excellent',
      hours: '7,100',
      origin: 'Japan',
      badge: 'CERTIFIED',
      note: 'INSTALL INCLUDED',
      ctaLabel: 'View Configuration Sheet',
      icon: Icons.build_circle_outlined,
      images: ['$_p/okuma_genos.jpg', '$_p/vmc_machining_center.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'OKUMA',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2019',
        ),
        MachineSpec(icon: Icons.speed_outlined, label: 'RPM', value: '15,000'),
      ],
      machineDetails: [
        ('Machine Type', 'Vertical Machining Center'),
        ('Controller', 'Okuma OSP-P300MA'),
        ('No. of Axis', '3 Axis'),
        ('Travels X/Y/Z', '1,050 / 560 / 460 mm'),
        ('Table Size', '1,300 x 550 mm'),
        ('Max Table Load', '1,000 kg'),
        ('Power Requirement', '3-Phase 415V, 30 kVA'),
        ('Weight of Machine', '6,500 kg'),
        ('Country of Origin', 'Japan'),
      ],
      specifications: [
        ('Spindle Speed', '15,000 rpm'),
        ('Spindle Taper', 'CAT 40'),
        ('Spindle Power', '22 kW'),
        ('Tool Magazine Capacity', '32 tools'),
        ('Rapid Traverse', '40 m/min'),
        ('Thermo-Friendly Concept', 'Fitted'),
        ('Coolant System', 'Flood + through spindle'),
        ('Guideways', 'Box ways (Y/Z)'),
      ],
      overview: [
        'Okuma\'s GENOS M560-V pairs a rigid box-way structure with the '
            'OSP-P300 control and Thermo-Friendly Concept, holding dimensional '
            'stability through long unattended runs.',
        'Bought new by a tier-1 automotive supplier and maintained on a '
            'quarterly AMC. Original tooling and manuals included.',
      ],
      features: [
        'Thermo-Friendly Concept',
        'Collision Avoidance',
        'Through Spindle Coolant',
        'Box Ways',
      ],
    ),
    Machine(
      title: 'Doosan DNM 5700',
      brand: 'Doosan Machine Tools',
      subtitle: 'Vertical Machining Center',
      category: 'VMC Centers',
      year: '2020',
      price: '₹78,00,000',
      location: 'Ahmedabad, GJ',
      condition: 'Good',
      hours: '9,300',
      origin: 'South Korea',
      badge: 'VERIFIED',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.auto_awesome_mosaic_outlined,
      images: ['$_p/vmc_machining_center.jpg', '$_p/haas_vf2.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'DOOSAN',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2020',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'TRAVEL',
          value: '1300mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Vertical Machining Center'),
        ('Controller', 'Fanuc 0i-MF Plus'),
        ('No. of Axis', '3 Axis'),
        ('Travels X/Y/Z', '1,300 / 570 / 625 mm'),
        ('Table Size', '1,500 x 570 mm'),
        ('Max Table Load', '1,300 kg'),
        ('Power Requirement', '3-Phase 415V, 26 kVA'),
        ('Weight of Machine', '7,300 kg'),
        ('Country of Origin', 'South Korea'),
      ],
      specifications: [
        ('Spindle Speed', '12,000 rpm'),
        ('Spindle Taper', 'BT 40'),
        ('Spindle Power', '18.5 kW'),
        ('Tool Magazine Capacity', '30 tools'),
        ('Rapid Traverse', '36 m/min'),
        ('Positioning Accuracy', '±0.005 mm'),
        ('Coolant System', 'Flood, 20 bar'),
        ('Guideways', 'Roller guideways'),
      ],
      overview: [
        'A large-envelope VMC that suits die work and long plates — 1,300 mm '
            'of X travel with a 1,300 kg table capacity.',
        'Single owner, used on two shifts in a general engineering shop. '
            'Ball screws and guideways checked clear at the last audit.',
      ],
      features: [
        'Rigid Tapping',
        'Programmable Coolant',
        'Chip Conveyor',
        'Spindle Chiller',
      ],
    ),

    // ------------------------------------------------------------ Lathes
    Machine(
      title: 'Mazak QUICK TURN 250MY',
      brand: 'Yamazaki Mazak',
      subtitle: 'CNC Turning Center',
      category: 'Lathes',
      year: '2018',
      price: '₹62,00,000',
      location: 'Pune, MH',
      condition: 'Good',
      hours: '12,600',
      origin: 'Japan',
      badge: 'VERIFIED',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.rotate_right,
      images: ['$_p/mazak_quick_turn.jpg', '$_p/lathe_wasino.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'MAZAK',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2018',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'SWING',
          value: '350mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'CNC Turning Center'),
        ('Controller', 'Mazatrol SmoothG'),
        ('No. of Axis', '4 Axis (X/Y/Z/C)'),
        ('Max Turning Diameter', 'Ø 350 mm'),
        ('Max Turning Length', '1,011 mm'),
        ('Chuck Size', '10 inch'),
        ('Bar Capacity', 'Ø 80 mm'),
        ('Weight of Machine', '5,900 kg'),
        ('Country of Origin', 'Japan'),
      ],
      specifications: [
        ('Spindle Speed', '4,000 rpm'),
        ('Spindle Power', '22 kW'),
        ('Turret Stations', '12 (all driven)'),
        ('Y-Axis Travel', '±50 mm'),
        ('Tailstock', 'Programmable'),
        ('Rapid Traverse', '30 m/min'),
        ('Coolant System', 'Flood + through tool'),
        ('Chip Conveyor', 'Hinged belt'),
      ],
      overview: [
        'The QUICK TURN 250MY adds Y-axis and driven tooling to Mazak\'s '
            'proven turning platform, so milled flats and cross-holes finish '
            'without a second operation.',
        'Used on hydraulic component work. Turret and tailstock serviced in '
            '2025; spindle bearings original and running within spec.',
      ],
      features: [
        'Driven Tooling',
        'Y-Axis',
        'Programmable Tailstock',
        'Parts Catcher',
      ],
    ),
    Machine(
      title: 'Doosan PUMA 2600SY',
      brand: 'Doosan Machine Tools',
      subtitle: 'CNC Turning Center',
      category: 'Lathes',
      year: '2019',
      price: '₹55,00,000',
      location: 'Chennai, TN',
      condition: 'Good',
      hours: '15,400',
      origin: 'South Korea',
      badge: 'VERIFIED',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.hardware_outlined,
      images: ['$_p/lathe_moriseiki.jpg', '$_p/doosan_lynx.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'DOOSAN',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2019',
        ),
        MachineSpec(icon: Icons.straighten, label: 'CHUCK', value: '10"'),
      ],
      machineDetails: [
        ('Machine Type', 'CNC Turning Center'),
        ('Controller', 'Fanuc i Series'),
        ('No. of Axis', '5 Axis (X/Y/Z/C + sub)'),
        ('Max Turning Diameter', 'Ø 400 mm'),
        ('Max Turning Length', '780 mm'),
        ('Chuck Size', '10 inch'),
        ('Bar Capacity', 'Ø 80 mm'),
        ('Weight of Machine', '6,200 kg'),
        ('Country of Origin', 'South Korea'),
      ],
      specifications: [
        ('Main Spindle Speed', '3,500 rpm'),
        ('Sub Spindle Speed', '5,000 rpm'),
        ('Spindle Power', '18.5 kW'),
        ('Turret Stations', '12 (driven)'),
        ('Y-Axis Travel', '±52.5 mm'),
        ('Sub Spindle', 'Yes, servo driven'),
        ('Coolant System', 'Flood, 15 bar'),
        ('Chip Conveyor', 'Hinged belt'),
      ],
      overview: [
        'A sub-spindle, Y-axis turning center for complete machining of small '
            'to medium shafts and chucked parts in one clamping.',
        'Ran a single automotive part family on three shifts. Fully documented '
            'AMC history and a recent geometric accuracy report.',
      ],
      features: ['Sub Spindle', 'Y-Axis', 'Driven Tooling', 'Parts Catcher'],
    ),
    Machine(
      title: 'Haas ST-20Y',
      brand: 'Haas Automation',
      subtitle: 'CNC Lathe with Y-Axis',
      category: 'Lathes',
      year: '2021',
      price: '₹48,50,000',
      location: 'Ludhiana, PB',
      condition: 'Excellent',
      hours: '3,800',
      origin: 'USA',
      badge: 'EXCELLENT CONDITION',
      note: 'INSTALL INCLUDED',
      ctaLabel: 'View Configuration Sheet',
      icon: Icons.rotate_90_degrees_ccw,
      images: ['$_p/lathe_wasino.jpg', '$_p/mazak_quick_turn.jpg'],
      specs: [
        MachineSpec(icon: Icons.factory_outlined, label: 'BRAND', value: 'HAAS'),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2021',
        ),
        MachineSpec(icon: Icons.speed_outlined, label: 'RPM', value: '4,000'),
      ],
      machineDetails: [
        ('Machine Type', 'CNC Turning Center'),
        ('Controller', 'Haas Next Generation Control'),
        ('No. of Axis', '4 Axis (X/Y/Z/C)'),
        ('Max Cutting Diameter', 'Ø 267 mm'),
        ('Max Cutting Length', '584 mm'),
        ('Chuck Size', '8.3 inch'),
        ('Bar Capacity', 'Ø 51 mm'),
        ('Weight of Machine', '3,765 kg'),
        ('Country of Origin', 'USA'),
      ],
      specifications: [
        ('Spindle Speed', '4,000 rpm'),
        ('Spindle Power', '14.9 kW'),
        ('Turret Stations', '12 (BOT, live tooling)'),
        ('Y-Axis Travel', '±50.8 mm'),
        ('Tailstock', 'Servo controlled'),
        ('Rapid Traverse', '24 m/min'),
        ('Coolant System', 'Flood, high pressure ready'),
        ('Chip Conveyor', 'Auger'),
      ],
      overview: [
        'A compact Y-axis turning center with live tooling — well suited to '
            'short-run precision work where a second op would otherwise be '
            'needed.',
        'Barely three years old with under 4,000 spindle hours. Still on the '
            'original Haas service contract, transferable to the buyer.',
      ],
      features: ['Live Tooling', 'Y-Axis', 'Servo Tailstock', 'Chip Auger'],
    ),

    // ---------------------------------------------------------- Grinders
    Machine(
      title: 'Studer S33',
      brand: 'Fritz Studer AG',
      subtitle: 'Universal Cylindrical Grinder',
      category: 'Grinders',
      year: '2017',
      price: '₹88,00,000',
      location: 'Pune, MH',
      condition: 'Excellent',
      hours: '8,900',
      origin: 'Switzerland',
      badge: 'CERTIFIED',
      note: 'INSTALL INCLUDED',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.blur_circular,
      images: ['$_p/grinder_cylindrical.jpg', '$_p/workshop_banner.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'STUDER',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2017',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'CENTRES',
          value: '1000mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Universal Cylindrical Grinder'),
        ('Controller', 'Fanuc 31i-B with StuderWIN'),
        ('No. of Axis', '3 Axis (X/Z/B)'),
        ('Distance Between Centres', '1,000 mm'),
        ('Centre Height', '175 mm'),
        ('Max Workpiece Weight', '150 kg'),
        ('Power Requirement', '3-Phase 415V, 20 kVA'),
        ('Weight of Machine', '4,600 kg'),
        ('Country of Origin', 'Switzerland'),
      ],
      specifications: [
        ('Grinding Wheel Size', '500 x 63 x 203 mm'),
        ('Wheelhead Swivel (B-Axis)', '±30°, 0.0001° resolution'),
        ('Workhead Speed', '5 – 1,000 rpm'),
        ('In-Process Gauging', 'Marposs fitted'),
        ('Dressing', 'Diamond roll, CNC'),
        ('Roundness Achievable', '0.0005 mm'),
        ('Coolant System', 'Paper band filtration'),
        ('Guideways', 'StuderGuide with linear drive'),
      ],
      overview: [
        'The S33 is Studer\'s universal cylindrical grinder for medium-sized '
            'workpieces — external, internal and face grinding on a single '
            'B-axis platform.',
        'Housed in a climate-controlled grinding room since installation. '
            'Marposs in-process gauging and a full set of wheel adapters are '
            'included in the sale.',
      ],
      features: [
        'B-Axis Wheelhead',
        'In-Process Gauging',
        'CNC Dressing',
        'Internal Grinding Attachment',
      ],
    ),
    Machine(
      title: 'Okamoto ACC-1224DX',
      brand: 'Okamoto',
      subtitle: 'Precision Surface Grinder',
      category: 'Grinders',
      year: '2019',
      price: '₹32,00,000',
      location: 'Rajkot, GJ',
      condition: 'Good',
      hours: '6,700',
      origin: 'Japan',
      badge: 'VERIFIED',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.layers_outlined,
      images: ['$_p/grinder_surface.jpg', '$_p/workshop_banner.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'OKAMOTO',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2019',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'TABLE',
          value: '300x600',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Precision Surface Grinder'),
        ('Controller', 'Okamoto digital, 3-axis auto'),
        ('No. of Axis', '3 Axis (X/Y/Z auto)'),
        ('Table Working Surface', '300 x 600 mm'),
        ('Max Grinding Height', '450 mm'),
        ('Magnetic Chuck', '300 x 600 mm electromagnetic'),
        ('Power Requirement', '3-Phase 415V, 11 kVA'),
        ('Weight of Machine', '2,300 kg'),
        ('Country of Origin', 'Japan'),
      ],
      specifications: [
        ('Grinding Wheel Size', '355 x 38 x 127 mm'),
        ('Spindle Speed', '1,800 rpm'),
        ('Spindle Power', '3.7 kW'),
        ('Table Speed', '5 – 25 m/min hydraulic'),
        ('Cross Feed Increment', '0.5 – 30 mm'),
        ('Down Feed Increment', '0.001 mm'),
        ('Coolant System', 'Magnetic separator + paper filter'),
        ('Guideways', 'Hardened and ground V-flat'),
      ],
      overview: [
        'A workhorse hydraulic surface grinder with automatic three-axis '
            'operation, widely used in Indian tool rooms for die plates and '
            'precision flats.',
        'Comes with the original electromagnetic chuck, coolant system with '
            'magnetic separator, and a spare wheel set.',
      ],
      features: [
        'Auto 3-Axis',
        'Electromagnetic Chuck',
        'Magnetic Separator',
        'Auto Down Feed',
      ],
    ),
    Machine(
      title: 'Ghiringhelli M200 SP',
      brand: 'Ghiringhelli',
      subtitle: 'Centreless Grinding Machine',
      category: 'Grinders',
      year: '2016',
      price: '₹41,00,000',
      location: 'Bengaluru, KA',
      condition: 'Good',
      hours: '13,100',
      origin: 'Italy',
      badge: 'VERIFIED',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'View Configuration Sheet',
      icon: Icons.donut_large_outlined,
      images: ['$_p/grinder_centerless.jpg', '$_p/workshop_banner.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'GHIRINGHELLI',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2016',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'CAPACITY',
          value: 'Ø100mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Centreless Grinding Machine'),
        ('Controller', 'Siemens PLC with touch HMI'),
        ('No. of Axis', '2 CNC Axis'),
        ('Grinding Diameter Range', 'Ø 0.5 – 100 mm'),
        ('Max Infeed Width', '200 mm'),
        ('Through-Feed Capability', 'Yes'),
        ('Power Requirement', '3-Phase 415V, 25 kVA'),
        ('Weight of Machine', '4,100 kg'),
        ('Country of Origin', 'Italy'),
      ],
      specifications: [
        ('Grinding Wheel Size', '500 x 200 x 304.8 mm'),
        ('Regulating Wheel Size', '250 x 200 mm'),
        ('Grinding Wheel Speed', '1,450 rpm'),
        ('Regulating Wheel Speed', '10 – 300 rpm'),
        ('Dressing', 'CNC diamond, both wheels'),
        ('Roundness Achievable', '0.001 mm'),
        ('Coolant System', 'Tank with paper band filter'),
        ('Guideways', 'Hardened slideways'),
      ],
      overview: [
        'A through-feed and in-feed centreless grinder built for high-volume '
            'pin, shaft and bearing-race work.',
        'Rebuilt wheel spindle in 2024 with documentation. Sold with work '
            'rests, blades and the original dressing attachments.',
      ],
      features: [
        'Through-Feed',
        'In-Feed',
        'CNC Dressing',
        'Paper Band Filtration',
      ],
    ),

    // --------------------------------------------------------------- EDM
    Machine(
      title: 'Sodick AG400L',
      brand: 'Sodick',
      subtitle: 'Wire Cut EDM',
      category: 'EDM',
      year: '2019',
      price: '₹58,00,000',
      location: 'Chennai, TN',
      condition: 'Excellent',
      hours: '5,600',
      origin: 'Japan',
      badge: 'CERTIFIED',
      note: 'INSTALL INCLUDED',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.electric_bolt_outlined,
      images: ['$_p/wire_edm_ona.jpg', '$_p/wire_edm_robofil.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'SODICK',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2019',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'TRAVEL',
          value: '400mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Wire Cut EDM'),
        ('Controller', 'Sodick LN2W'),
        ('No. of Axis', '5 Axis (X/Y/Z/U/V)'),
        ('Travels X/Y/Z', '400 / 300 / 250 mm'),
        ('U/V Travel', '±80 mm'),
        ('Max Workpiece Size', '810 x 700 x 250 mm'),
        ('Max Workpiece Weight', '500 kg'),
        ('Weight of Machine', '3,400 kg'),
        ('Country of Origin', 'Japan'),
      ],
      specifications: [
        ('Drive System', 'Linear motor, all axes'),
        ('Max Taper Angle', '±15° / 80 mm'),
        ('Wire Diameter Range', '0.10 – 0.30 mm'),
        ('Auto Wire Threading', 'Yes, submerged'),
        ('Best Surface Finish', 'Ra 0.4 µm'),
        ('Positioning Accuracy', '±0.002 mm'),
        ('Dielectric', 'Deionised water, chiller'),
        ('Generator', 'Anti-electrolysis'),
      ],
      overview: [
        'Sodick\'s AG400L runs linear motor drives on every axis, so there '
            'are no ball screws to wear and long-term positioning accuracy '
            'holds without backlash compensation.',
        'Used for carbide punch and die work in a tool room. Includes the '
            'water chiller, filter housing and a stock of consumables.',
      ],
      features: [
        'Linear Motor Drives',
        'Auto Wire Threading',
        'Anti-Electrolysis',
        'Submerged Cutting',
      ],
    ),
    Machine(
      title: 'Mitsubishi MV1200R',
      brand: 'Mitsubishi Electric',
      subtitle: 'Wire Cut EDM',
      category: 'EDM',
      year: '2020',
      price: '₹64,00,000',
      location: 'Pune, MH',
      condition: 'Excellent',
      hours: '4,100',
      origin: 'Japan',
      badge: 'EXCELLENT CONDITION',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'View Configuration Sheet',
      icon: Icons.bolt_outlined,
      images: ['$_p/wire_edm_robofil.jpg', '$_p/wire_edm_ona.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'MITSUBISHI',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2020',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'TRAVEL',
          value: '400mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Wire Cut EDM'),
        ('Controller', 'Mitsubishi M800 series'),
        ('No. of Axis', '5 Axis (X/Y/Z/U/V)'),
        ('Travels X/Y/Z', '400 / 300 / 220 mm'),
        ('U/V Travel', '±80 mm'),
        ('Max Workpiece Size', '1,050 x 820 x 215 mm'),
        ('Max Workpiece Weight', '500 kg'),
        ('Weight of Machine', '2,900 kg'),
        ('Country of Origin', 'Japan'),
      ],
      specifications: [
        ('Drive System', 'Cylindrical AC servo'),
        ('Max Taper Angle', '±15° / 100 mm'),
        ('Wire Diameter Range', '0.10 – 0.30 mm'),
        ('Auto Wire Threading', 'Yes, annealed cut'),
        ('Best Surface Finish', 'Ra 0.32 µm'),
        ('Positioning Accuracy', '±0.002 mm'),
        ('Dielectric', 'Deionised water with chiller'),
        ('Power Supply', 'Digital-FS anti-electrolysis'),
      ],
      overview: [
        'The MV1200R is Mitsubishi\'s R-series wire EDM with a cylindrical '
            'drive system and tubular ceramic construction that resists '
            'thermal drift during long unattended cuts.',
        'Low-hour machine from a precision mould shop. Wire threading is '
            'reliable from cold; chiller serviced in 2026.',
      ],
      features: [
        'Auto Wire Threading',
        'Digital-FS Generator',
        'Optimum Power Control',
        'Anti-Electrolysis',
      ],
    ),
    Machine(
      title: 'Makino EDNC6',
      brand: 'Makino',
      subtitle: 'Sinker EDM / Small Hole Driller',
      category: 'EDM',
      year: '2018',
      price: '₹37,50,000',
      location: 'Ahmedabad, GJ',
      condition: 'Good',
      hours: '10,200',
      origin: 'Japan',
      badge: 'VERIFIED',
      note: 'EXCL. SHIPPING',
      ctaLabel: 'Request Technical Audit',
      icon: Icons.adjust_outlined,
      images: ['$_p/edm_small_hole.jpg', '$_p/wire_edm_ona.jpg'],
      specs: [
        MachineSpec(
          icon: Icons.factory_outlined,
          label: 'BRAND',
          value: 'MAKINO',
        ),
        MachineSpec(
          icon: Icons.calendar_today_outlined,
          label: 'YEAR',
          value: '2018',
        ),
        MachineSpec(
          icon: Icons.straighten,
          label: 'TRAVEL',
          value: '300mm',
        ),
      ],
      machineDetails: [
        ('Machine Type', 'Sinker EDM with small hole drilling'),
        ('Controller', 'Makino MGH'),
        ('No. of Axis', '3 Axis (X/Y/Z)'),
        ('Travels X/Y/Z', '300 / 250 / 250 mm'),
        ('Work Tank Size', '700 x 450 x 300 mm'),
        ('Max Electrode Weight', '50 kg'),
        ('Max Workpiece Weight', '550 kg'),
        ('Weight of Machine', '2,100 kg'),
        ('Country of Origin', 'Japan'),
      ],
      specifications: [
        ('Max Discharge Current', '40 A'),
        ('Electrode Materials', 'Copper, graphite'),
        ('Best Surface Finish', 'Ra 0.2 µm'),
        ('Hole Drilling Range', 'Ø 0.3 – 3.0 mm'),
        ('Dielectric', 'EDM oil with paper filter'),
        ('Positioning Accuracy', '±0.003 mm'),
        ('C-Axis', 'Optional, not fitted'),
        ('Fire Suppression', 'CO₂ system fitted'),
      ],
      overview: [
        'A compact sinker EDM used for cavity work and start holes, with the '
            'small-hole drilling head fitted for wire EDM pre-drilling.',
        'Steady toolroom use on single shifts. Dielectric system flushed and '
            'filters replaced before listing.',
      ],
      features: [
        'Small Hole Drilling',
        'Fire Suppression',
        'Paper Filtration',
        'Graphite Capable',
      ],
    ),
  ];
}
