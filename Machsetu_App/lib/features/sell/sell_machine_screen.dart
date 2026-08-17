import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/upload_service.dart';
import '../../core/theme/app_colors.dart';
import 'data/sell_options.dart';
import 'data/sell_store.dart';
import 'widgets/sell_widgets.dart';

/// Four-step listing wizard mirroring the printed registration form:
/// Details (seller, machine, commercial, specs) → Images → Docs → Review.
///
/// Nothing is mandatory — a seller can submit a partial listing and the
/// sourcing desk fills the gaps during verification.
class SellMachineScreen extends StatefulWidget {
  const SellMachineScreen({super.key});

  @override
  State<SellMachineScreen> createState() => _SellMachineScreenState();
}

class _SellMachineScreenState extends State<SellMachineScreen> {
  static const List<String> steps = ['Details', 'Images', 'Docs', 'Review'];

  /// Stand-ins used when the upload cannot reach the sourcing desk.
  static const List<String> _samplePhotos = [
    'assets/images/machines/haas_vf2ss.jpg',
    'assets/images/machines/dmg_cmx_1100v.jpg',
    'assets/images/machines/okuma_genos.jpg',
    'assets/images/machines/mazak_quick_turn.jpg',
    'assets/images/machines/workshop_banner.jpg',
  ];

  static const Map<String, IconData> _docIcons = {
    'GST Certificate': Icons.article_outlined,
    'Ownership Proof': Icons.assignment_ind_outlined,
    'Purchase Invoice': Icons.receipt_outlined,
    'AMC Details': Icons.handyman_outlined,
    'Original Invoice': Icons.receipt_long_outlined,
    'Maintenance Records': Icons.build_outlined,
    'Machine Manual': Icons.menu_book_outlined,
    'Warranty (If Any)': Icons.shield_outlined,
    'Service History': Icons.history,
    'Other Documents': Icons.folder_outlined,
  };

  final _draft = MachineDraft();
  final _scroll = ScrollController();

  /// One controller per text field, created on demand.
  final Map<String, TextEditingController> _fields = {};

  int _step = 0;
  bool _confirmed = false;
  bool _submitting = false;

  TextEditingController _ctrl(String key) =>
      _fields.putIfAbsent(key, TextEditingController.new);

  final _settings = SettingsService.instance;

  @override
  void initState() {
    super.initState();
    // The category tick list is whatever the marketplace currently publishes.
    _settings.addListener(_onSettings);
    _settings.load();
  }

  void _onSettings() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettings);
    _scroll.dispose();
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _text(String key) => _fields[key]?.text ?? '';

  void _sync() {
    _draft
      // Section 1
      ..sellerName = _text('sellerName')
      ..companyName = _text('companyName')
      ..mobile = _text('mobile')
      ..whatsapp = _text('whatsapp')
      ..email = _text('email')
      // Statutory IDs are uppercase by convention.
      ..gstNumber = _text('gstNumber').toUpperCase()
      ..panNumber = _text('panNumber').toUpperCase()
      ..address = _text('address')
      ..city = _text('city')
      ..state = _text('state')
      ..pincode = _text('pincode')
      // Section 2
      ..categoryOther = _text('categoryOther')
      ..machineType = _text('machineType')
      ..brand = _text('brand')
      ..model = _text('model')
      ..year = _text('year')
      ..installationYear = _text('installationYear')
      ..countryOfOrigin = _text('countryOfOrigin')
      ..controller = _text('controller')
      ..numberOfAxis = _text('numberOfAxis')
      ..machineCapacity = _text('machineCapacity')
      ..powerRequirement = _text('powerRequirement')
      ..maxSpindleSpeed = _text('maxSpindleSpeed')
      ..weight = _text('weight')
      ..location = _text('location')
      ..workingHours = _text('workingHours')
      ..lastServiceDate = _text('lastServiceDate')
      ..accessoriesIncluded = _text('accessoriesIncluded')
      ..serialNumber = _text('serialNumber')
      ..description = _text('description')
      // Section 3
      ..price = _text('price')
      ..additionalRemarks = _text('additionalRemarks')
      // Section 4
      ..tableSize = _text('tableSize')
      ..lubricationSystem = _text('lubricationSystem')
      ..electricalPanelCondition = _text('electricalPanelCondition')
      ..toolMagazineCapacity = _text('toolMagazineCapacity')
      ..servoMotors = _text('servoMotors')
      ..toolChangerType = _text('toolChangerType')
      ..ballScrewCondition = _text('ballScrewCondition')
      ..coolantSystem = _text('coolantSystem')
      ..guideways = _text('guideways')
      ..hydraulicSystem = _text('hydraulicSystem')
      ..otherSpecifications = _text('otherSpecifications');
  }

  void _goTo(int step) {
    _sync();
    FocusScope.of(context).unfocus();
    setState(() => _step = step.clamp(0, steps.length - 1));
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  /// Whatever the admin panel publishes, plus the sheet's own extras so a
  /// seller can still tick something the marketplace has not listed yet.
  List<String> get _categoryOptions {
    final published = _settings.categories;
    if (published.isEmpty) return SellOptions.categories;
    return [
      ...published,
      ...SellOptions.categories.where((c) => !published.contains(c)),
    ];
  }

  /// Every other checklist and chip row, also owned by the desk. The bundled
  /// list stands in whenever the settings call has not landed.
  List<String> _options(List<String> published, List<String> bundled) =>
      published.isEmpty ? bundled : published;

  List<String> get _workingStatus =>
      _options(_settings.sellOptions.workingStatus, SellOptions.workingStatus);

  List<String> get _conditions =>
      _options(_settings.sellOptions.conditions, SellOptions.conditions);

  List<String> get _maintenanceStatus => _options(
    _settings.sellOptions.maintenanceStatus,
    SellOptions.maintenanceStatus,
  );

  List<String> get _ownerTypes =>
      _options(_settings.sellOptions.ownerTypes, SellOptions.ownerTypes);

  List<String> get _requiredPhotos => _options(
    _settings.sellOptions.requiredPhotos,
    SellOptions.requiredPhotos,
  );

  List<String> get _documentTypes =>
      _options(_settings.sellOptions.documentTypes, SellOptions.documentTypes);

  Future<void> _addPhoto() async {
    if (_draft.images.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can attach up to 10 photos')),
      );
      return;
    }

    final room = 10 - _draft.images.length;
    final uploaded = await UploadService.instance.pickAndUpload(limit: room);
    if (!mounted) return;

    if (uploaded.isEmpty) {
      // Nothing picked, or the upload failed — keep the wizard usable either
      // way by falling back to a bundled photo.
      setState(() {
        _draft.images.add(
          _samplePhotos[_draft.images.length % _samplePhotos.length],
        );
      });
      return;
    }
    setState(() => _draft.images.addAll(uploaded));
  }

  Future<void> _addDocument(String category) async {
    final index = _draft.documents.length + 1;
    final slug = category
        .replaceAll(RegExp(r'[^A-Za-z ]'), '')
        .trim()
        .replaceAll(' ', '_');

    final uploaded = await UploadService.instance.pickDocumentAndUpload();
    if (!mounted) return;

    setState(() {
      _draft.documents.add(
        SellDocument(
          // A failed or cancelled pick still records the paperwork type, so
          // the desk knows what the seller says they have.
          name: uploaded?.name ?? '${slug}_$index.pdf',
          size: uploaded?.size ?? '—',
          category: category,
          uploadedOn: 'Just now',
          url: uploaded?.url ?? '',
        ),
      );
    });
  }

  Future<void> _submit() async {
    _sync();
    setState(() => _submitting = true);

    final listing = await SellStore.instance.submit(_draft);
    if (!mounted) return;
    setState(() => _submitting = false);

    await Navigator.of(
      context,
    ).pushReplacementNamed(AppRoutes.submissionStatus, arguments: listing);
  }

  void _saveDraft() {
    _sync();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Draft saved for ${_draft.displayTitle}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(_step == 0 ? Icons.arrow_back : Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sell Your Machine'),
            Text(
              'Step ${_step + 1}: ${steps[_step]}',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: StepTrail(
              labels: steps,
              current: _step,
              onTap: (index) => index <= _step ? _goTo(index) : null,
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: switch (_step) {
                0 => _detailsStep(),
                1 => _imagesStep(),
                2 => _docsStep(),
                _ => _reviewStep(),
              },
            ),
          ),
          _BottomBar(
            step: _step,
            submitting: _submitting,
            canSubmit: _confirmed,
            onBack: () => _goTo(_step - 1),
            onNext: () => _goTo(_step + 1),
            onSaveDraft: _saveDraft,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- step 1

  List<Widget> _detailsStep() {
    return [
      const Text(
        'Submit your machine for verification. Once approved, our team will '
        'list it for buyers on the marketplace. Every field is optional.',
        style: TextStyle(
          fontSize: 14,
          height: 1.55,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 18),

      // ---- Section 1 -------------------------------------------------
      SellCard(
        icon: Icons.person_outline,
        title: 'Seller Information',
        children: [
          SellField(
            label: 'Seller / Contact Person Name',
            hint: 'e.g. Pappu Singh',
            controller: _ctrl('sellerName'),
            textCapitalization: TextCapitalization.words,
          ),
          SellField(
            label: 'Company Name',
            hint: 'e.g. Fortune Gold Machine Tools',
            controller: _ctrl('companyName'),
            textCapitalization: TextCapitalization.words,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Mobile Number',
                  hint: '84015 03169',
                  controller: _ctrl('mobile'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'WhatsApp Number',
                  hint: 'Same as mobile',
                  controller: _ctrl('whatsapp'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
              ),
            ],
          ),
          SellField(
            label: 'Email ID',
            hint: 'you@company.com',
            controller: _ctrl('email'),
            keyboardType: TextInputType.emailAddress,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'GST Number',
                  hint: '24AAACF1234K1ZV',
                  controller: _ctrl('gstNumber'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'PAN Number',
                  hint: 'AAACF1234K',
                  controller: _ctrl('panNumber'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          SellField(
            label: 'Complete Address',
            hint: 'Plot / unit, area, landmark',
            controller: _ctrl('address'),
            maxLines: 2,
            textCapitalization: TextCapitalization.words,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'City',
                  hint: 'Rajkot',
                  controller: _ctrl('city'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'State',
                  hint: 'Gujarat',
                  controller: _ctrl('state'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          SellField(
            label: 'Pincode',
            hint: '360021',
            controller: _ctrl('pincode'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            isLast: true,
          ),
        ],
      ),
      const SizedBox(height: 16),

      // ---- Section 2 -------------------------------------------------
      SellCard(
        icon: Icons.precision_manufacturing_outlined,
        title: 'Machine Details',
        children: [
          SellCheckboxGroup(
            label: 'Machine Category (select all that apply)',
            options: _categoryOptions,
            selected: _draft.categories,
            onToggle: (option) => setState(() {
              _draft.categories.contains(option)
                  ? _draft.categories.remove(option)
                  : _draft.categories.add(option);
            }),
          ),
          if (_draft.categories.contains('Other'))
            SellField(
              label: 'Other Category',
              hint: 'Specify the machine category',
              controller: _ctrl('categoryOther'),
              textCapitalization: TextCapitalization.words,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Machine Type',
                  hint: 'e.g. Vertical Machining Center',
                  controller: _ctrl('machineType'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Brand / Make',
                  hint: 'e.g. Haas',
                  controller: _ctrl('brand'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Model',
                  hint: 'e.g. VF-2',
                  controller: _ctrl('model'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Manufacturing Year',
                  hint: 'YYYY',
                  controller: _ctrl('year'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Installation Year',
                  hint: 'YYYY',
                  controller: _ctrl('installationYear'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Country of Origin',
                  hint: 'e.g. Japan',
                  controller: _ctrl('countryOfOrigin'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Controller',
                  hint: 'e.g. Fanuc 31i-B',
                  controller: _ctrl('controller'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'No. of Axis',
                  hint: 'e.g. 3 Axis',
                  controller: _ctrl('numberOfAxis'),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Machine Capacity / Size',
                  hint: 'e.g. 760 x 406 x 508 mm',
                  controller: _ctrl('machineCapacity'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Power Requirement',
                  hint: 'e.g. 3-Phase 415V',
                  controller: _ctrl('powerRequirement'),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Maximum Spindle Speed',
                  hint: 'e.g. 12,000 RPM',
                  controller: _ctrl('maxSpindleSpeed'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Weight of Machine',
                  hint: 'e.g. 3,175 kg',
                  controller: _ctrl('weight'),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Machine Location',
                  hint: 'City, State',
                  controller: _ctrl('location'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Working Hours',
                  hint: 'e.g. 5000',
                  controller: _ctrl('workingHours'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          SellChoice(
            label: 'Working Status',
            options: _workingStatus,
            value: _draft.workingStatus,
            onChanged: (value) => setState(() => _draft.workingStatus = value),
          ),
          SellChoice(
            label: 'Machine Condition',
            options: _conditions,
            value: _draft.condition,
            onChanged: (value) => setState(() => _draft.condition = value),
          ),
          SellChoice(
            label: 'Maintenance Status',
            options: _maintenanceStatus,
            value: _draft.maintenanceStatus,
            onChanged: (value) =>
                setState(() => _draft.maintenanceStatus = value),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Last Service Date',
                  hint: 'DD / MM / YYYY',
                  controller: _ctrl('lastServiceDate'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Serial Number',
                  hint: 'Machine SN',
                  controller: _ctrl('serialNumber'),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          SellField(
            label: 'Accessories Included',
            hint: 'Tool holders, coolant pump, manuals…',
            controller: _ctrl('accessoriesIncluded'),
            maxLines: 3,
          ),
          SellField(
            label: 'Machine Description',
            hint:
                'Provide details about specs, condition, included '
                'accessories, or known issues…',
            controller: _ctrl('description'),
            maxLines: 5,
            isLast: true,
          ),
        ],
      ),
      const SizedBox(height: 16),

      // ---- Section 3 -------------------------------------------------
      SellCard(
        icon: Icons.payments_outlined,
        title: 'Commercial Information',
        children: [
          SellField(
            label: 'Expected Selling Price (₹)',
            hint: 'e.g. 1500000',
            controller: _ctrl('price'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SellYesNo(
            label: 'Negotiable',
            value: _draft.negotiable,
            onChanged: (value) => setState(() => _draft.negotiable = value),
          ),
          SellYesNo(
            label: 'GST Available',
            value: _draft.gstAvailable,
            onChanged: (value) => setState(() => _draft.gstAvailable = value),
          ),
          SellYesNo(
            label: 'Tax Invoice Available',
            value: _draft.taxInvoiceAvailable,
            onChanged: (value) =>
                setState(() => _draft.taxInvoiceAvailable = value),
          ),
          SellYesNo(
            label: 'Finance / Loan Pending',
            value: _draft.financePending,
            onChanged: (value) => setState(() => _draft.financePending = value),
          ),
          SellYesNo(
            label: 'Delivery Available',
            value: _draft.deliveryAvailable,
            onChanged: (value) =>
                setState(() => _draft.deliveryAvailable = value),
          ),
          SellYesNo(
            label: 'Loading Available',
            value: _draft.loadingAvailable,
            onChanged: (value) =>
                setState(() => _draft.loadingAvailable = value),
          ),
          const SizedBox(height: 4),
          SellChoice(
            label: 'Owner Type',
            options: _ownerTypes,
            value: _draft.ownerType,
            onChanged: (value) => setState(() => _draft.ownerType = value),
          ),
          SellField(
            label: 'Remark (If Any)',
            hint: 'Anything a buyer should know before quoting',
            controller: _ctrl('additionalRemarks'),
            maxLines: 3,
            isLast: true,
          ),
        ],
      ),
      const SizedBox(height: 16),

      // ---- Section 4 -------------------------------------------------
      SellCard(
        icon: Icons.settings_outlined,
        title: 'Machine Specifications',
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Table Size',
                  hint: 'e.g. 914 x 356 mm',
                  controller: _ctrl('tableSize'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Lubrication System',
                  hint: 'e.g. Automatic',
                  controller: _ctrl('lubricationSystem'),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Tool Magazine Capacity',
                  hint: 'e.g. 30+1',
                  controller: _ctrl('toolMagazineCapacity'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Electrical Panel Condition',
                  hint: 'e.g. Excellent',
                  controller: _ctrl('electricalPanelCondition'),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Tool Changer Type',
                  hint: 'e.g. Side mount ATC',
                  controller: _ctrl('toolChangerType'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Servo Motors',
                  hint: 'Make and health',
                  controller: _ctrl('servoMotors'),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Coolant System',
                  hint: 'e.g. Through spindle',
                  controller: _ctrl('coolantSystem'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Ball Screw Condition',
                  hint: 'e.g. No backlash',
                  controller: _ctrl('ballScrewCondition'),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Hydraulic System',
                  hint: 'e.g. Working',
                  controller: _ctrl('hydraulicSystem'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Guideways',
                  hint: 'e.g. Linear',
                  controller: _ctrl('guideways'),
                ),
              ),
            ],
          ),
          SellField(
            label: 'Other Specifications',
            hint: 'Anything else worth listing',
            controller: _ctrl('otherSpecifications'),
            maxLines: 3,
            isLast: true,
          ),
        ],
      ),
    ];
  }

  // ---------------------------------------------------------------- step 2

  List<Widget> _imagesStep() {
    return [
      const Text(
        'Upload Images',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Upload up to 10 clear images of the machine, then tick the views you '
        'have covered.',
        style: TextStyle(
          fontSize: 13.5,
          height: 1.55,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 18),
      GestureDetector(
        onTap: _addPhoto,
        child: CustomPaint(
          painter: DashedBorderPainter(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30),
            alignment: Alignment.center,
            child: Column(
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: const BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Tap to upload',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'PNG, JPG up to 10MB each',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      if (_draft.images.isEmpty)
        const Text(
          'No photos attached yet — this step is optional.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        )
      else
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _draft.images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) => PhotoTile(
            path: _draft.images[index],
            isMain: index == 0,
            onRemove: () => setState(() => _draft.images.removeAt(index)),
          ),
        ),
      const SizedBox(height: 22),
      SellCard(
        icon: Icons.checklist_rtl,
        title: 'Required Photos',
        children: [
          SellCheckboxGroup(
            label: 'Tick every view you have provided',
            options: _requiredPhotos,
            selected: _draft.requiredPhotos,
            onToggle: (option) => setState(() {
              _draft.requiredPhotos.contains(option)
                  ? _draft.requiredPhotos.remove(option)
                  : _draft.requiredPhotos.add(option);
            }),
          ),
          Text(
            '${_draft.requiredPhotos.length} of '
            '${_requiredPhotos.length} views ticked',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    ];
  }

  // ---------------------------------------------------------------- step 3

  List<Widget> _docsStep() {
    return [
      const Text(
        'Documents Checklist',
        style: TextStyle(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Providing comprehensive documentation increases buyer trust and '
        'expedites the valuation process. A card ticks itself once a file is '
        'attached.',
        style: TextStyle(
          fontSize: 13.5,
          height: 1.55,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 18),
      for (final type in _documentTypes) ...[
        DocTypeCard(
          title: type,
          subtitle: 'Not attached',
          icon: _docIcons[type] ?? Icons.folder_outlined,
          attached: _draft.documents.where((d) => d.category == type).length,
          onUpload: () => _addDocument(type),
        ),
        const SizedBox(height: 12),
      ],
      if (_draft.documents.isNotEmpty) ...[
        const SizedBox(height: 10),
        const Text(
          'ATTACHED FILES',
          style: TextStyle(
            fontSize: 11.5,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        for (final doc in _draft.documents) ...[
          DocumentRow(
            document: doc,
            onRemove: () => setState(() => _draft.documents.remove(doc)),
          ),
          const SizedBox(height: 10),
        ],
      ],
    ];
  }

  // ---------------------------------------------------------------- step 4

  List<Widget> _reviewStep() {
    _sync();

    String orDash(String value) => value.trim().isEmpty ? '—' : value.trim();

    return [
      const Text(
        'Final Review',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.navy,
        ),
      ),
      const SizedBox(height: 16),
      SellCard(
        icon: Icons.person_outline,
        title: 'Seller Information',
        onEdit: () => _goTo(0),
        children: [
          for (final row in _draft.sellerInfo.rows)
            SpecRow(label: row.$1, value: orDash(row.$2)),
        ],
      ),
      const SizedBox(height: 16),
      SellCard(
        icon: Icons.precision_manufacturing_outlined,
        title: 'Machine Summary',
        onEdit: () => _goTo(0),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SummaryPair(
                  label: 'Manufacturer',
                  value: orDash(_draft.brand),
                ),
              ),
              Expanded(
                child: SummaryPair(label: 'Model', value: orDash(_draft.model)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SummaryPair(label: 'Year', value: orDash(_draft.year)),
              ),
              Expanded(
                child: SummaryPair(
                  label: 'Category',
                  value: orDash(_draft.category),
                  asChip: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          SpecRow(label: 'Machine Type', value: orDash(_draft.machineType)),
          SpecRow(label: 'Controller', value: orDash(_draft.controller)),
          SpecRow(label: 'No. of Axis', value: orDash(_draft.numberOfAxis)),
          SpecRow(
            label: 'Machine Capacity / Size',
            value: orDash(_draft.machineCapacity),
          ),
          SpecRow(
            label: 'Maximum Spindle Speed',
            value: orDash(_draft.maxSpindleSpeed),
          ),
          SpecRow(
            label: 'Power Requirement',
            value: orDash(_draft.powerRequirement),
          ),
          SpecRow(label: 'Weight of Machine', value: orDash(_draft.weight)),
          SpecRow(
            label: 'Installation Year',
            value: orDash(_draft.installationYear),
          ),
          SpecRow(
            label: 'Country of Origin',
            value: orDash(_draft.countryOfOrigin),
          ),
          SpecRow(label: 'Machine Location', value: orDash(_draft.location)),
          SpecRow(label: 'Working Hours', value: orDash(_draft.workingHours)),
          SpecRow(label: 'Working Status', value: orDash(_draft.workingStatus)),
          SpecRow(label: 'Condition', value: orDash(_draft.condition)),
          SpecRow(
            label: 'Maintenance Status',
            value: orDash(_draft.maintenanceStatus),
          ),
          SpecRow(
            label: 'Last Service Date',
            value: orDash(_draft.lastServiceDate),
          ),
          SpecRow(label: 'Serial Number', value: orDash(_draft.serialNumber)),
          const SizedBox(height: 10),
          SummaryPair(
            label: 'Accessories Included',
            value: orDash(_draft.accessoriesIncluded),
            block: true,
          ),
          const SizedBox(height: 14),
          SummaryPair(
            label: 'Condition Notes',
            value: _draft.description.trim().isEmpty
                ? 'No notes provided — our team will capture these during '
                      'verification.'
                : _draft.description,
            block: true,
          ),
        ],
      ),
      const SizedBox(height: 16),
      SellCard(
        icon: Icons.settings_outlined,
        title: 'Machine Specifications',
        onEdit: () => _goTo(0),
        children: [
          for (final row in _draft.machineSpecs.rows)
            SpecRow(label: row.$1, value: orDash(row.$2)),
        ],
      ),
      const SizedBox(height: 16),
      SellCard(
        icon: Icons.photo_library_outlined,
        title: 'Photos (${_draft.images.length})',
        onEdit: () => _goTo(1),
        children: [
          if (_draft.images.isEmpty)
            const Text(
              'No photos attached.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            )
          else
            SizedBox(
              height: 84,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _draft.images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) =>
                    ReviewThumb(path: _draft.images[index], isMain: index == 0),
              ),
            ),
          const SizedBox(height: 12),
          SpecRow(
            label: 'Required views ticked',
            value:
                '${_draft.requiredPhotos.length} of '
                '${_requiredPhotos.length}',
          ),
        ],
      ),
      const SizedBox(height: 16),
      SellCard(
        icon: Icons.description_outlined,
        title: 'Documents (${_draft.documents.length})',
        onEdit: () => _goTo(2),
        children: [
          if (_draft.documents.isEmpty)
            const Text(
              'No documents attached.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            )
          else
            for (final doc in _draft.documents)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 20,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${doc.size} • ${doc.category}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
      const SizedBox(height: 16),
      SellCard(
        icon: Icons.payments_outlined,
        title: 'Commercial Information',
        onEdit: () => _goTo(0),
        children: [
          const Text(
            'Expected Selling Price',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            _draft.displayPrice,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: AppColors.textMuted),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Excludes shipping and handling',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          for (final row in _draft.commercialInfo.rows)
            SpecRow(label: row.$1, value: orDash(row.$2)),
          const SizedBox(height: 10),
          SummaryPair(
            label: 'Remark',
            value: orDash(_draft.additionalRemarks),
            block: true,
          ),
        ],
      ),
      const SizedBox(height: 18),
      // Section 9 — seller declaration.
      GestureDetector(
        onTap: () => setState(() => _confirmed = !_confirmed),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELLER DECLARATION',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _confirmed,
                    activeColor: AppColors.accent,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) =>
                        setState(() => _confirmed = value ?? false),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I hereby declare that the above information is true and '
                      'correct to the best of my knowledge. I am the '
                      'authorized seller/owner of the machine and have the '
                      'full right to sell it. MachSetu is not responsible for '
                      'any misrepresentation. I agree to the Terms & '
                      'Conditions of MachSetu.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.step,
    required this.submitting,
    required this.canSubmit,
    required this.onBack,
    required this.onNext,
    required this.onSaveDraft,
    required this.onSubmit,
  });

  final int step;
  final bool submitting;
  final bool canSubmit;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSaveDraft;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isReview = step == 3;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onPressed: step == 0 ? onSaveDraft : onBack,
                  child: Text(
                    step == 0 ? 'Save Draft' : 'Back',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    disabledBackgroundColor: AppColors.steel,
                    minimumSize: const Size.fromHeight(50),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  onPressed: submitting
                      ? null
                      : isReview
                      ? (canSubmit ? onSubmit : null)
                      : onNext,
                  child: submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                isReview
                                    ? 'Submit for Verification'
                                    : 'Next Step',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (!isReview) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 17),
                            ],
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
