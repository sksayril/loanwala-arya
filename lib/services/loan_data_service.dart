import '../models/loan_data_model.dart';

class LoanDataService {
  static final LoanDataService _instance = LoanDataService._internal();
  factory LoanDataService() => _instance;
  LoanDataService._internal();

  final LoanDataModel _loanData = LoanDataModel();

  // Getters
  LoanDataModel get loanData => _loanData;

  // CIBIL Screen Data
  void setCibilData({
    String? name,
    String? phone,
    String? pan,
    String? dob,
  }) {
    if (name != null) _loanData.cibilName = name;
    if (phone != null) _loanData.cibilPhone = phone;
    if (pan != null) _loanData.cibilPan = pan;
    if (dob != null) _loanData.cibilDob = dob;
  }

  // Customize Loan Screen Data
  void setLoanDetails({
    double? loanAmount,
    int? tenure,
    String? loanType,
  }) {
    if (loanAmount != null) _loanData.loanAmount = loanAmount;
    if (tenure != null) _loanData.tenure = tenure;
    if (loanType != null) _loanData.loanType = loanType;
  }

  // Personal Details Screen Data
  void setPersonalDetails({
    String? name,
    String? mobile,
    String? pan,
    String? employmentType,
  }) {
    if (name != null) _loanData.personalName = name;
    if (mobile != null) _loanData.personalMobile = mobile;
    if (pan != null) _loanData.personalPan = pan;
    if (employmentType != null) _loanData.employmentType = employmentType;
  }

  // KYC Screen Data
  void setKycData({
    String? aadhaarNumber,
    String? pan,
    String? address,
  }) {
    if (aadhaarNumber != null) _loanData.aadhaarNumber = aadhaarNumber;
    if (pan != null) _loanData.kycPan = pan;
    if (address != null) _loanData.address = address;
  }

  // Bank Details Screen Data
  void setBankDetails({
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }) {
    if (bankName != null) _loanData.bankName = bankName;
    if (accountNumber != null) _loanData.accountNumber = accountNumber;
    if (ifscCode != null) _loanData.ifscCode = ifscCode;
  }

  // Clear all data
  void clearAll() {
    _loanData.clear();
  }

  // Get data for API submission
  Map<String, dynamic> getApiPayload() {
    return {
      'name': _loanData.primaryName ?? '',
      'loanData': [_loanData.toJson()],
    };
  }
}
