part of 'transaction_cubit.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final double totalBalance;
  final Map<Category, double> monthlyExpensesByCategory;
  final Map<DateTime, List<dynamic>> events; // <-- أضف هذا السطر

  const TransactionLoaded({
    required this.transactions,
    required this.totalBalance,
    required this.monthlyExpensesByCategory,
    required this.events, // <-- وأضفه هنا
  });

  @override
  List<Object> get props => [
    transactions,
    totalBalance,
    monthlyExpensesByCategory,
    events,
  ]; // <-- وهنا
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object> get props => [message];
}
