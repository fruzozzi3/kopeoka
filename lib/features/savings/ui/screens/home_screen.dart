// lib/features/savings/ui/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_kopilka/features/savings/models/goal.dart';
import 'package:my_kopilka/features/savings/ui/screens/goal_details_screen.dart';
import 'package:my_kopilka/features/savings/ui/screens/statistics_screen.dart';
import 'package:my_kopilka/features/savings/ui/widgets/quick_add_widget.dart';
import 'package:my_kopilka/features/savings/viewmodels/savings_view_model.dart';
import 'package:my_kopilka/theme/color.dart';
import 'package:my_kopilka/core/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'active'; // active, completed, all

  void _showAddGoalDialog(BuildContext context, SavingsViewModel vm) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime? targetDate;
    String selectedCategory = 'general';

    final categories = [
      {'value': 'general', 'name': 'Общие', 'icon': Icons.savings},
      {'value': 'travel', 'name': 'Путешествия', 'icon': Icons.flight},
      {'value': 'electronics', 'name': 'Техника', 'icon': Icons.phone_android},
      {'value': 'education', 'name': 'Образование', 'icon': Icons.school},
      {'value': 'home', 'name': 'Дом', 'icon': Icons.home},
      {'value': 'car', 'name': 'Автомобиль', 'icon': Icons.directions_car},
      {'value': 'gift', 'name': 'Подарки', 'icon': Icons.card_giftcard},
      {'value': 'emergency', 'name': 'Аварийный фонд', 'icon': Icons.emergency},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Новая копилка',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название цели',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    validator: (value) => value!.isEmpty ? 'Введите название' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание (необязательно)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Целевая сумма',
                      prefixIcon: Icon(Icons.monetization_on),
                      suffixText: '₽',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Введите сумму';
                      if (int.tryParse(value) == null || int.parse(value) <= 0) {
                        return 'Введите корректную сумму';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) {
                        setState(() => targetDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Дата цели (необязательно)',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        targetDate != null 
                            ? DateFormat('dd.MM.yyyy').format(targetDate!)
                            : 'Выберите дату',
                        style: TextStyle(
                          color: targetDate != null 
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Категория', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category['value'];
                      return FilterChip(
                        avatar: Icon(category['icon'] as IconData, size: 18),
                        label: Text(category['name'] as String),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => selectedCategory = category['value'] as String);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final name = nameController.text;
                        final description = descriptionController.text.isNotEmpty 
                            ? descriptionController.text 
                            : null;
                        final amount = int.parse(amountController.text);
                        
                        vm.addGoal(
                          name: name,
                          description: description,
                          targetAmount: amount,
                          targetDate: targetDate,
                          category: selectedCategory,
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('Создать копилку'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SavingsViewModel>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Фильтруем цели
    List<Goal> filteredGoals = vm.goals.where((goal) {
      switch (_selectedFilter) {
        case 'completed':
          return goal.isCompleted;
        case 'active':
          return !goal.isCompleted && !goal.isArchived;
        case 'all':
        default:
          return !goal.isArchived;
      }
    }).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Мои Копилки',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                  );
                },
                icon: const Icon(Icons.analytics),
              ),
              IconButton(
                onPressed: () => themeProvider.toggleTheme(),
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              ),
            ],
          ),
          if (vm.isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (vm.goals.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: isDark ? kPrimaryGradientDark : kPrimaryGradientLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.savings,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Создайте свою первую копилку!',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Отслеживайте накопления в физической копилке.\nДобавляйте монеты и банкноты по мере пополнения.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Статистика
                    _buildStatsCard(vm, isDark),
                    const SizedBox(height: 16),
                    
                    // Быстрое пополнение
                    if (filteredGoals.isNotEmpty) ...[
                      const QuickAddWidget(),
                      const SizedBox(height: 16),
                    ],
                    
                    // Фильтры
                    Row(
                      children: [
                        Text('Копилки:', style: Theme.of(context).textTheme.titleLarge),
                        const Spacer(),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'active', label: Text('Активные')),
                            ButtonSegment(value: 'completed', label: Text('Готовые')),
                            ButtonSegment(value: 'all', label: Text('Все')),
                          ],
                          selected: {_selectedFilter},
                          onSelectionChanged: (selected) {
                            setState(() => _selectedFilter = selected.first);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => GoalCard(goal: filteredGoals[index]),
                  childCount: filteredGoals.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context, vm),
        icon: const Icon(Icons.add),
        label: const Text('Новая копилка'),
      ),
    );
  }

  Widget _buildStatsCard(SavingsViewModel vm, bool isDark) {
    final totalSaved = vm.goals.fold(0, (sum, goal) => sum + goal.currentAmount);
    final totalTarget = vm.goals.fold(0, (sum, goal) => sum + goal.targetAmount);
    final completedGoals = vm.goals.where((g) => g.isCompleted).length;
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark ? kPrimaryGradientDark : kPrimaryGradientLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'Общая статистика',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Накоплено',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                    Text(
                      currencyFormat.format(totalSaved),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Завершено целей',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                      textAlign: TextAlign.end,
                    ),
                    Text(
                      '$completedGoals из ${vm.goals.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;
  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'ru_RU', symbol: '₽', decimalDigits: 0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: kSoftShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GoalDetailsScreen(goalId: goal.id!),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: goal.isCompleted 
                            ? kSuccessGradient 
                            : (isDark ? kPrimaryGradientDark : kPrimaryGradientLight),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        goal.isCompleted ? Icons.check : _getCategoryIcon(goal.category),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (goal.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              goal.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (goal.daysUntilTarget != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: goal.daysUntilTarget! <= 7 
                              ? (isDark ? kErrorDark : kErrorLight).withOpacity(0.1)
                              : (isDark ? kPrimaryDark : kPrimaryLight).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${goal.daysUntilTarget!} дн.',
                          style: TextStyle(
                            color: goal.daysUntilTarget! <= 7 
                                ? (isDark ? kErrorDark : kErrorLight)
                                : (isDark ? kPrimaryDark : kPrimaryLight),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(goal.currentAmount),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: goal.isCompleted 
                            ? (isDark ? kSuccessDark : kSuccessLight)
                            : Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Text(
                      '/ ${currencyFormat.format(goal.targetAmount)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 8,
                    backgroundColor: (isDark ? kTextSecondaryDark : kTextSecondaryLight).withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      goal.isCompleted 
                          ? (isDark ? kSuccessDark : kSuccessLight)
                          : (isDark ? kPrimaryDark : kPrimaryLight),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (goal.dailySavingsNeeded != null && !goal.isCompleted)
                      Text(
                        '~${currencyFormat.format(goal.dailySavingsNeeded!.round())}/день',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'travel': return Icons.flight;
      case 'electronics': return Icons.phone_android;
      case 'education': return Icons.school;
      case 'home': return Icons.home;
      case 'car': return Icons.directions_car;
      case 'gift': return Icons.card_giftcard;
      case 'emergency': return Icons.emergency;
      default: return Icons.savings;
    }
  }
}