import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/vault_provider.dart';
import '../../models/payment_card.dart';
import '../../widgets/empty_state.dart';
import '../../config/theme.dart';
import '../../config/translations.dart';

class PaymentCardsScreen extends StatefulWidget {
  const PaymentCardsScreen({super.key});

  @override
  State<PaymentCardsScreen> createState() => _PaymentCardsScreenState();
}

class _PaymentCardsScreenState extends State<PaymentCardsScreen> {
  // Store card IDs whose details are revealed
  final Set<String> _revealedCardNumbers = {};
  final Set<String> _revealedCvvs = {};

  static const List<List<Color>> _cardGradients = [
    [Color(0xFF0F172A), Color(0xFF1E3A8A)], // Deep Navy
    [Color(0xFF064E3B), Color(0xFF059669)], // Emerald
    [Color(0xFF3B0764), Color(0xFF7C3AED)], // Violet
    [Color(0xFF18181B), Color(0xFF3F3F46)], // Obsidian
    [Color(0xFF78350F), Color(0xFFD97706)], // Gold / Amber
  ];

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cards = vaultProvider.cards;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr.cardsTitle, style: GoogleFonts.cairo()),
        leading: IconButton(
          icon: Icon(context.isArabic
              ? Icons.arrow_forward_ios_rounded
              : Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: FilledButton.tonalIcon(
              onPressed: () => _openCardDialog(context, null),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.tr.newCard, style: GoogleFonts.cairo(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: cards.isEmpty
          ? EmptyState(
              icon: Icons.credit_card_rounded,
              title: context.tr.emptyCardsTitle,
              subtitle: context.tr.emptyCardsSub,
              buttonText: context.tr.newCard,
              onButtonPressed: () => _openCardDialog(context, null),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return _buildCardWidget(context, vaultProvider, card, isDark);
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.cardsAccent,
        onPressed: () => _openCardDialog(context, null),
        child: const Icon(Icons.add_card_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildCardWidget(
    BuildContext context,
    VaultProvider provider,
    PaymentCard card,
    bool isDark,
  ) {
    final isNumberRevealed = _revealedCardNumbers.contains(card.id);
    final isCvvRevealed = _revealedCvvs.contains(card.id);
    final gradientColors = _cardGradients[card.colorIndex.clamp(0, _cardGradients.length - 1)];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative background circles
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -20,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Bank name & Card type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_rounded,
                                color: Colors.white70, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              card.bankName?.isNotEmpty == true
                                  ? card.bankName!
                                  : 'ROF Secure Card',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        // Card brand badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            card.cardType.toUpperCase(),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Chip & Contactless icons
                    Row(
                      children: [
                        // Chip
                        Container(
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 32,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF8B6508), width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Contactless wave
                        const Icon(Icons.wifi_rounded,
                            color: Colors.white70, size: 22),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Card Number with toggle reveal and copy
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isNumberRevealed
                                ? card.formattedCardNumber
                                : card.maskedCardNumber,
                            style: GoogleFonts.chivoMono(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                            textDirection: TextDirection.ltr,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isNumberRevealed
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              if (isNumberRevealed) {
                                _revealedCardNumbers.remove(card.id);
                              } else {
                                _revealedCardNumbers.add(card.id);
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded,
                              color: Colors.white70, size: 20),
                          tooltip: context.tr.copyCardNumber,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: card.cardNumber.replaceAll(' ', '')));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.tr.copiedToClipboard,
                                  style: GoogleFonts.cairo(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Cardholder & Expiry & CVV
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Cardholder
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr.cardHolderLabel.toUpperCase(),
                                style: GoogleFonts.cairo(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                card.cardHolderName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Expiry
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EXPIRY',
                                style: GoogleFonts.cairo(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                card.expiryDate,
                                style: GoogleFonts.chivoMono(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),

                        // CVV
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CVV',
                                style: GoogleFonts.cairo(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    isCvvRevealed ? card.cvv : card.maskedCvv,
                                    style: GoogleFonts.chivoMono(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isCvvRevealed) {
                                          _revealedCvvs.remove(card.id);
                                        } else {
                                          _revealedCvvs.add(card.id);
                                        }
                                      });
                                    },
                                    child: Icon(
                                      isCvvRevealed
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: card.cvv));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            context.tr.copiedToClipboard,
                                            style: GoogleFonts.cairo(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.copy_rounded,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Edit / Delete actions
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_rounded,
                                  color: Colors.white70, size: 18),
                              onPressed: () => _openCardDialog(context, card),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.white70, size: 18),
                              onPressed: () =>
                                  _showDeleteConfirm(context, provider, card),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (card.pin != null && card.pin!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ATM PIN: ${card.pin!}',
                          style: GoogleFonts.chivoMono(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCardDialog(BuildContext context, PaymentCard? existingCard) {
    showDialog(
      context: context,
      builder: (ctx) => _CardFormBottomSheet(card: existingCard),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, VaultProvider provider, PaymentCard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr.deleteCard, style: GoogleFonts.cairo()),
        content: Text(context.tr.deleteCardConfirm, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr.cancel, style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCard(card.id);
              Navigator.pop(ctx);
            },
            child: Text(
              context.tr.delete,
              style: GoogleFonts.cairo(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFormBottomSheet extends StatefulWidget {
  final PaymentCard? card;

  const _CardFormBottomSheet({this.card});

  @override
  State<_CardFormBottomSheet> createState() => _CardFormBottomSheetState();
}

class _CardFormBottomSheetState extends State<_CardFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _holderController;
  late TextEditingController _numberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  late TextEditingController _pinController;
  late TextEditingController _bankController;
  late TextEditingController _notesController;
  int _colorIndex = 0;
  String _cardType = 'Visa';

  static const List<Color> _themeColors = [
    Color(0xFF1E3A8A), // Deep Navy
    Color(0xFF059669), // Emerald
    Color(0xFF7C3AED), // Violet
    Color(0xFF27272A), // Obsidian
    Color(0xFFD97706), // Gold
  ];

  @override
  void initState() {
    super.initState();
    _holderController =
        TextEditingController(text: widget.card?.cardHolderName ?? '');
    _numberController =
        TextEditingController(text: widget.card?.cardNumber ?? '');
    _expiryController =
        TextEditingController(text: widget.card?.expiryDate ?? '');
    _cvvController = TextEditingController(text: widget.card?.cvv ?? '');
    _pinController = TextEditingController(text: widget.card?.pin ?? '');
    _bankController = TextEditingController(text: widget.card?.bankName ?? '');
    _notesController = TextEditingController(text: widget.card?.notes ?? '');
    _colorIndex = widget.card?.colorIndex ?? 0;
    _cardType = widget.card?.cardType ?? 'Visa';
  }

  @override
  void dispose() {
    _holderController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _bankController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<VaultProvider>(context, listen: false);
    final now = DateTime.now();

    if (widget.card == null) {
      final card = PaymentCard(
        id: const Uuid().v4(),
        cardHolderName: _holderController.text.trim(),
        cardNumber: _numberController.text.trim(),
        expiryDate: _expiryController.text.trim(),
        cvv: _cvvController.text.trim(),
        pin: _pinController.text.trim().isEmpty ? null : _pinController.text.trim(),
        cardType: _cardType,
        bankName: _bankController.text.trim().isEmpty ? null : _bankController.text.trim(),
        colorIndex: _colorIndex,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await provider.addCard(card);
    } else {
      final updated = widget.card!.copyWith(
        cardHolderName: _holderController.text.trim(),
        cardNumber: _numberController.text.trim(),
        expiryDate: _expiryController.text.trim(),
        cvv: _cvvController.text.trim(),
        pin: _pinController.text.trim().isEmpty ? null : _pinController.text.trim(),
        cardType: _cardType,
        bankName: _bankController.text.trim().isEmpty ? null : _bankController.text.trim(),
        colorIndex: _colorIndex,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        updatedAt: now,
      );
      await provider.updateCard(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.card == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Title and Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardsAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.credit_card_rounded, color: AppColors.cardsAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isNew ? context.tr.newCard : context.tr.editCard,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: context.isArabic ? 'إغلاق' : 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Theme color picker
                        Text(
                          context.tr.cardColorLabel,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_themeColors.length, (index) {
                  final isSelected = _colorIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _colorIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _themeColors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: _themeColors[index].withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Cardholder Name
              TextFormField(
                controller: _holderController,
                decoration: InputDecoration(
                  labelText: context.tr.cardHolderLabel,
                  hintText: context.tr.cardHolderHint,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? context.tr.cardHolderLabel : null,
              ),
              const SizedBox(height: 14),

              // Card Number
              TextFormField(
                controller: _numberController,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.tr.cardNumberLabel,
                  hintText: context.tr.cardNumberHint,
                  prefixIcon: const Icon(Icons.credit_card_rounded),
                ),
                onChanged: (val) {
                  final detected = PaymentCard.detectCardType(val);
                  if (detected != 'Card') {
                    setState(() => _cardType = detected);
                  }
                },
                validator: (v) =>
                    v == null || v.trim().isEmpty ? context.tr.cardNumberLabel : null,
              ),
              const SizedBox(height: 14),

              // Expiry & CVV in a row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: context.tr.expiryDateLabel,
                        hintText: context.tr.expiryDateHint,
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'MM/YY' : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: context.tr.cvvLabel,
                        hintText: context.tr.cvvHint,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'CVV' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bank Name & ATM PIN in a row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _bankController,
                      decoration: InputDecoration(
                        labelText: context.tr.bankNameLabel,
                        hintText: context.tr.bankNameHint,
                        prefixIcon: const Icon(Icons.account_balance_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextFormField(
                      controller: _pinController,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: context.tr.cardPinLabel,
                        prefixIcon: const Icon(Icons.pin_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: context.tr.notesOptional,
                  prefixIcon: const Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cardsAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _save,
                  child: Text(
                    isNew ? context.tr.add : context.tr.save,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
