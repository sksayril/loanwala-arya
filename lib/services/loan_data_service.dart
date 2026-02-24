import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/loan_data_model.dart';

class LoanDataService {
  static const String apiUrl = 'https://datahive.skystar.co.in/loan-data';
  
  // Singleton instance
  static final LoanDataService _instance = LoanDataService._internal();
  factory LoanDataService() => _instance;
  LoanDataService._internal();
  
  // Store loan data
  LoanDataModel _loanData = LoanDataModel();
  
  // Getters
  LoanDataModel get loanData => _loanData;
  
  // Update loan details
  void updateLoanDetails({
    double? loanAmount,
    int? tenure,
    String? loanType,
  }) {
    _loanData.loanAmount = loanAmount ?? _loanData.loanAmount;
    _loanData.tenure = tenure ?? _loanData.tenure;
    _loanData.loanType = loanType ?? _loanData.loanType;
  }
  
  // Update personal details
  void updatePersonalDetails({
    String? name,
    String? email,
    String? mobile,
    String? pan,
    String? employmentType,
    String? dateOfBirth,
  }) {
    _loanData.name = name ?? _loanData.name;
    _loanData.email = email ?? _loanData.email;
    _loanData.mobile = mobile ?? _loanData.mobile;
    _loanData.pan = pan ?? _loanData.pan;
    _loanData.employmentType = employmentType ?? _loanData.employmentType;
    _loanData.dateOfBirth = dateOfBirth ?? _loanData.dateOfBirth;
  }
  
  // Update KYC details
  void updateKycDetails({
    String? aadhaar,
    String? address,
  }) {
    _loanData.aadhaar = aadhaar ?? _loanData.aadhaar;
    _loanData.address = address ?? _loanData.address;
  }
  
  // Update bank details
  void updateBankDetails({
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }) {
    _loanData.bankName = bankName ?? _loanData.bankName;
    _loanData.accountNumber = accountNumber ?? _loanData.accountNumber;
    _loanData.ifscCode = ifscCode ?? _loanData.ifscCode;
  }
  
  // Submit loan data to API
  Future<Map<String, dynamic>> submitLoanData() async {
    try {
      // Prepare request body
      final requestBody = {
        'name': _loanData.name ?? '',
        'loanData': _loanData.toLoanDataArray(),
      };
      
      print('Submitting loan data: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection.');
        },
      );
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Loan data submitted successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit loan data: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      print('Error submitting loan data: $e');
      String errorMessage = 'An error occurred while submitting your data';
      
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup')) {
        errorMessage = 'No internet connection. Please check your network.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'error': e.toString(),
      };
    }
  }
  
  // Clear all stored data
  void clearData() {
    _loanData = LoanDataModel();
  }
  
  // Check if required data is available
  bool hasRequiredData() {
    return _loanData.name != null && 
           _loanData.name!.isNotEmpty &&
           _loanData.mobile != null &&
           _loanData.mobile!.isNotEmpty;
  }
}
