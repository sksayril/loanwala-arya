class LoanApplicationData {
  // Loan Details (from CustomizeLoanScreen)
  String? loanType;
  double? loanAmount;
  int? tenure; // in months
  double? interestRate;
  double? emi;

  // Personal Details (from PersonalDetailsScreen)
  String? name;
  String? email;
  String? mobile;
  String? pan;
  String? employmentType;

  // CIBIL Check Details (from CheckCibilScreen)
  String? cibilName;
  String? cibilPhone;
  String? cibilPan;
  String? dateOfBirth;

  // KYC Details (from KycVerificationScreen)
  String? aadhaar;
  String? address;

  // Bank Details (from BankDetailsScreen)
  String? bankName;
  String? accountNumber;
  String? ifscCode;

  LoanApplicationData({
    this.loanType,
    this.loanAmount,
    this.tenure,
    this.interestRate,
    this.emi,
    this.name,
    this.email,
    this.mobile,
    this.pan,
    this.employmentType,
    this.cibilName,
    this.cibilPhone,
    this.cibilPan,
    this.dateOfBirth,
    this.aadhaar,
    this.address,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
  });

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'loanType': loanType,
      'loanAmount': loanAmount,
      'tenure': tenure,
      'interestRate': interestRate,
      'emi': emi,
      'name': name,
      'email': email,
      'mobile': mobile,
      'pan': pan,
      'employmentType': employmentType,
      'cibilName': cibilName,
      'cibilPhone': cibilPhone,
      'cibilPan': cibilPan,
      'dateOfBirth': dateOfBirth,
      'aadhaar': aadhaar,
      'address': address,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
    };
  }

  // Convert to loanData array format for API
  Map<String, dynamic> toLoanDataJson() {
    return {
      'loanType': loanType,
      'loanAmount': loanAmount,
      'tenure': tenure,
      'interestRate': interestRate,
      'emi': emi,
      'mobile': mobile,
      'pan': pan,
      'employmentType': employmentType,
      'email': email,
      'aadhaar': aadhaar,
      'address': address,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      // CIBIL Check Data
      'cibilName': cibilName,
      'cibilPhone': cibilPhone,
      'cibilPan': cibilPan,
      'dateOfBirth': dateOfBirth,
    };
  }
}
