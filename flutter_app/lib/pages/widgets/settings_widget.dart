
class Settings {
  final bool isDarkMode;
  final String selectedCurrency;

  Settings({
     this.isDarkMode = false, 
     this.selectedCurrency = "USD",
    });

  Settings.custom(this.isDarkMode, this.selectedCurrency);  
}
