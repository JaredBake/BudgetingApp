
class Profile {
  final bool isDarkMode;
  final String selectedCurrency;

  Profile({
     this.isDarkMode = false, 
     this.selectedCurrency = "USD",
    });

  Profile.custom(this.isDarkMode, this.selectedCurrency);  
}
