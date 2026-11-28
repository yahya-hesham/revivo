import '../../data/models/warranty_models.dart';

abstract class WarrantyState {
  const WarrantyState();
}

class WarrantyInitial extends WarrantyState {
  const WarrantyInitial();
}

class WarrantyLoading extends WarrantyState {
  const WarrantyLoading();
}

class WarrantiesListLoaded extends WarrantyState {
  const WarrantiesListLoaded(this.warranties);

  final List<WarrantyModel> warranties;
}

class WarrantyDetailLoaded extends WarrantyState {
  const WarrantyDetailLoaded(this.warranty);

  final WarrantyModel? warranty;
}

class WarrantyActionLoading extends WarrantyState {
  const WarrantyActionLoading();
}

class WarrantySavedSuccess extends WarrantyState {
  const WarrantySavedSuccess(this.warranty);

  final WarrantyModel warranty;
}

class WarrantyDeletedSuccess extends WarrantyState {
  const WarrantyDeletedSuccess();
}

class WarrantyError extends WarrantyState {
  const WarrantyError({
    required this.message,
    this.fieldErrors = const {},
  });

  final String message;
  final Map<String, List<String>> fieldErrors;

  String? fieldError(String fieldName) {
    final errors = fieldErrors[fieldName.toLowerCase()];
    if (errors == null || errors.isEmpty) return null;
    return errors.first;
  }
}
