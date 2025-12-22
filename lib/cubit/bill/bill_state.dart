import 'package:equatable/equatable.dart';
import '../../models/models.dart';

/// States for bill management
abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BillInitial extends BillState {
  const BillInitial();
}

/// Loading bills
class BillLoading extends BillState {
  const BillLoading();
}

/// Bills loaded successfully
class BillsLoaded extends BillState {
  final List<Bill> bills;

  const BillsLoaded(this.bills);

  @override
  List<Object?> get props => [bills];
}

/// Single bill loaded (for detail view)
class BillDetailLoaded extends BillState {
  final Bill bill;
  final Map<String, AppUser> participants;

  const BillDetailLoaded({required this.bill, required this.participants});

  @override
  List<Object?> get props => [bill, participants];
}

/// Bill operation in progress
class BillOperating extends BillState {
  final String message;

  const BillOperating([this.message = 'Processing...']);

  @override
  List<Object?> get props => [message];
}

/// Bill created successfully
class BillCreated extends BillState {
  final String billId;

  const BillCreated(this.billId);

  @override
  List<Object?> get props => [billId];
}

/// Bill error occurred
class BillError extends BillState {
  final String message;

  const BillError(this.message);

  @override
  List<Object?> get props => [message];
}
