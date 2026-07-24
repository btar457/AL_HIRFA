// اختبارات آلية لقواعد Firestore (firestore.rules) عبر محاكي Firebase
// و @firebase/rules-unit-testing. تغطي بالضبط السيناريوهات المطلوبة في
// مهمة "تحصين قواعد Firestore" — لا تغطي كل قاعدة في الملف، فقط ما طُلب.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} from '@firebase/rules-unit-testing';
import {
  doc,
  getDoc,
  setDoc,
  updateDoc,
  deleteDoc,
} from 'firebase/firestore';

const PROJECT_ID = 'demo-al-hirfa';
let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync('../firestore.rules', 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

// -----------------------------------------------------------------------
// بيانات تأسيسية مشتركة — تُكتب مباشرة بتجاوز القواعد (withSecurityRulesDisabled)
// -----------------------------------------------------------------------
async function seedBaseFixtures() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, 'users/customerA'), {
      role: 'customer', name: 'مشتري أ', city: 'بغداد',
      isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
    });
    await setDoc(doc(db, 'users/artisanA'), {
      role: 'artisan', name: 'حرفي أ', city: 'بغداد',
      isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
    });
    await setDoc(doc(db, 'users/artisanB'), {
      role: 'artisan', name: 'حرفي ب', city: 'بغداد',
      isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
    });
    await setDoc(doc(db, 'users/shippingA'), {
      role: 'shipping', name: 'شركة أ', city: 'بغداد', provinces: ['بغداد'],
      isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
    });
    await setDoc(doc(db, 'users/shippingB'), {
      role: 'shipping', name: 'شركة ب', city: 'البصرة', provinces: ['البصرة'],
      isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
    });
    await setDoc(doc(db, 'users/adminA'), {
      role: 'admin', name: 'المدير', city: '',
      isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
    });
    await setDoc(doc(db, 'users/bannedA'), {
      role: 'customer', name: 'محظور', city: 'بغداد',
      isActive: false, banned: true, warningCount: 0, approvalStatus: 'approved',
    });

    await setDoc(doc(db, 'orders/orderX'), {
      buyerUid: 'customerA', artisanUid: 'artisanA', shippingUid: null,
      status: 'seller_approved',
      address: { governorate: 'بغداد', district: '', notes: '' },
      price: 20000, deliveryFee: 5000, totalAmount: 25000,
      platformFee: 2500, artisanEarnings: 17500, shippingEarnings: 4500,
      isReviewed: false, createdAt: new Date(),
    });
    await setDoc(doc(db, 'orders/orderPending'), {
      buyerUid: 'customerA', artisanUid: 'artisanA', shippingUid: null,
      status: 'pending',
      address: { governorate: 'بغداد', district: '', notes: '' },
      price: 20000, deliveryFee: 5000, totalAmount: 25000,
      platformFee: 2500, artisanEarnings: 17500, shippingEarnings: 4500,
      isReviewed: false, createdAt: new Date(),
    });

    await setDoc(doc(db, 'system_config/founder_lock'), {
      claimedBy: 'adminA', claimedAt: new Date(),
    });
  });
}

function ctx(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

// -----------------------------------------------------------------------
// بيانات تأسيسية إضافية للجولة الثانية من الاختبارات — لا تُعدَّل
// seedBaseFixtures أعلاه، فقط بيانات جديدة لسيناريوهات جديدة.
// -----------------------------------------------------------------------
async function seedRoundTwoFixtures() {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();

    await setDoc(doc(db, 'users/artisanPending'), {
      role: 'artisan', name: 'حرفي معلَّق', city: 'بغداد',
      isActive: true, banned: false, warningCount: 0, approvalStatus: 'pending',
    });
    await setDoc(doc(db, 'users/shippingPending'), {
      role: 'shipping', name: 'شركة معلَّقة', city: 'بغداد', provinces: ['بغداد'],
      isActive: true, banned: false, warningCount: 0, approvalStatus: 'pending',
    });

    await setDoc(doc(db, 'orders/orderDelivered'), {
      buyerUid: 'customerA', artisanUid: 'artisanA', shippingUid: 'shippingA',
      status: 'delivered',
      address: { governorate: 'بغداد', district: '', notes: '' },
      price: 20000, deliveryFee: 5000, totalAmount: 25000,
      platformFee: 2500, artisanEarnings: 17500, shippingEarnings: 4500,
      isReviewed: false, createdAt: new Date(), deliveredAt: new Date(),
    });

    await setDoc(doc(db, 'settlements/settlementA'), {
      shippingUid: 'shippingA', weekStart: new Date(), weekEnd: new Date(),
      deliveriesCount: 1, totalEarnings: 4500, platformDue: 500,
      status: 'pending', penaltyAmount: 0, createdAt: new Date(),
    });

    await setDoc(doc(db, 'app_config/rules'), {
      productCommission: 0.1, shippingCommission: 0.1, fixedDeliveryFee: 5000,
    });

    await setDoc(doc(db, 'products/productPending'), {
      artisanUid: 'artisanA', name: 'منتج معلَّق', description: '', price: 10000,
      category: 'other', city: 'بغداد', images: [], narrative: '', material: '',
      originPlace: '', technique: '', status: 'pending', rating: 0, reviewCount: 0,
      salesCount: 0, createdAt: new Date(),
    });

    await setDoc(doc(db, 'users/artisanA/private/contact'), { phone: '07701234567' });
  });
}

// =========================================================================
// 1) مستخدم يرقّي نفسه إلى admin عبر update
// =========================================================================
test('رفض: مستخدم يرقّي نفسه إلى admin عبر update', async () => {
  await seedBaseFixtures();
  const db = ctx('customerA');
  await assertFails(updateDoc(doc(db, 'users/customerA'), { role: 'admin' }));
});

// =========================================================================
// 2) حرفي/شركة شحن يسجّل نفسه بحالة معتمَدة مباشرة
// =========================================================================
test('رفض: حرفي يسجّل نفسه بحالة approved مباشرة عند الإنشاء', async () => {
  await seedBaseFixtures();
  const db = ctx('newArtisan');
  await assertFails(setDoc(doc(db, 'users/newArtisan'), {
    role: 'artisan', name: 'حرفي جديد', city: 'بغداد',
    isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
  }));
});

test('رفض: شركة شحن تسجّل نفسها بحالة approved مباشرة عند الإنشاء', async () => {
  await seedBaseFixtures();
  const db = ctx('newShipping');
  await assertFails(setDoc(doc(db, 'users/newShipping'), {
    role: 'shipping', name: 'شركة جديدة', city: 'بغداد', provinces: ['بغداد'],
    isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
  }));
});

// =========================================================================
// 3) حرفي يعدّل طلباً لا يخصه
// =========================================================================
test('رفض: حرفي يعدّل طلباً لا يخصه (يخص حرفياً آخر)', async () => {
  await seedBaseFixtures();
  const db = ctx('artisanB'); // ليس مالك orderPending (مالكه artisanA)
  await assertFails(updateDoc(doc(db, 'orders/orderPending'), {
    status: 'seller_approved',
    shippingAcceptDeadline: new Date(),
  }));
});

// =========================================================================
// 4) شركة شحن تقرأ خارج محافظات تغطيتها
// =========================================================================
test('رفض: شركة شحن تقرأ طلباً خارج محافظات تغطيتها', async () => {
  await seedBaseFixtures();
  // orderX في محافظة بغداد، shippingB مغطّاة فقط للبصرة، وليست طرفاً في الطلب.
  const db = ctx('shippingB');
  await assertFails(getDoc(doc(db, 'orders/orderX')));
});

// =========================================================================
// 5) مستخدم يكتب حقل العمولة أو حالة الطلب مباشرة
// =========================================================================
test('رفض: المشتري (مالك الطلب) يكتب حقل platformFee مباشرة', async () => {
  await seedBaseFixtures();
  const db = ctx('customerA'); // مالك الطلب فعلياً كمشترٍ
  await assertFails(updateDoc(doc(db, 'orders/orderX'), { platformFee: 999999 }));
});

test('رفض: الحرفي (مالك الطلب) يغيّر status مباشرة إلى delivered متجاوزاً الشحن', async () => {
  await seedBaseFixtures();
  const db = ctx('artisanA'); // مالك orderX كحرفي
  await assertFails(updateDoc(doc(db, 'orders/orderX'), { status: 'delivered' }));
});

// =========================================================================
// 6) حساب موقوف يقرأ
// =========================================================================
test('رفض: حساب موقوف/محظور يقرأ وثيقة مستخدم (حتى وثيقته هو)', async () => {
  await seedBaseFixtures();
  const db = ctx('bannedA');
  await assertFails(getDoc(doc(db, 'users/bannedA')));
});

test('رفض: حساب موقوف/محظور يقرأ وثيقة مستخدم آخر', async () => {
  await seedBaseFixtures();
  const db = ctx('bannedA');
  await assertFails(getDoc(doc(db, 'users/artisanA')));
});

// =========================================================================
// 7) حذف founder_lock
// =========================================================================
test('رفض: حذف system_config/founder_lock من قبل صاحبه (claimedBy)', async () => {
  await seedBaseFixtures();
  const db = ctx('adminA'); // adminA هو claimedBy فعلياً
  await assertFails(deleteDoc(doc(db, 'system_config/founder_lock')));
});

test('رفض: حذف system_config/founder_lock من قبل طرف آخر', async () => {
  await seedBaseFixtures();
  const db = ctx('customerA');
  await assertFails(deleteDoc(doc(db, 'system_config/founder_lock')));
});

// =========================================================================
// 8) المسارات الشرعية المسموحة لكل دور
// =========================================================================
test('سماح: مشترٍ ينشئ حسابه الخاص بدور customer', async () => {
  await seedBaseFixtures();
  const db = ctx('newCustomer');
  await assertSucceeds(setDoc(doc(db, 'users/newCustomer'), {
    role: 'customer', name: 'مشترٍ جديد', city: 'بغداد',
    isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
  }));
});

test('سماح: حرفي ينشئ حسابه الخاص بحالة pending (المسار الشرعي)', async () => {
  await seedBaseFixtures();
  const db = ctx('newArtisan');
  await assertSucceeds(setDoc(doc(db, 'users/newArtisan'), {
    role: 'artisan', name: 'حرفي جديد', city: 'بغداد',
    isActive: true, banned: false, warningCount: 0, approvalStatus: 'pending',
  }));
});

test('سماح: شركة شحن تنشئ حسابها الخاص بحالة pending (المسار الشرعي)', async () => {
  await seedBaseFixtures();
  const db = ctx('newShipping');
  await assertSucceeds(setDoc(doc(db, 'users/newShipping'), {
    role: 'shipping', name: 'شركة جديدة', city: 'بغداد', provinces: ['بغداد'],
    isActive: true, banned: false, warningCount: 0, approvalStatus: 'pending',
  }));
});

test('سماح: الإدارة تغيّر دور مستخدم (المسار الشرعي الوحيد لتغيير role)', async () => {
  await seedBaseFixtures();
  const db = ctx('adminA');
  await assertSucceeds(updateDoc(doc(db, 'users/artisanB'), { role: 'admin' }));
});

test('سماح: مستخدم نشط غير محظور يقرأ وثيقة مستخدم آخر', async () => {
  await seedBaseFixtures();
  const db = ctx('customerA');
  await assertSucceeds(getDoc(doc(db, 'users/artisanA')));
});

test('سماح: الحرفي مالك الطلب يوافق عليه (pending -> seller_approved)', async () => {
  await seedBaseFixtures();
  const db = ctx('artisanA'); // مالك orderPending فعلياً
  await assertSucceeds(updateDoc(doc(db, 'orders/orderPending'), {
    status: 'seller_approved',
    shippingAcceptDeadline: new Date(),
  }));
});

test('سماح: شركة شحن ضمن نطاق تغطيتها تقرأ الطلب وتقبله', async () => {
  await seedBaseFixtures();
  const db = ctx('shippingA'); // مغطّاة لمحافظة بغداد (نفس orderX)
  await assertSucceeds(getDoc(doc(db, 'orders/orderX')));
  await assertSucceeds(updateDoc(doc(db, 'orders/orderX'), {
    status: 'shipping_assigned',
    shippingUid: 'shippingA',
    shippingCompanyName: 'شركة أ',
    shippingAssignedAt: new Date(),
  }));
});

test('سماح: مستخدم جديد يؤسّس حساب المؤسس عندما لا يوجد قفل بعد', async () => {
  // بلا seedBaseFixtures هنا عمداً — لا يوجد founder_lock إطلاقاً بعد clearFirestore().
  const db = ctx('firstFounder');
  await assertSucceeds(setDoc(doc(db, 'system_config/founder_lock'), {
    claimedBy: 'firstFounder', claimedAt: new Date(),
  }));
  await assertSucceeds(setDoc(doc(db, 'users/firstFounder'), {
    role: 'admin', name: 'المؤسس', city: '',
    isActive: true, banned: false, warningCount: 0, approvalStatus: 'approved',
  }));
});

// =========================================================================
// الجولة الثانية — اختبارات إضافية (تكملة لمهمة اختبارات القواعد)
// =========================================================================

// --- اختبارات تعديل (update) — كلها يجب أن تُرفض ---

test('رفض: حرفي بحالة pending يعدّل وثيقته إلى approved', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('artisanPending');
  await assertFails(updateDoc(doc(db, 'users/artisanPending'), { approvalStatus: 'approved' }));
});

test('رفض: شركة شحن بحالة pending تعدّل وثيقتها إلى approved', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('shippingPending');
  await assertFails(updateDoc(doc(db, 'users/shippingPending'), { approvalStatus: 'approved' }));
});

test('رفض: مستخدم customer يغيّر role إلى shipping', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('customerA');
  await assertFails(updateDoc(doc(db, 'users/customerA'), { role: 'shipping' }));
});

test('رفض: مستخدم customer يغيّر role إلى artisan', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('customerA');
  await assertFails(updateDoc(doc(db, 'users/customerA'), { role: 'artisan' }));
});

test('رفض: حساب موقوف يكتب أي وثيقة (لا يقرأ فقط)', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('bannedA');
  await assertFails(updateDoc(doc(db, 'users/bannedA'), { photoUrl: 'https://example.com/x.png' }));
});

test('رفض: حساب موقوف يعدّل حقل حالة الحظر عن نفسه', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('bannedA');
  await assertFails(updateDoc(doc(db, 'users/bannedA'), { banned: false, isActive: true }));
});

// --- مجموعات غير مغطّاة — رفض ---

test('رفض: حرفي يكتب رصيد محفظته مباشرة عبر إنشاء transaction وهمية', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('artisanA');
  await assertFails(setDoc(doc(db, 'transactions/txFake'), {
    orderId: 'orderDelivered', type: 'sale', amount: 999999,
    fromUid: 'customerA', toUid: 'artisanA', status: 'completed', createdAt: new Date(),
  }));
});

test('رفض: شركة شحن تغيّر حالة تسويتها إلى paid', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('shippingA');
  await assertFails(updateDoc(doc(db, 'settlements/settlementA'), { status: 'paid' }));
});

test('رفض: أي عميل يكتب في transactions', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('customerA');
  await assertFails(setDoc(doc(db, 'transactions/txFake2'), {
    orderId: 'orderDelivered', type: 'sale', amount: 17500,
    fromUid: 'customerA', toUid: 'artisanA', status: 'completed', createdAt: new Date(),
  }));
});

test('رفض: غير-مدير يعدّل نسبة العمولة أو سعر التوصيل في الإعدادات', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('customerA');
  await assertFails(updateDoc(doc(db, 'app_config/rules'), { productCommission: 0.5 }));
});

test('رفض: حرفي ينقل منتجه من pending إلى active مباشرة', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('artisanA');
  await assertFails(updateDoc(doc(db, 'products/productPending'), { status: 'active' }));
});

test('رفض: مستخدم يقرأ المجموعة الفرعية للهاتف/IBAN لمستخدم آخر', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('artisanB');
  await assertFails(getDoc(doc(db, 'users/artisanA/private/contact')));
});

// --- سماح (تحقّق من عدم الإفراط في التقييد) ---

test('سماح: الحرفي يقرأ مجموعته الفرعية الخاصة به (private/contact)', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('artisanA');
  await assertSucceeds(getDoc(doc(db, 'users/artisanA/private/contact')));
});

test('سماح: الإدارة تنقل منتجاً من pending إلى active', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('adminA');
  await assertSucceeds(updateDoc(doc(db, 'products/productPending'), { status: 'active' }));
});

// =========================================================================
// طلب المستخدم: سدّ ثغرة تكرار transactions لنفس orderId+type — المعرّف
// الحتمي (orderId_type) بدل doc() العشوائي في order_service.dart.
// =========================================================================
test('رفض: معاملة sale مكرَّرة لنفس orderId+type عبر معرّف عشوائي ثانٍ', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('shippingA');
  const validData = {
    orderId: 'orderDelivered', type: 'sale', amount: 17500,
    fromUid: 'customerA', toUid: 'artisanA', status: 'completed', createdAt: new Date(),
  };
  // المعرّف الحتمي الصحيح — ينجح دائماً (قبل الإصلاح وبعده).
  await assertSucceeds(setDoc(doc(db, 'transactions/orderDelivered_sale'), validData));
  // محاولة ثانية بمعرّف عشوائي مختلف تماماً لنفس orderId+type — يحاكي
  // doc() العشوائي قبل الإصلاح. قبل الإصلاح: تنجح أيضاً (لا فحص تكرار) —
  // هذا بالضبط ما يجعل هذا السطر فاشلاً قبل تطبيق الإصلاح. بعد الإصلاح:
  // السطر الجديد في create يفرض transactionId == orderId+'_'+type،
  // و'randomIdTwo' لا يطابقه أبداً → رفض.
  await assertFails(setDoc(doc(db, 'transactions/randomIdTwo'), validData));
  // إعادة الكتابة على المعرّف الحتمي نفسه بعد نجاحه = update (وثيقة موجودة)
  // وهي if false أصلاً — محمية بغضّ النظر عن هذا الإصلاح، مذكورة هنا لتوثيق
  // الآلية الكاملة كما وصفها المستخدم: "المحاولة الثانية تصبح update".
  await assertFails(setDoc(doc(db, 'transactions/orderDelivered_sale'), validData));
});

// =========================================================================
// طلب المستخدم: اختباران إضافيان لتكامل transactions
// =========================================================================
test('توثيق سلوك حالي (لا يُصلَح الآن): شركة الشحن تحدّث الطلب إلى delivered دون كتابة المعاملات', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  const db = ctx('shippingA');
  // orderX بحالة seller_approved، shippingUid فارغ — نجعله picked_up أولاً
  // ثم delivered، دون إنشاء أي وثيقة transactions مقابلة، لنثبت أن قاعدة
  // orders/update لا تفرض إطلاقاً كتابة المعاملات الثلاث كإجراء ذرّي واحد
  // (order_service.dart: confirmDelivery و_createDeliveryTransactions
  // كتابتان منفصلتان فعلياً، غير مضمونتين معاً — راجع تقرير التدقيق التكميلي).
  await assertSucceeds(updateDoc(doc(db, 'orders/orderX'), {
    status: 'shipping_assigned', shippingUid: 'shippingA',
    shippingCompanyName: 'شركة أ', shippingAssignedAt: new Date(),
  }));
  await assertSucceeds(updateDoc(doc(db, 'orders/orderX'), { status: 'picked_up' }));
  await assertSucceeds(updateDoc(doc(db, 'orders/orderX'), { status: 'delivered', deliveredAt: new Date() }));
});

test('رفض: طرف ثالث ليس shippingUid الطلب ينشئ معاملة delivery لنفسه', async () => {
  await seedBaseFixtures();
  await seedRoundTwoFixtures();
  // orderDelivered معيَّن فعلياً لـ shippingA — shippingB ليس طرفاً فيه إطلاقاً.
  const db = ctx('shippingB');
  await assertFails(setDoc(doc(db, 'transactions/orderDelivered_delivery_fake'), {
    orderId: 'orderDelivered', type: 'delivery', amount: 4500,
    fromUid: 'customerA', toUid: 'shippingB', status: 'completed', createdAt: new Date(),
  }));
});
