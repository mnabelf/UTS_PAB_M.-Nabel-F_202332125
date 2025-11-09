import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class AddTransactionSheet extends StatefulWidget {
  final TransactionModel? transaction; // null = mode Add, not null = Edit

  const AddTransactionSheet({super.key, this.transaction});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  bool isIncome = false;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String selectedCategory = "Makan";
  DateTime selectedDate = DateTime.now();

  final categories = ["Makan", "Transport", "Gaji", "Belanja", "Lainnya"];

  @override
  void initState() {
    super.initState();

    if (widget.transaction != null) {
      final t = widget.transaction!;
      isIncome = t.isIncome;
      amountController.text = t.amount.toStringAsFixed(0);
      noteController.text = t.note ?? "";
      selectedCategory = t.category;
      selectedDate = t.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Text(
              isEdit ? "Edit Transaksi" : "Tambah Transaksi",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _typeButton("Pengeluaran", false),
                const SizedBox(width: 8),
                _typeButton("Pemasukan", true),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Jumlah (Rp)"),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField(
              initialValue: selectedCategory,
              dropdownColor: const Color(0xFF2A2A2A),
              style: const TextStyle(color: Colors.white),
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              decoration: _inputDecoration("Kategori"),
              onChanged: (value) => setState(() => selectedCategory = value.toString()),
            ),

            const SizedBox(height: 12),

            // Date Picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  helpText: "Pilih Tanggal",
                  cancelText: "Batal",
                  confirmText: "Pilih",
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFF4CAF50),
                          onSurface: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                  color: Colors.white10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDate(selectedDate), style: const TextStyle(color: Colors.white)),
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: noteController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Catatan (opsional)"),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (amountController.text.isEmpty) return;

                  final newT = TransactionModel(
                    category: selectedCategory,
                    date: selectedDate,
                    amount: double.tryParse(amountController.text) ?? 0,
                    isIncome: isIncome,
                    note: noteController.text.isEmpty ? null : noteController.text,
                  );

                  Navigator.pop(context, newT);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  isEdit ? "Update" : "Simpan",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String text, bool incomeValue) {
    final active = isIncome == incomeValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isIncome = incomeValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF4CAF50) : Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.white70)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    const days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];

    final dayName = days[date.weekday - 1];
    final month = months[date.month - 1];

    return "$dayName, ${date.day} $month ${date.year}";
  }
}
