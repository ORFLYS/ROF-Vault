import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

extension LocalizationExtension on BuildContext {
  AppStrings get tr => AppStrings.of(this);
  bool get isArabic => Provider.of<LocaleProvider>(this).isArabic;
}

class AppStrings {
  final bool isArabic;

  const AppStrings({required this.isArabic});

  static AppStrings of(BuildContext context) {
    final isAr = Provider.of<LocaleProvider>(context).isArabic;
    return AppStrings(isArabic: isAr);
  }

  // ==================== APP INFO ====================
  String get appName => isArabic ? 'خزنة ROF' : 'ROF Vault';
  String get appSubtitle => isArabic ? 'مساحتك الآمنة والخاصة' : 'Your Secure & Private Space';
  String get encryptedVault => isArabic ? 'الخزنة المشفرة' : 'Encrypted Vault';
  String get vaultUser => isArabic ? 'مستخدم الخزنة' : 'Vault User';

  // ==================== NAVIGATION ====================
  String get navHome => isArabic ? 'الرئيسية' : 'Home';
  String get navSearch => isArabic ? 'البحث الشامل' : 'Global Search';
  String get navTrash => isArabic ? 'سلة المحذوفات' : 'Trash';
  String get navSettings => isArabic ? 'الإعدادات' : 'Settings';
  String get lockVault => isArabic ? 'قفل الخزنة' : 'Lock Vault';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get currentLanguageName => isArabic ? 'العربية' : 'English';
  String get otherLanguageName => isArabic ? 'English' : 'العربية';
  String get switchToOtherLanguage => isArabic ? 'Switch to English' : 'التحويل للعربية';

  // ==================== HOME ====================
  String get vaultCategories => isArabic ? 'أقسام الخزنة' : 'Vault Categories';
  String get welcomeUser => isArabic ? 'مرحباً بك' : 'Welcome back';
  String get totalProtectedItems => isArabic ? 'عناصر محمية داخل خزنتك' : 'protected items in your vault';
  String get cloudBackupActive => isArabic ? 'النسخ السحابي مفعل' : 'Cloud Backup Active';
  String get cloudBackupInactive => isArabic ? 'النسخ السحابي غير متصل' : 'Cloud Backup Inactive';
  String get connectDrivePrompt => isArabic ? 'اربط Google Drive لحفظ ملفاتك سحابياً' : 'Connect Google Drive for cloud backup';

  // Categories
  String get catGallery => isArabic ? 'الاستوديو' : 'Media Gallery';
  String get catGallerySub => isArabic ? 'الصور ومقاطع الفيديو المشفرة' : 'Encrypted photos & videos';
  String get catPhotos => isArabic ? 'الصور' : 'Photos';
  String get catPhotosSub => isArabic ? 'صورك الخاصة والمشفرة' : 'Private encrypted photos';
  String get catVideos => isArabic ? 'الفيديوهات' : 'Videos';
  String get catVideosSub => isArabic ? 'مقاطعك المحمية بأمان' : 'Secure protected videos';
  String get catNotes => isArabic ? 'الملاحظات' : 'Notes';
  String get catNotesSub => isArabic ? 'أفكارك ونصوصك السرية' : 'Secret notes & ideas';
  String get catAccounts => isArabic ? 'الحسابات' : 'Accounts';
  String get catAccountsSub => isArabic ? 'بيانات الدخول وكلمات المرور' : 'Login credentials & passwords';
  String get catWebsites => isArabic ? 'المواقع الآمنة' : 'Safe Websites';
  String get catWebsitesSub => isArabic ? 'روابطك وحساباتك المهمة' : 'Important links & portals';
  String get catDocuments => isArabic ? 'المستندات' : 'Documents';
  String get catDocumentsSub => isArabic ? 'ملفاتك ومستنداتك الهامة' : 'Important files & documents';
  String get catCards => isArabic ? 'البطاقات المصرفية' : 'Payment Cards';
  String get catCardsSub => isArabic ? 'بطاقات الفيزا والماستركارد' : 'Credit & debit cards';
  String get catIdentities => isArabic ? 'الهويات والوثائق' : 'Identities & Documents';
  String get catIdentitiesSub => isArabic ? 'الجوازات والبطاقات الرسمية' : 'Passports & official IDs';

  // Unit
  String get itemsCount => isArabic ? 'عنصر' : 'items';
  String get singleItem => isArabic ? 'عنصر واحد' : '1 item';
  String get zeroItems => isArabic ? 'لا توجد عناصر' : 'No items';

  // ==================== AUTH ====================
  String get welcomeBack => isArabic ? 'أهلاً بك مجدداً' : 'Welcome Back';
  String get signInToVault => isArabic ? 'سجل دخولك للوصول إلى خزنتك' : 'Sign in to access your vault';
  String get createNewVault => isArabic ? 'إنشاء خزنة جديدة' : 'Create New Vault';
  String get createAccountSub => isArabic ? 'أنشئ حسابك لحماية ملفاتك وبياناتك' : 'Create an account to protect your data';
  String get emailLabel => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get emailHint => isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email address';
  String get passwordLabel => isArabic ? 'كلمة المرور' : 'Password';
  String get passwordHint => isArabic ? 'أدخل كلمة المرور' : 'Enter your password';
  String get confirmPasswordLabel => isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get confirmPasswordHint => isArabic ? 'أعد إدخال كلمة المرور' : 'Re-enter your password';
  String get nameLabel => isArabic ? 'الاسم الكامل' : 'Full Name';
  String get nameHint => isArabic ? 'أدخل اسمك الكامل' : 'Enter your full name';
  String get signInBtn => isArabic ? 'تسجيل الدخول' : 'Sign In';
  String get signUpBtn => isArabic ? 'إنشاء الحساب' : 'Create Account';
  String get forgotPassword => isArabic ? 'نسيت كلمة المرور؟' : 'Forgot password?';
  String get dontHaveAccount => isArabic ? 'ليس لديك حساب؟' : "Don't have an account?";
  String get alreadyHaveAccount => isArabic ? 'لديك حساب بالفعل؟' : 'Already have an account?';
  String get registerNow => isArabic ? 'سجل الآن' : 'Register now';
  String get loginNow => isArabic ? 'سجل دخولك' : 'Sign in';
  String get orSignInWith => isArabic ? 'أو الدخول عبر' : 'Or sign in with';
  String get signInWithGoogle => isArabic ? 'تسجيل الدخول باستخدام Google' : 'Sign in with Google';
  String get resetPasswordTitle => isArabic ? 'استعادة كلمة المرور' : 'Reset Password';
  String get resetPasswordDesc => isArabic ? 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين' : 'Enter your email to receive a password reset link';
  String get sendResetLink => isArabic ? 'إرسال الرابط' : 'Send Link';
  String get resetLinkSent => isArabic
      ? 'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني. يرجى تفقّد صندوق الوارد ومجلد Spam أو المهملات.'
      : 'Password reset link sent to your email. Please check your inbox and Spam folder.';

  // Auth Validation
  String get enterEmailVal => isArabic ? 'يرجى إدخال البريد الإلكتروني' : 'Please enter your email';
  String get validEmailVal => isArabic ? 'يرجى إدخال بريد إلكتروني صحيح' : 'Please enter a valid email';
  String get enterPasswordVal => isArabic ? 'يرجى إدخال كلمة المرور' : 'Please enter your password';
  String get passwordLengthVal => isArabic ? 'كلمة المرور يجب أن لا تقل عن 6 أحرف' : 'Password must be at least 6 characters';
  String get enterNameVal => isArabic ? 'يرجى إدخال الاسم' : 'Please enter your name';
  String get passwordMismatchVal => isArabic ? 'كلمتا المرور غير متطابقتين' : 'Passwords do not match';
  String get continueWithGoogle => isArabic ? 'المتابعة باستخدام Google' : 'Continue with Google';
  String get orDivider => isArabic ? 'أو' : 'OR';

  // Email Verification
  String get verifyEmailTitle => isArabic ? 'تأكيد البريد الإلكتروني' : 'Verify Your Email';
  String get verifyEmailSub => isArabic
      ? 'أرسلنا رابط تأكيد إلى بريدك الإلكتروني. يرجى فتح الرسالة والنقر على الرابط لتأكيد ملكية حسابك.'
      : 'We sent a verification link to your email. Please open the email and click the link to verify account ownership.';
  String get verifyEmailCheckNotice => isArabic
      ? 'بعد النقر على الرابط في بريدك، اضغط على زر "تم التحقق / متابعة" أدناه للدخول إلى خزنتك.'
      : 'After clicking the link in your email, click "I\'ve Verified / Continue" below to access your vault.';
  String get checkVerifiedBtn => isArabic ? 'تم التحقق / متابعة' : "I've Verified / Continue";
  String get resendVerificationBtn => isArabic ? 'إعادة إرسال الرابط' : 'Resend Verification Link';
  String get resendInSeconds => isArabic ? 'إعادة الإرسال بعد' : 'Resend in';
  String get secondsShort => isArabic ? 'ثانية' : 's';
  String get emailNotVerifiedYet => isArabic
      ? 'لم يتم تأكيد البريد بعد. يرجى فتح بريدك والضغط على الرابط أولاً.'
      : 'Email not verified yet. Please open your inbox and click the verification link first.';
  String get verificationLinkResent => isArabic
      ? 'تم إرسال رابط تأكيد جديد إلى بريدك الإلكتروني بنجاح.'
      : 'A new verification link has been sent to your email successfully.';
  String get changeEmailOrSignOut => isArabic ? 'تسجيل الخروج / استخدام بريد آخر' : 'Sign Out / Use Another Email';
  String get checkingVerification => isArabic ? 'جاري التحقق...' : 'Checking verification...';
  String get spamFolderNotice => isArabic
      ? 'ملاحظة: إذا لم تجد الرسالة في صندوق الوارد، يرجى تفقّد مجلد الرسائل غير المرغوب فيها (Spam) أو المهملات.'
      : 'Tip: If you don\'t see the email in your inbox, please check your Spam or Junk folder.';

  // ==================== SECURITY GATE ====================
  String get securityGateTitle => isArabic ? 'التحقق الأمني' : 'Security Verification';
  String get enterPinPrompt => isArabic
      ? 'أدخل رمز PIN ثم اضغط Enter أو ✓ للتأكيد'
      : 'Enter PIN then press Enter or ✓ to confirm';
  String get biometricPrompt => isArabic ? 'قم بالتحقق من هويتك للوصول إلى خزينتك' : 'Authenticate to access your vault';
  String get biometricFailed => isArabic ? 'فشل التحقق بالبصمة. حاول مرة أخرى' : 'Biometric authentication failed. Try again';
  String get incorrectPin => isArabic ? 'رمز PIN غير صحيح' : 'Incorrect PIN';
  String get remainingAttempts => isArabic ? 'المحاولات المتبقية' : 'Attempts remaining';
  String get maxAttemptsReached => isArabic ? 'تم تجاوز الحد المسموح. سيتم تسجيل الخروج' : 'Too many attempts. Signing out';
  String get useBiometricBtn => isArabic ? 'استخدام البصمة الحيوية' : 'Use Biometrics';
  String get usePinBtn => isArabic ? 'استخدام رمز PIN' : 'Use PIN Code';

  // ==================== NOTES ====================
  String get notesTitle => isArabic ? 'الملاحظات' : 'Notes';
  String get newNote => isArabic ? 'ملاحظة جديدة' : 'New Note';
  String get editNote => isArabic ? 'تعديل الملاحظة' : 'Edit Note';
  String get noteTitleHint => isArabic ? 'عنوان الملاحظة...' : 'Note title...';
  String get noteContentHint => isArabic ? 'اكتب ملاحظتك هنا...' : 'Write your note here...';
  String get pinNote => isArabic ? 'تثبيت في الأعلى' : 'Pin to top';
  String get unpinNote => isArabic ? 'إلغاء التثبيت' : 'Unpin note';
  String get deleteNote => isArabic ? 'حذف الملاحظة' : 'Delete Note';
  String get deleteNoteConfirm => isArabic ? 'هل تريد نقل هذه الملاحظة إلى سلة المحذوفات؟' : 'Move this note to trash?';
  String get noteColor => isArabic ? 'لون الملاحظة' : 'Note Color';
  String get emptyNotesTitle => isArabic ? 'لا توجد ملاحظات حتى الآن' : 'No notes yet';
  String get emptyNotesSub => isArabic ? 'انقر على زر الإضافة لتدوين أول ملاحظة مشفرة لك' : 'Click the add button to create your first encrypted note';

  // ==================== FILES & MEDIA ====================
  String get photosTitle => isArabic ? 'الصور المشفرة' : 'Encrypted Photos';
  String get videosTitle => isArabic ? 'الفيديوهات المشفرة' : 'Encrypted Videos';
  String get documentsTitle => isArabic ? 'المستندات المشفرة' : 'Encrypted Documents';
  String get uploadFile => isArabic ? 'رفع ملف' : 'Upload File';
  String get uploadPhoto => isArabic ? 'إضافة صورة' : 'Add Photo';
  String get uploadVideo => isArabic ? 'إضافة فيديو' : 'Add Video';
  String get uploadDocument => isArabic ? 'إضافة مستند' : 'Add Document';
  String get fileDetails => isArabic ? 'تفاصيل الملف' : 'File Details';
  String get fileName => isArabic ? 'اسم الملف' : 'File Name';
  String get fileSize => isArabic ? 'الحجم' : 'Size';
  String get fileDate => isArabic ? 'تاريخ الإضافة' : 'Date Added';
  String get deleteFile => isArabic ? 'حذف الملف' : 'Delete File';
  String get deleteFileConfirm => isArabic ? 'هل تريد نقل هذا الملف إلى سلة المحذوفات؟' : 'Move this file to trash?';
  String get emptyPhotosTitle => isArabic ? 'لا توجد صور بعد' : 'No photos yet';
  String get emptyPhotosSub => isArabic ? 'أضف صورك لحمايتها وتشفيرها بشكل آمن' : 'Add photos to protect and encrypt them securely';
  String get emptyVideosTitle => isArabic ? 'لا توجد فيديوهات بعد' : 'No videos yet';
  String get emptyVideosSub => isArabic ? 'أضف مقاطع الفيديو الخاصة بك لتأمينها' : 'Add videos to keep them private and safe';
  String get emptyDocsTitle => isArabic ? 'لا توجد مستندات بعد' : 'No documents yet';
  String get emptyDocsSub => isArabic ? 'احفظ ملفات PDF والمستندات الهامة هنا' : 'Save PDF and important documents securely here';
  String get uploadingFile => isArabic ? 'جاري رفع وتشفير الملف...' : 'Encrypting and uploading file...';
  String get decryptingFile => isArabic ? 'جاري فك التشفير والتحميل...' : 'Decrypting and loading file...';
  String get driveNotConnectedErr => isArabic ? 'Google Drive غير متصل. يرجى ربط حسابك أولاً.' : 'Google Drive is not connected. Please connect your account first.';

  // ==================== ACCOUNTS ====================
  String get accountsTitle => isArabic ? 'الحسابات وكلمات المرور' : 'Accounts & Passwords';
  String get newAccount => isArabic ? 'حساب جديد' : 'New Account';
  String get editAccount => isArabic ? 'تعديل الحساب' : 'Edit Account';
  String get serviceNameLabel => isArabic ? 'اسم الخدمة أو الموقع' : 'Service or Website Name';
  String get serviceNameHint => isArabic ? 'مثال: فيسبوك، جيميل، إنستغرام' : 'e.g. Google, GitHub, Netflix';
  String get usernameLabel => isArabic ? 'اسم المستخدم أو البريد' : 'Username or Email';
  String get usernameHint => isArabic ? 'أدخل اسم المستخدم أو البريد' : 'Enter username or email';
  String get notesOptional => isArabic ? 'ملاحظات إضافية (اختياري)' : 'Additional Notes (Optional)';
  String get notesOptionalHint => isArabic ? 'أدخل أي تفاصيل أو أرقام سرية إضافية' : 'Enter any additional details or hints';
  String get copyUsername => isArabic ? 'نسخ اسم المستخدم' : 'Copy Username';
  String get copyPassword => isArabic ? 'نسخ كلمة المرور' : 'Copy Password';
  String get copiedToClipboard => isArabic ? 'تم النسخ إلى الحافظة' : 'Copied to clipboard';
  String get showPassword => isArabic ? 'إظهار كلمة المرور' : 'Show Password';
  String get hidePassword => isArabic ? 'إخفاء كلمة المرور' : 'Hide Password';
  String get deleteAccount => isArabic ? 'حذف الحساب' : 'Delete Account';
  String get deleteAccountConfirm => isArabic ? 'هل تريد نقل هذا الحساب إلى سلة المحذوفات؟' : 'Move this account to trash?';
  String get emptyAccountsTitle => isArabic ? 'لا توجد حسابات مسجلة' : 'No saved accounts';
  String get emptyAccountsSub => isArabic ? 'احفظ كلمات مرورك وبيانات تسجيل الدخول بأمان تام' : 'Store your passwords and login credentials with total security';

  // ==================== SAFE WEBSITES ====================
  String get websitesTitle => isArabic ? 'المواقع الآمنة' : 'Safe Websites';
  String get newWebsite => isArabic ? 'موقع آمن جديد' : 'New Safe Website';
  String get editWebsite => isArabic ? 'تعديل الموقع' : 'Edit Safe Website';
  String get websiteNameLabel => isArabic ? 'اسم الموقع' : 'Website Name';
  String get websiteNameHint => isArabic ? 'مثال: البنك الإلكتروني، بوابة العمل' : 'e.g. Online Banking, Work Portal';
  String get websiteUrlLabel => isArabic ? 'رابط الموقع (URL)' : 'Website URL';
  String get websiteUrlHint => isArabic ? 'https://example.com' : 'https://example.com';
  String get openInBrowser => isArabic ? 'فتح في المتصفح' : 'Open in Browser';
  String get deleteWebsite => isArabic ? 'حذف الموقع' : 'Delete Website';
  String get deleteWebsiteConfirm => isArabic ? 'هل تريد نقل هذا الموقع إلى سلة المحذوفات؟' : 'Move this website to trash?';
  String get emptyWebsitesTitle => isArabic ? 'لا توجد مواقع آمنة بعد' : 'No safe websites yet';
  String get emptyWebsitesSub => isArabic ? 'أضف روابطك الحساسة مع بيانات تسجيل الدخول الخاصة بها' : 'Add sensitive web links along with your login credentials';

  // ==================== GALLERY ====================
  String get galleryTitle => isArabic ? 'الاستوديو المشفر' : 'Encrypted Media Gallery';
  String get tabAll => isArabic ? 'الكل' : 'All';
  String get tabPhotos => isArabic ? 'الصور' : 'Photos';
  String get tabVideos => isArabic ? 'الفيديوهات' : 'Videos';
  String get importPhotos => isArabic ? 'إضافة صور' : 'Add Photos';
  String get importVideos => isArabic ? 'إضافة فيديو' : 'Add Video';

  // ==================== PAYMENT CARDS ====================
  String get cardsTitle => isArabic ? 'البطاقات المصرفية' : 'Payment Cards';
  String get newCard => isArabic ? 'إضافة بطاقة جديدة' : 'Add New Card';
  String get editCard => isArabic ? 'تعديل البطاقة' : 'Edit Card';
  String get cardHolderLabel => isArabic ? 'اسم صاحب البطاقة' : 'Cardholder Name';
  String get cardHolderHint => isArabic ? 'الاسم كما هو مطبوع على البطاقة' : 'Name as printed on card';
  String get cardNumberLabel => isArabic ? 'رقم البطاقة' : 'Card Number';
  String get cardNumberHint => '•••• •••• •••• ••••';
  String get expiryDateLabel => isArabic ? 'تاريخ الانتهاء (MM/YY)' : 'Expiry Date (MM/YY)';
  String get expiryDateHint => 'MM/YY';
  String get cvvLabel => isArabic ? 'رمز الأمان (CVV)' : 'Security Code (CVV)';
  String get cvvHint => isArabic ? '3 أو 4 أرقام' : '3 or 4 digits';
  String get cardPinLabel => isArabic ? 'رمز PIN السري للصراف (اختياري)' : 'ATM PIN (Optional)';
  String get bankNameLabel => isArabic ? 'اسم البنك / المصرف' : 'Bank / Issuer Name';
  String get bankNameHint => isArabic ? 'مثال: بنك الرافدين، TBI، الأهلي' : 'e.g. Chase, TBI, Barclays';
  String get cardColorLabel => isArabic ? 'مظهر ولون البطاقة' : 'Card Theme Color';
  String get copyCardNumber => isArabic ? 'نسخ رقم البطاقة' : 'Copy Card Number';
  String get copyCvv => isArabic ? 'نسخ رمز CVV' : 'Copy CVV';
  String get showCvv => isArabic ? 'إظهار CVV' : 'Show CVV';
  String get hideCvv => isArabic ? 'إخفاء CVV' : 'Hide CVV';
  String get deleteCard => isArabic ? 'حذف البطاقة' : 'Delete Card';
  String get deleteCardConfirm => isArabic ? 'هل تريد نقل هذه البطاقة إلى سلة المحذوفات؟' : 'Move this card to trash?';
  String get emptyCardsTitle => isArabic ? 'لا توجد بطاقات مصرفية بعد' : 'No payment cards yet';
  String get emptyCardsSub => isArabic ? 'احفظ بطاقات الائتمان والخصم الخاصة بك بتشفير محكم ووصول سريع' : 'Safely store your credit and debit cards with bank-grade encryption';

  // ==================== IDENTITIES & OFFICIAL IDS ====================
  String get identitiesTitle => isArabic ? 'الهويات والوثائق الرسمية' : 'Identities & Official IDs';
  String get newIdentity => isArabic ? 'إضافة وثيقة جديدة' : 'Add New Document';
  String get editIdentity => isArabic ? 'تعديل الوثيقة' : 'Edit Document';
  String get idTitleLabel => isArabic ? 'عنوان الوثيقة' : 'Document Title';
  String get idTitleHint => isArabic ? 'مثال: جواز السفر، البطاقة الوطنية، رخصة القيادة' : 'e.g. Passport, National ID, Driver License';
  String get idTypeLabel => isArabic ? 'نوع الوثيقة' : 'Document Type';
  String get idTypePassport => isArabic ? 'جواز سفر' : 'Passport';
  String get idTypeNationalId => isArabic ? 'بطاقة وطنية / هوية أحوال' : 'National ID';
  String get idTypeDriverLicense => isArabic ? 'رخصة قيادة' : "Driver's License";
  String get idTypeResidency => isArabic ? 'بطاقة إقامة' : 'Residency Permit';
  String get idTypeOther => isArabic ? 'وثيقة أخرى' : 'Other Document';
  String get idFullNameLabel => isArabic ? 'الاسم الكامل بالوثيقة' : 'Full Name on Document';
  String get idFullNameHint => isArabic ? 'أدخل الاسم كما هو مكتوب في الوثيقة' : 'Enter full name as printed';
  String get idNumberLabel => isArabic ? 'رقم الوثيقة / الهوية' : 'Document Number';
  String get idNumberHint => isArabic ? 'أدخل رقم الهوية أو الجواز' : 'Enter ID or passport number';
  String get issueDateLabel => isArabic ? 'تاريخ الإصدار (اختياري)' : 'Issue Date (Optional)';
  String get idExpiryDateLabel => isArabic ? 'تاريخ الانتهاء (اختياري)' : 'Expiry Date (Optional)';
  String get frontImageLabel => isArabic ? 'صورة الوجه الأمامي' : 'Front Side Image';
  String get backImageLabel => isArabic ? 'صورة الوجه الخلفي' : 'Back Side Image';
  String get attachPhoto => isArabic ? 'إرفاق صورة' : 'Attach Photo';
  String get changePhoto => isArabic ? 'تغيير الصورة' : 'Change Photo';
  String get copyIdNumber => isArabic ? 'نسخ رقم الوثيقة' : 'Copy Document Number';
  String get deleteIdentity => isArabic ? 'حذف الوثيقة' : 'Delete Document';
  String get deleteIdentityConfirm => isArabic ? 'هل تريد نقل هذه الوثيقة إلى سلة المحذوفات؟' : 'Move this document to trash?';
  String get emptyIdentitiesTitle => isArabic ? 'لا توجد وثائق أو هويات بعد' : 'No documents or IDs yet';
  String get emptyIdentitiesSub => isArabic ? 'احفظ نسخاً مشفرة من جوازات سفرك وهوياتك للرجوع إليها في أي وقت' : 'Store encrypted copies of your official IDs and passports for instant offline access';
  String get statusExpired => isArabic ? 'منتهية الصلاحية' : 'Expired';
  String get statusExpiringSoon => isArabic ? 'تنتهي قريباً' : 'Expiring Soon';
  String get statusValid => isArabic ? 'سارية المفعول' : 'Valid';

  // ==================== TRASH ====================
  String get trashTitle => isArabic ? 'سلة المحذوفات' : 'Trash Bin';
  String get emptyTrashBtn => isArabic ? 'إفراغ السلة بالكامل' : 'Empty Trash';
  String get restoreItem => isArabic ? 'استعادة' : 'Restore';
  String get permanentDelete => isArabic ? 'حذف نهائي' : 'Delete Forever';
  String get emptyTrashConfirmTitle => isArabic ? 'تأكيد إفراغ السلة' : 'Empty Trash Confirmation';
  String get emptyTrashConfirmMsg => isArabic ? 'هل أنت متأكد من مسح جميع العناصر المحذوفة نهائياً؟ لا يمكن التراجع عن هذا الإجراء.' : 'Are you sure you want to permanently delete all items? This action cannot be undone.';
  String get permanentDeleteConfirm => isArabic ? 'هل أنت متأكد من الحذف النهائي لهذا العنصر؟ لا يمكن استعادته لاحقاً.' : 'Are you sure you want to permanently delete this item? It cannot be restored.';
  String get trashNotice => isArabic ? 'يتم الاحتفاظ بالعناصر في سلة المحذوفات لمدة 30 يوماً قبل مسحها تلقائياً' : 'Items in trash are automatically purged after 30 days';
  String get emptyTrashStateTitle => isArabic ? 'سلة المحذوفات فارغة' : 'Trash is empty';
  String get emptyTrashStateSub => isArabic ? 'أي عنصر تقوم بحذفه سينتقل إلى هنا مؤقتاً ويمكنك استعادته في أي وقت' : 'Any item you delete will be moved here temporarily and can be restored anytime';
  String get itemRestoredSuccess => isArabic ? 'تمت استعادة العنصر بنجاح' : 'Item restored successfully';
  String get itemPermanentlyDeleted => isArabic ? 'تم حذف العنصر نهائياً' : 'Item permanently deleted';

  // ==================== SEARCH ====================
  String get searchPlaceholder => isArabic ? 'ابحث في الملاحظات، الملفات، الحسابات...' : 'Search notes, files, accounts...';
  String get filterAll => isArabic ? 'الكل' : 'All';
  String get filterNotes => isArabic ? 'الملاحظات' : 'Notes';
  String get filterFiles => isArabic ? 'الملفات' : 'Files';
  String get filterAccounts => isArabic ? 'الحسابات' : 'Accounts';
  String get noSearchResults => isArabic ? 'لا توجد نتائج مطابقة' : 'No matching results';
  String get tryDifferentKeywords => isArabic ? 'جرب البحث باستخدام كلمات أخرى' : 'Try searching with different keywords';
  String get startTypingToSearch => isArabic ? 'ابدأ بالكتابة للبحث في كافة محتويات الخزنة' : 'Type keywords to search across your encrypted vault';

  // ==================== SETTINGS ====================
  String get settingsTitle => isArabic ? 'الإعدادات' : 'Settings';
  String get secAccount => isArabic ? 'الحساب والمزامنة' : 'Account & Sync';
  String get secSecurity => isArabic ? 'الأمان والحماية' : 'Security & Privacy';
  String get secPreferences => isArabic ? 'التفضيلات والمظهر' : 'Preferences & Appearance';
  String get secAbout => isArabic ? 'حول التطبيق' : 'About App';

  // Security settings
  String get appProtection => isArabic ? 'حماية التطبيق' : 'App Protection';
  String get appProtectionDesc => isArabic ? 'قفل الخزنة برمز PIN أو البصمة' : 'Lock vault with PIN or Biometrics';
  String get securityMethodTitle => isArabic ? 'طريقة القفل' : 'Lock Method';
  String get methodNone => isArabic ? 'بدون حماية' : 'None';
  String get methodPin => isArabic ? 'رمز PIN فقط' : 'PIN Code Only';
  String get methodBiometric => isArabic ? 'البصمة الحيوية فقط' : 'Biometrics Only';
  String get methodBoth => isArabic ? 'رمز PIN والبصمة معاً' : 'Both (PIN & Biometrics)';
  String get changePin => isArabic ? 'تغيير رمز PIN' : 'Change PIN Code';
  String get setNewPin => isArabic ? 'تعيين رمز PIN جديد' : 'Set New PIN Code';
  String get autoLockTimer => isArabic ? 'مؤقت القفل التلقائي' : 'Auto-lock Timer';
  String get lockImmediately => isArabic ? 'فوراً عند الخروج' : 'Immediately';
  String get lock1Min => isArabic ? 'بعد دقيقة واحدة' : 'After 1 minute';
  String get lock5Min => isArabic ? 'بعد 5 دقائق' : 'After 5 minutes';
  String get lock15Min => isArabic ? 'بعد 15 دقيقة' : 'After 15 minutes';
  String get lock30Min => isArabic ? 'بعد 30 دقيقة' : 'After 30 minutes';

  // Google Drive
  String get gdriveBackup => isArabic ? 'النسخ الاحتياطي على Google Drive' : 'Google Drive Cloud Backup';
  String get gdriveConnected => isArabic ? 'متصل ومحمي' : 'Connected & Encrypted';
  String get gdriveNotConnected => isArabic ? 'غير متصل' : 'Not Connected';
  String get connectDriveBtn => isArabic ? 'ربط Google Drive' : 'Connect Google Drive';
  String get disconnectDriveBtn => isArabic ? 'فصل الحساب السحابي' : 'Disconnect Drive';
  String get driveDisconnectConfirm => isArabic ? 'هل أنت متأكد من فصل Google Drive؟ لن تتمكن من رفع ملفات جديدة حتى إعادة الربط.' : 'Disconnect Google Drive? You will not be able to backup new files until reconnected.';

  // Theme & Language
  String get themeSetting => isArabic ? 'المظهر (الثيم)' : 'Appearance Theme';
  String get themeLight => isArabic ? 'الوضع النهاري' : 'Light Mode';
  String get themeDark => isArabic ? 'الوضع الليلي' : 'Dark Mode';
  String get languageSetting => isArabic ? 'لغة التطبيق' : 'Application Language';
  String get languageSettingDesc => isArabic ? 'اختر لغة الواجهة المفضلة لديك' : 'Choose your preferred interface language';

  // About & Sign out
  String get devCreditsTitle => isArabic ? 'فريق التطوير والحقوق' : 'Developer & Credits';
  String get developedBy => isArabic ? 'تطوير: مصطفى علي' : 'Developed by: Mustafa Ali';
  String get appVersionLabel => isArabic ? 'رقم الإصدار' : 'Version';
  String get signOutBtn => isArabic ? 'تسجيل الخروج' : 'Sign Out';
  String get signOutConfirmTitle => isArabic ? 'تأكيد تسجيل الخروج' : 'Sign Out Confirmation';
  String get signOutConfirmMsg => isArabic ? 'هل تريد تسجيل الخروج من حسابك في الخزنة؟' : 'Are you sure you want to sign out of your vault?';

  // ==================== GOOGLE DRIVE DIALOG ====================
  String get driveDialogTitle => isArabic ? 'النسخ السحابي المشفر' : 'Encrypted Cloud Backup';
  String get driveDialogSubtitle => isArabic ? 'استخدم مساحتك الشخصية على Google Drive' : 'Use your personal Google Drive storage';
  String get driveDialogPoint1Title => isArabic ? 'مساحتك الشخصية الخاصة' : 'Your Personal Private Space';
  String get driveDialogPoint1Desc => isArabic ? 'تُخزن ملفاتك في مجلد سري (appDataFolder) داخل حسابك، ولا أحد غيرك يستطيع الوصول إليها.' : 'Files are stored in a hidden app folder (appDataFolder) in your Drive, accessible only to you.';
  String get driveDialogPoint2Title => isArabic ? 'تشفير كامل قبل الرفع' : 'End-to-End Local Encryption';
  String get driveDialogPoint2Desc => isArabic ? 'يتم تشفير كافة صورك وفيديوهاتك ومستنداتك على جهازك قبل رفعها للسحاب.' : 'All photos, videos, and documents are encrypted on your device before uploading.';
  String get driveDialogPoint3Title => isArabic ? 'أنت صاحب القرار دائماً' : 'You are Always in Control';
  String get driveDialogPoint3Desc => isArabic ? 'يمكنك ربط الحساب الآن، أو التخطي والمتابعة واستخدام الخزنة محلياً.' : 'You can connect now, or skip and use your vault locally anytime.';
  String get driveDialogConnect => isArabic ? 'ربط حساب Google Drive الآن' : 'Connect Google Drive Now';
  String get driveDialogSkip => isArabic ? 'تخطي والمتابعة لاحقاً' : 'Skip & Continue Later';
  String get driveConnectedSuccess => isArabic ? 'تم ربط Google Drive بنجاح' : 'Google Drive connected successfully';

  // ==================== COMMON ACTIONS ====================
  String get save => isArabic ? 'حفظ' : 'Save';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get delete => isArabic ? 'حذف' : 'Delete';
  String get confirm => isArabic ? 'تأكيد' : 'Confirm';
  String get done => isArabic ? 'تم' : 'Done';
  String get close => isArabic ? 'إغلاق' : 'Close';
  String get back => isArabic ? 'رجوع' : 'Back';
  String get add => isArabic ? 'إضافة' : 'Add';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get loading => isArabic ? 'جاري التحميل...' : 'Loading...';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get success => isArabic ? 'تمت العملية بنجاح' : 'Operation successful';
  String get errorOccurred => isArabic ? 'حدث خطأ غير متوقع' : 'An unexpected error occurred';

  // ==================== PRIVACY POLICY & TERMS ====================
  String get privacyAndTermsNav => isArabic ? 'سياسة الخصوصية والاستخدام' : 'Privacy Policy & Terms';
  String get privacyPolicyTitle => isArabic ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get termsOfUseTitle => isArabic ? 'شروط الاستخدام' : 'Terms of Use';
  String get privacyDialogSubtitle => isArabic
      ? 'شفافية كاملة حول كيفية حفظ وتشفير وحماية بياناتك في الخزنة'
      : 'Full transparency on how your data is encrypted, stored, and protected';
  String get readOnWebsite => isArabic ? 'قراءة على الموقع الرسمي' : 'Read on Official Website';
  String get understoodAndAgree => isArabic ? 'فهمت وموافق' : 'I Understand';
}
