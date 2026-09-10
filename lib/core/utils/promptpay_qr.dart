/// A real, scannable Thai PromptPay QR payload (EMVCo Merchant-Presented
/// Mode), built from a `promptPayId` — the same "bare digits" string `/me`
/// and `OrderPayment.promptPayId` send.
///
/// This is the standard every Thai banking app reads: tag-length-value
/// fields terminated by a CRC-16/CCITT-FALSE checksum over everything before
/// it. There is no server endpoint that mints this string — PromptPay QR
/// codes are computed entirely on-device from the account id, which is why
/// this lives beside the widgets that draw it rather than in a datasource.
class PromptPayQr {
  PromptPayQr._();

  static const _aid = 'A000000677010111';

  /// [promptPayId] is a 10-digit mobile number or a 13-digit national id,
  /// digits only. [amount] in baht; omitted draws a QR the scanner enters
  /// their own amount into, which is what a general "pay me" code needs.
  ///
  /// Returns the empty string for anything that is not one of those two
  /// shapes, so a caller with no id yet draws nothing rather than a code that
  /// fails to scan.
  static String build({required String promptPayId, double? amount}) {
    final digits = promptPayId.replaceAll(RegExp(r'[^0-9]'), '');
    final String targetTag;
    final String targetValue;
    if (digits.length == 10) {
      targetTag = '01';
      // MSISDN form: country code 66 replaces the leading 0.
      targetValue = '0066${digits.substring(1)}';
    } else if (digits.length == 13) {
      targetTag = '02';
      targetValue = digits;
    } else {
      return '';
    }

    final merchantInfo = _serialize([
      _Field('00', _aid),
      _Field(targetTag, targetValue),
    ]);

    final fields = <_Field>[
      _Field('00', '01'), // Payload Format Indicator
      _Field('01', amount != null ? '12' : '11'), // Point of Initiation
      _Field('29', merchantInfo), // Merchant Account Info — PromptPay
      _Field('53', '764'), // Transaction Currency — THB
      if (amount != null) _Field('54', amount.toStringAsFixed(2)),
      _Field('58', 'TH'), // Country Code
    ];

    final withoutCrc = '${_serialize(fields)}6304';
    return withoutCrc + _crc16(withoutCrc);
  }

  static String _serialize(List<_Field> fields) =>
      fields.map((f) => f.encode()).join();

  /// CRC-16/CCITT-FALSE: polynomial 0x1021, initial value 0xFFFF, no final
  /// XOR — the checksum every PromptPay reader validates the payload with.
  static String _crc16(String data) {
    var crc = 0xFFFF;
    for (final byte in data.codeUnits) {
      crc ^= byte << 8;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 0x8000) != 0 ? ((crc << 1) ^ 0x1021) : (crc << 1);
        crc &= 0xFFFF;
      }
    }
    return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}

class _Field {
  const _Field(this.id, this.value);

  final String id;
  final String value;

  String encode() => '$id${value.length.toString().padLeft(2, '0')}$value';
}
