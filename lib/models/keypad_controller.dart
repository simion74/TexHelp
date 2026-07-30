/// প্রতিটি ক্যালকুলেটর স্ক্রিনে কয়েকটি ইনপুট ফিল্ড থাকে এবং কাস্টম কিপ্যাড
/// দিয়ে সেগুলোর মধ্যে যেকোনো একটি (active) এডিট করা হয়। এই ক্লাসটি সেই
/// কমন লজিক (active field, digit append, backspace, next/prev field) ধরে রাখে,
/// যাতে প্রতিটি স্ক্রিনে কোড ডুপ্লিকেট করতে না হয়।
class KeypadFieldController {
  final List<String> ids;
  final Map<String, String> values = {};
  late String activeId;

  KeypadFieldController(this.ids) {
    for (final id in ids) {
      values[id] = '';
    }
    activeId = ids.first;
  }

  void setActive(String id) => activeId = id;

  void appendDigit(String val) {
    final current = values[activeId] ?? '';
    if (val == '.' && current.contains('.')) return;
    values[activeId] = current + val;
  }

  void backspace() {
    final current = values[activeId] ?? '';
    if (current.isNotEmpty) {
      values[activeId] = current.substring(0, current.length - 1);
    }
  }

  void clearActive() {
    values[activeId] = '';
  }

  void moveField(int direction) {
    final idx = ids.indexOf(activeId);
    final nextIdx = (idx + direction + ids.length) % ids.length;
    activeId = ids[nextIdx];
  }

  void resetAll() {
    for (final id in ids) {
      values[id] = '';
    }
    activeId = ids.first;
  }

  double? number(String id) {
    final raw = values[id];
    if (raw == null || raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  void setValue(String id, String val) {
    values[id] = val;
  }
}
