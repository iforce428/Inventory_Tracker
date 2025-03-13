// account.dart
class StaffAccount {
  // Define the properties
  final int staffId;
  final String staffName;
  final String staffEmail;
  final String staffPassword;

  // Constructor to initialize the class properties
  StaffAccount({
    required this.staffId,
    required this.staffName,
    required this.staffEmail,
    required this.staffPassword,
  });

  // Method to create a new staff account (dummy logic for validation)
  static String createAccount(StaffAccount staffAccount) {
    // Dummy validation to check if all fields are filled
    if (staffAccount.staffName.isEmpty || staffAccount.staffEmail.isEmpty || staffAccount.staffPassword.isEmpty) {
      return "All fields must be filled!";
    }

    // Simulating saving the account (you can implement real saving logic here)
    return "Account for ${staffAccount.staffName} has been successfully created!";
  }

  // Method to print the account details (for testing purposes)
  void printAccountDetails() {
    print("Staff ID: $staffId");
    print("Staff Name: $staffName");
    print("Staff Email: $staffEmail");
    print("Staff Password: $staffPassword");
  }
}

