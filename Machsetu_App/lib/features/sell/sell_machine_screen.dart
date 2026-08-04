import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'data/sell_store.dart';
import 'widgets/sell_widgets.dart';

/// Four-step listing wizard: Details → Images → Docs → Review.
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

  static const List<String> _categories = [
    'CNC Machines',
    'VMC Centers',
    'Lathes',
    'Grinding',
    'EDM',
    'Multi-Tasking',
    'Press & Forming',
  ];

  static const List<String> _conditions = [
    'Like New',
    'Excellent',
    'Good',
    'Fair',
    'Needs Repair',
  ];

  /// Bundled photos stand in for a real gallery picker.
  static const List<String> _samplePhotos = [
    'assets/images/machines/haas_vf2ss.jpg',
    'assets/images/machines/dmg_cmx_1100v.jpg',
    'assets/images/machines/okuma_genos.jpg',
    'assets/images/machines/mazak_quick_turn.jpg',
    'assets/images/machines/workshop_banner.jpg',
  ];

  static const List<(String, String, IconData)> _docTypes = [
    ('Original Invoice', 'Proof of purchase', Icons.receipt_long_outlined),
    ('Service History/AMC', 'Maintenance records', Icons.build_outlined),
    ('Technical Manuals', 'Operator documentation', Icons.menu_book_outlined),
    ('Warranty Papers', 'Active warranties', Icons.shield_outlined),
  ];

  final _draft = MachineDraft();
  final _scroll = ScrollController();

  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _hours = TextEditingController();
  final _price = TextEditingController();
  final _location = TextEditingController();
  final _serial = TextEditingController();
  final _description = TextEditingController();

  int _step = 0;
  bool _confirmed = false;
  bool _submitting = false;

  @override
  void dispose() {
    _scroll.dispose();
    for (final c in [
      _brand,
      _model,
      _year,
      _hours,
      _price,
      _location,
      _serial,
      _description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _sync() {
    _draft
      ..brand = _brand.text
      ..model = _model.text
      ..year = _year.text
      ..workingHours = _hours.text
      ..price = _price.text
      ..location = _location.text
      ..serialNumber = _serial.text
      ..description = _description.text;
  }

  void _goTo(int step) {
    _sync();
    FocusScope.of(context).unfocus();
    setState(() => _step = step.clamp(0, steps.length - 1));
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _addPhoto() {
    if (_draft.images.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can attach up to 10 photos')),
      );
      return;
    }
    setState(() {
      _draft.images.add(_samplePhotos[_draft.images.length % _samplePhotos.length]);
    });
  }

  void _addDocument(String category) {
    final index = _draft.documents.length + 1;
    final slug = category.split('/').first.replaceAll(' ', '_');
    setState(() {
      _draft.documents.add(
        SellDocument(
          name: '${slug}_$index.pdf',
          size: '${(index * 1.3 + 1).toStringAsFixed(1)} MB',
          category: category,
          uploadedOn: 'Just now',
        ),
      );
    });
  }

  Future<void> _submit() async {
    _sync();
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final listing = SellStore.instance.submit(_draft);
    setState(() => _submitting = false);

    await Navigator.of(context).pushReplacementNamed(
      AppRoutes.submissionStatus,
      arguments: listing,
    );
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
        'list it for buyers on the marketplace.',
        style: TextStyle(
          fontSize: 14,
          height: 1.55,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 18),
      SellCard(
        icon: Icons.precision_manufacturing_outlined,
        title: 'Machine Information',
        children: [
          SellDropdown(
            label: 'Machine Type',
            hint: 'Select category (e.g. CNC, VMC)',
            value: _draft.category.isEmpty ? null : _draft.category,
            options: _categories,
            onChanged: (value) =>
                setState(() => _draft.category = value ?? ''),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Brand / Make',
                  hint: 'e.g. Haas',
                  controller: _brand,
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Model',
                  hint: 'e.g. VF-2',
                  controller: _model,
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Year of Mfg.',
                  hint: 'YYYY',
                  controller: _year,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellDropdown(
                  label: 'Condition',
                  hint: 'Good',
                  value: _draft.condition,
                  options: _conditions,
                  onChanged: (value) =>
                      setState(() => _draft.condition = value ?? 'Good'),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SellField(
                  label: 'Working Hours',
                  hint: 'e.g. 5000',
                  controller: _hours,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SellField(
                  label: 'Expected Price (₹)',
                  hint: 'e.g. 1500000',
                  controller: _price,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          SellField(
            label: 'Current Location',
            hint: 'City, State',
            controller: _location,
            textCapitalization: TextCapitalization.words,
          ),
          SellField(
            label: 'Serial Number',
            hint: 'Machine SN',
            controller: _serial,
            textCapitalization: TextCapitalization.characters,
          ),
          SellField(
            label: 'Machine Description',
            hint: 'Provide details about specs, condition, included '
                'accessories, or known issues…',
            controller: _description,
            maxLines: 5,
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
        'Upload up to 10 clear images of the machine (Front, Side, Control '
        'Panel, Spindle, Serial Plate).',
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
    ];
  }

  // ---------------------------------------------------------------- step 3

  List<Widget> _docsStep() {
    return [
      const Text(
        'Upload Technical Documents',
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
        'expedites the valuation process.',
        style: TextStyle(
          fontSize: 13.5,
          height: 1.55,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 18),
      for (final type in _docTypes) ...[
        DocTypeCard(
          title: type.$1,
          subtitle: type.$2,
          icon: type.$3,
          attached: _draft.documents.where((d) => d.category == type.$1).length,
          onUpload: () => _addDocument(type.$1),
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
                  value: _draft.brand.isEmpty ? 'Not provided' : _draft.brand,
                ),
              ),
              Expanded(
                child: SummaryPair(
                  label: 'Model',
                  value: _draft.model.isEmpty ? 'Not provided' : _draft.model,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SummaryPair(
                  label: 'Year',
                  value: _draft.year.isEmpty ? 'Not provided' : _draft.year,
                ),
              ),
              Expanded(
                child: SummaryPair(
                  label: 'Category',
                  value: _draft.category.isEmpty
                      ? 'Not provided'
                      : _draft.category,
                  asChip: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          SummaryPair(
            label: 'Condition Notes',
            value: _draft.description.isEmpty
                ? 'No notes provided — our team will capture these during '
                      'verification.'
                : _draft.description,
            block: true,
          ),
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
                itemBuilder: (context, index) => ReviewThumb(
                  path: _draft.images[index],
                  isMain: index == 0,
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      SellCard(
        icon: Icons.description_outlined,
        title: 'Documents',
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
                            doc.size,
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
        title: 'Pricing Details',
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
        ],
      ),
      const SizedBox(height: 18),
      // The whole row toggles, not just the 24px box.
      GestureDetector(
        onTap: () => setState(() => _confirmed = !_confirmed),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
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
                  'I confirm the information provided is accurate, complete, '
                  'and I am the authorized seller of this equipment.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
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
