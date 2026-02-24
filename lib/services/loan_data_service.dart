import '../models/loan_data_model.dart';

/// Singleton service to manage loan application data across screens
class LoanDataService {
  static final LoanDataService _instance = LoanDataService._internal();
  factory LoanDataService() => _instance;
  LoanDataService._internal();

  final LoanDataModel _loanData = LoanDataModel();

  /// Get the current loan data
  LoanDataModel get loanData => _loanData;

  /// Update personal details
  void updatePersonalDetails({
    String? name,
    String? email,
    String? phoneNumber,
    String? panNumber,
    String? employmentType,
    String? dateOfBirth,
  }) {
    if (name != null) _loanData.name = name;
    if (email != null) _loanData.email = email;
    if (phoneNumber != null) _loanData.phoneNumber = phoneNumber;
    if (panNumber != null) _loanData.panNumber = panNumber;
    if (employmentType != null) _loanData.employmentType = employmentType;
    if (dateOfBirth != null) _loanData.dateOfBirth = dateOfBirth;
  }

  /// Update CIBIL check data
  void updateCibilData({
    String? name,
    String? phoneNumber,
    String? panNumber,
    String? dateOfBirth,
  }) {
    if (name != null) _loanData.name = name;
    if (phoneNumber != null) _loanData.phoneNumber = phoneNumber;
    if (panNumber != null) _loanData.panNumber = panNumber;
    if (dateOfBirth != null) _loanData.dateOfBirth = dateOfBirth;
  }

  /// Update loan details
  void updateLoanDetails({
    double? loanAmount,
    int? tenure,
    String? loanType,
  }) {
    if (loanAmount != null) _loanData.loanAmount = loanAmount;
    if (tenure != null) _loanData.tenure = tenure;
    if (loanType != null) _loanData.loanType = loanType;
  }

  /// Update bank details
  void updateBankDetails({
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }) {
    if (bankName != null) _loanData.bankName = bankName;
    if (accountNumber != null) _loanData.accountNumber = accountNumber;
    if (ifscCode != null) _loanData.ifscCode = ifscCode;
  }

  /// Add additional data
  void addAdditionalData(String key, dynamic value) {
    _loanData.additionalData ??= <String, dynamic>{};
    _loanData.additionalData![key] = value;
  }

  /// Clear all data
  void clear() {
    _loanData.clear();
  }

  /// Get data as JSON for API submission
  Map<String, dynamic> getDataForApi() {
    return {
      'name': _loanData.name ?? '',
      'loanData': [_loanData.toJson()],
    };
  }
}
