import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/transaction_model.dart';
import '../widgets/add_transaction_sheet.dart';
import 'detail.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<TransactionModel> transactions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () async {
          final newT = await showModalBottomSheet<TransactionModel>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => const AddTransactionSheet(),
          );
          if (newT != null) setState(() => transactions.insert(0, newT));
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // SALDO: full width header
          Card(
            margin: EdgeInsets.zero,
            color: const Color(0xFF1E1E1E),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Saldo Saat Ini", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(
                    "Rp ${_formatCurrency(getBalance())}",
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row: pemasukan & pengeluaran
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                const Text("Pemasukan", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 6),
                                Text(
                                  "Rp ${_formatCurrency(getTotalIncome())}",
                                  style: const TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              children: [
                                const Text("Pengeluaran", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                const SizedBox(height: 6),
                                Text(
                                  "Rp ${_formatCurrency(getTotalExpense())}",
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // PREVIEW CARD: kategori terbesar (tint gelap warna kategori)
                  Builder(
                    builder: (context) {
                      final expenseData = getExpenseByCategory();
                      if (expenseData.isEmpty) return const SizedBox.shrink();

                      final sorted = expenseData.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                      final top = sorted.first;
                      final totalExpense = getTotalExpense();
                      final percent = totalExpense > 0
                          ? (top.value / totalExpense * 100).toStringAsFixed(0)
                          : "0";

                      return GestureDetector(
                        onTap: _openFullExpenseChart,
                        child: Container
                        (
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: getCategoryDarkTint(top.key),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Kategori Pengeluaran Terbesar",
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                top.key,
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${_formatCurrency(top.value)}  •  $percent%",
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Tap untuk lihat grafik",
                                style: TextStyle(color: Colors.white38, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Text(
                    "Transaksi Terbaru",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        return Card(
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransactionDetailScreen(transaction: t),
                                ),
                              );

                              if (result == null) return;

                              if (result is TransactionModel) {
                                setState(() => transactions[index] = result);
                              } else if (result == "deleted") {
                                setState(() => transactions.removeAt(index));
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                t.isIncome ? Icons.call_received : Icons.call_made,
                                color: t.isIncome ? const Color(0xFF4CAF50) : Colors.redAccent,
                                size: 22,
                              ),
                            ),
                            title: Text(t.category, style: const TextStyle(color: Colors.white, fontSize: 15)),
                            subtitle: Text(
                              _formatDate(t.date),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            trailing: Text(
                              (t.isIncome ? "+ " : "- ") + "Rp ${_formatCurrency(t.amount)}",
                              style: TextStyle(
                                color: t.isIncome ? const Color(0xFF4CAF50) : Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Helpers: hitung & format ----

  double getTotalIncome() =>
      transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);

  double getTotalExpense() =>
      transactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

  double getBalance() => getTotalIncome() - getTotalExpense();

  Map<String, double> getExpenseByCategory() {
    final Map<String, double> data = {};
    for (var t in transactions.where((t) => !t.isIncome)) {
      data[t.category] = (data[t.category] ?? 0) + t.amount;
    }
    return data;
  }

  static String _formatCurrency(double value) {
    final s = value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.",
    );
    return s;
  }

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
    const days = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"];
    final dayName = days[date.weekday - 1];
    final month = months[date.month - 1];
    return "$dayName, ${date.day} $month ${date.year}";
  }

  // ---- Helpers: warna kategori (utama & dark tint) ----

  Color getCategoryColor(String category) {
    switch (category) {
      case "Makan": return Colors.orange;
      case "Transport": return Colors.blue;
      case "Belanja": return Colors.pink;
      case "Gaji": return Colors.green;
      case "Lainnya": return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color getCategoryDarkTint(String category) {
    // W2: dark tint elegan
    return getCategoryColor(category).withOpacity(0.18);
  }

  // ---- Bottom sheet: full pie chart ----

  void _openFullExpenseChart() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final expenseData = getExpenseByCategory();
        final total = getTotalExpense();

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Text(
                    "Pengeluaran Berdasarkan Kategori",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Total: Rp ${_formatCurrency(total)}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  ExpensePieChart(data: expenseData, colorPicker: getCategoryColor),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Pie chart + legend (hanya menerima data & fungsi warna)
class ExpensePieChart extends StatelessWidget {
  final Map<String, double> data;
  final Color Function(String category) colorPicker;

  const ExpensePieChart({
    super.key,
    required this.data,
    required this.colorPicker,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text("Belum ada pengeluaran", style: TextStyle(color: Colors.white70)),
      );
    }

    final sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = data.values.fold(0.0, (a, b) => a + b);
    final topCategory = sorted.first.key;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Kategori terbanyak: $topCategory",
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 10),

        // Pie chart (lebih compact)
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 42,
              sections: sorted.map((e) {
                final percent = total > 0 ? (e.value / total * 100).toStringAsFixed(0) : "0";
                return PieChartSectionData(
                  color: colorPicker(e.key),
                  value: e.value,
                  title: "$percent%",
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                  radius: 54,
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Legend
        Column(
          children: sorted.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: colorPicker(e.key),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  Text(
                    "Rp ${_formatCurrency(e.value)}",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  static String _formatCurrency(double value) {
    final s = value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.",
    );
    return s;
  }
}
