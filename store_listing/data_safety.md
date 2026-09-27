# مسودة إجابات نموذج Data Safety — Google Play Console

استبيان "أمان البيانات" في Play Console تفاعلي (أسئلة متتالية وليس
حقل نص)، لذا هذا الملف مرجع لتعبئته بسرعة دون الحاجة لإعادة تحليل
الكود كل مرة. الأسماء بالإنجليزية كما تظهر فعلياً في واجهة Console.

## Does your app collect or share any of the required user data types?
**Yes.**

## Is all of the user data collected by your app encrypted in transit?
**Yes** — كل الاتصالات عبر Firebase (Firestore/Auth/Storage) وCloudflare R2 تمر عبر HTTPS/TLS.

## Do you provide a way for users to request that their data is deleted?
**Yes** — رابط: `https://al-hirfa.web.app/privacy` (قسم "حذف الحساب وبياناتك")، بالإضافة لمسار داخل التطبيق (الملف الشخصي ← حذف الحساب).

---

## أنواع البيانات (Data types)

### Personal info
| النوع | مُجمَّع؟ | مُشارَك؟ | الغرض | إلزامي/اختياري |
|---|---|---|---|---|
| Name | نعم | لا | App functionality, Account management | إلزامي |
| Email address | نعم | لا | App functionality, Account management | إلزامي |
| Phone number | نعم | لا | App functionality, Account management | إلزامي |
| Address (المدينة فقط، ليس عنواناً دقيقاً) | نعم | لا | App functionality | إلزامي |

### Financial info
| النوع | مُجمَّع؟ | مُشارَك؟ | الغرض | إلزامي/اختياري |
|---|---|---|---|---|
| User payment info — رقم الحساب البنكي (IBAN) | نعم (للحرفيين/شركات الشحن فقط) | لا | App functionality (استلام مستحقات العمولة خارج التطبيق) | اختياري (فقط لمن يريد استلام مستحقات) |

> **ملاحظة**: لا يعالج التطبيق أي دفع إلكتروني مباشر ولا يخزّن بيانات
> بطاقات ائتمانية — IBAN يُستخدم فقط كمرجع تحويل بنكي يدوي من الإدارة.

### Photos and videos
| النوع | مُجمَّع؟ | مُشارَك؟ | الغرض | إلزامي/اختياري |
|---|---|---|---|---|
| Photos | نعم | لا | App functionality (صورة الملف الشخصي، صور المنتجات) | اختياري للزبون، إلزامي للحرفي عند نشر منتج |

### App activity
| النوع | مُجمَّع؟ | مُشارَك؟ | الغرض | إلزامي/اختياري |
|---|---|---|---|---|
| App interactions (الطلبات، المفضلة، التقييمات) | نعم | لا | App functionality | إلزامي لوظائف الشراء |

### App info and performance
| النوع | مُجمَّع؟ | مُشارَك؟ | الغرض | إلزامي/اختياري |
|---|---|---|---|---|
| Crash logs | نعم (Firebase Crashlytics) | لا | Analytics (تحسين استقرار التطبيق) | إلزامي (تلقائي) |
| Diagnostics | نعم (Firebase Crashlytics) | لا | Analytics | إلزامي (تلقائي) |

### Device or other IDs
| النوع | مُجمَّع؟ | مُشارَك؟ | الغرض | إلزامي/اختياري |
|---|---|---|---|---|
| Device or other IDs — رمز إشعارات FCM | نعم | لا | App functionality (إشعارات الطلبات) | إلزامي |

---

## بخصوص "المشاركة مع أطراف ثالثة" (Data sharing)

الإجابة الصحيحة على "Is any of this data shared with third parties؟"
هي **لا** من الناحية العملية: Firebase (Google) وCloudflare R2 يُصنَّفان
عادةً في تصنيف Google كـ **"Service providers"** (يعالجون البيانات
نيابة عنك لتشغيل التطبيق فقط، لا لأغراضهم الخاصة)، وليس "third-party
sharing" بالمعنى الذي يتطلب الإفصاح كمشاركة. Play Console يوضّح هذا
الفرق داخل الاستبيان نفسه بأمثلة — راجعه عند التعبئة للتأكد.
