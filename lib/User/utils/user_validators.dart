/// Classe utilitaire pour la validation des formulaires utilisateur
class UserValidators {
  /// Valide une adresse email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre adresse email';
    }
    
    // Utilisation d'une expression régulière pour valider le format de l'email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide';
    }
    
    return null;
  }

  /// Valide un mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    // Vérification optionnelle de la complexité du mot de passe
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!(hasUppercase && hasDigits) && !hasSpecialCharacters) {
      return 'Le mot de passe doit contenir au moins une majuscule et un chiffre, ou un caractère spécial';
    }
    
    return null;
  }

  /// Valide la confirmation d'un mot de passe
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }

  /// Valide un nom
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nom';
    }
    
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    
    return null;
  }

  /// Valide un numéro de téléphone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    
    // Validation simple pour les numéros de téléphone français
    final phoneRegex = RegExp(r'^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    
    return null;
  }

  /// Version simplifiée de la validation de téléphone (accepte plus de formats)
  static String? validatePhoneSimple(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    
    // Supprime les espaces, tirets et parenthèses pour la validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Vérification simple: uniquement des chiffres et longueur raisonnable
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(cleanPhone)) {
      return 'Veuillez entrer un numéro de téléphone valide';
    }
    
    return null;
  }

  /// Validation générique pour champs requis
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Le champ $fieldName est requis';
    }
    return null;
  }
}