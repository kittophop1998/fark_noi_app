import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/services/media_upload_service.dart';
import '../../domain/entities/reputation_entity.dart';
import '../store/profile_store.dart';

const _kPrimary = AppColors.primary;
const _kTextPrimary = AppColors.text;
const _kTextSecondary = AppColors.muted;
const _kBorder = AppColors.border;
const _kBg = AppColors.background;

/// `PATCH /me { promptPayId }` — the one thing every payment screen in the
/// app (the receiving QR, an order's `OrderPayment`) reads back afterwards.
class PromptPayEditSheet extends StatefulWidget {
  final ProfileStore store;
  final String? current;

  const PromptPayEditSheet({super.key, required this.store, this.current});

  @override
  State<PromptPayEditSheet> createState() => _PromptPayEditSheetState();
}

class _PromptPayEditSheetState extends State<PromptPayEditSheet> {
  late final _controller = TextEditingController(text: widget.current ?? '');
  bool _saving = false;
  String? _error;

  String get _digits => _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
  bool get _valid => _digits.length == 10 || _digits.length == 13;

  Future<void> _save() async {
    if (!_valid) {
      setState(() => _error = 'ใส่เบอร์มือถือ 10 หลัก หรือเลขบัตรประชาชน 13 หลัก');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await widget.store.updateProfile(promptPayId: _digits);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = widget.store.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ข้อมูลพร้อมเพย์',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kTextPrimary)),
            const SizedBox(height: 4),
            const Text(
              'ใช้สร้าง QR รับเงินตอนส่งของ และแสดงให้คนฝากเห็นตอนถึงจุดจ่ายเงิน',
              style: TextStyle(fontSize: 12, color: _kTextSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'เบอร์มือถือ หรือ เลขบัตรประชาชน',
                errorText: _error,
                filled: true,
                fillColor: _kBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('บันทึก',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `PATCH /me { displayName, avatarMediaId }`.
class EditProfileSheet extends StatefulWidget {
  final ProfileStore store;
  final String currentName;

  const EditProfileSheet(
      {super.key, required this.store, required this.currentName});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final _controller = TextEditingController(text: widget.currentName);
  File? _avatar;
  bool _saving = false;
  String? _error;

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _avatar = File(picked.path));
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'ใส่ชื่อที่ต้องการแสดง');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      String? avatarMediaId;
      if (_avatar != null) {
        avatarMediaId = await sl<MediaUploadService>().upload(
          file: _avatar!,
          purpose: MediaPurpose.profileImage,
        );
      }
      final ok = await widget.store.updateProfile(
        displayName: name,
        avatarMediaId: avatarMediaId,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _saving = false;
          _error = widget.store.errorMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'อัปโหลดรูปไม่สำเร็จ ลองใหม่อีกครั้ง';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('แก้ไขโปรไฟล์',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kTextPrimary)),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.secondarySoft,
                      backgroundImage:
                          _avatar != null ? FileImage(_avatar!) : null,
                      child: _avatar == null
                          ? const Icon(Icons.person_rounded,
                              size: 36, color: AppColors.secondary)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                            color: _kPrimary, shape: BoxShape.circle),
                        child: const Icon(Icons.edit_rounded,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'ชื่อที่แสดง',
                errorText: _error,
                filled: true,
                fillColor: _kBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('บันทึก',
                        style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A read-only breakdown of the two wallets `ProfileStore.credits` already
/// holds — no separate call, since `/me/credits/transactions` has no
/// published schema to parse against safely.
class CreditsDetailSheet extends StatelessWidget {
  final CreditBalanceEntity credits;
  const CreditsDetailSheet({super.key, required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('เครดิตของฉัน',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _kTextPrimary)),
          const SizedBox(height: 16),
          _WalletRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'เครดิตฝากซื้อ (คงเหลือ)',
            value: credits.depositBalance,
          ),
          if (credits.depositReserved > 0)
            _WalletRow(
              icon: Icons.lock_clock_outlined,
              label: 'ถูกกันไว้สำหรับออเดอร์ที่เปิดอยู่',
              value: credits.depositReserved,
              muted: true,
            ),
          const Divider(height: 28),
          _WalletRow(
            icon: Icons.savings_outlined,
            label: 'รายได้จากการหิ้ว (คงเหลือ)',
            value: credits.earningBalance,
          ),
          if (credits.pendingEarnings > 0)
            _WalletRow(
              icon: Icons.hourglass_bottom_rounded,
              label: 'รอเข้าบัญชี (งานยังไม่ปิด)',
              value: credits.pendingEarnings,
              muted: true,
            ),
        ],
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final bool muted;

  const _WalletRow({
    required this.icon,
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: muted ? _kTextSecondary : _kPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: muted ? _kTextSecondary : _kTextPrimary)),
          ),
          Text(
            '฿${value.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: muted ? _kTextSecondary : _kPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
