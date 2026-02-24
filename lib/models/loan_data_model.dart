/// Model class to store all loan application form data
class LoanDataModel {
  // Personal Details
  String? name;
  String? email;
  String? phoneNumber;
  String? panNumber;
  String? employmentType;
  String? dateOfBirth; // Date of Birth from CIBIL check screen
  
  // Loan Details (from previous screens)
  double? loanAmount;
  int? tenure;
  String? loanType;
  
  // Bank Details
  String? bankName;
  String? accountNumber;
  String? ifscCode;
  
  // Additional data that might be collected
  Map<String, dynamic>? additionalData;

  LoanDataModel({
    this.name,
    this.email,
    this.phoneNumber,
    this.panNumber,
    this.employmentType,
    this.dateOfBirth,
    this.loanAmount,
    this.tenure,
    this.loanType,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.additionalData,
  });

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    final loanData = <String, dynamic>{};
    
    // Add personal details
    if (name != null) loanData['name'] = name;
    if (email != null) loanData['email'] = email;
    if (phoneNumber != null) loanData['phoneNumber'] = phoneNumber;
    if (panNumber != null) loanData['panNumber'] = panNumber;
    if (employmentType != null) loanData['employmentType'] = employmentType;
    if (dateOfBirth != null) loanData['dateOfBirth'] = dateOfBirth;
    
    // Add loan details
    if (loanAmount != null) loanData['loanAmount'] = loanAmount;
    if (tenure != null) loanData['tenure'] = tenure;
    if (loanType != null) loanData['loanType'] = loanType;
    
    // Add bank details
    if (bankName != null) loanData['bankName'] = bankName;
    if (accountNumber != null) loanData['accountNumber'] = accountNumber;
    if (ifscCode != null) loanData['ifscCode'] = ifscCode;
    
    // Add any additional data
    if (additionalData != null) {
      loanData.addAll(additionalData!);
    }
    
    return loanData;
  }

  /// Create from JSON
  factory LoanDataModel.fromJson(Map<String, dynamic> json) {
    return LoanDataModel(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      panNumber: json['panNumber'] as String?,
      employmentType: json['employmentType'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      loanAmount: json['loanAmount'] != null ? (json['loanAmount'] as num).toDouble() : null,
      tenure: json['tenure'] as int?,
      loanType: json['loanType'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  /// Clear all data
  void clear() {
    name = null;
    email = null;
    phoneNumber = null;
    panNumber = null;
    employmentType = null;
    dateOfBirth = null;
    loanAmount = null;
    tenure = null;
    loanType = null;
    bankName = null;
    accountNumber = null;
    ifscCode = null;
    additionalData = null;
  }
}
