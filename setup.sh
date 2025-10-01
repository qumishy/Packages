#!/bin/bash

# =========================================================
# متغيرات التخصيص
# يجب عليك تحديث هذه القيم قبل تشغيل السكربت
# =========================================================
IMAGEBUILDER_DIR="openwrt-imagebuilder-23.05.6-ramips-mt7621.Linux-x86_64"  # عدّل هذا الاسم ليتطابق مع اسم مجلد ImageBuilder الفعلي
CUSTOM_HOSTNAME="ابو عياض"
PHONE_NUMBER="774372146"
LOGO_SOURCE="m.jpg" # تأكد من أن هذه الصورة موجودة في نفس مجلد السكربت
LOGO_DEST_NAME="logo.png"

# =========================================================
# التحقق من المتطلبات الأساسية
# =========================================================
if [ ! -d "$IMAGEBUILDER_DIR" ]; then
    echo "❌ خطأ: لم يتم العثور على مجلد ImageBuilder باسم: $IMAGEBUILDER_DIR"
    echo "يرجى تعديل قيمة IMAGEBUILDER_DIR في السكربت ليتطابق مع اسم مجلدك الفعلي."
    exit 1
fi

if [ ! -f "$LOGO_SOURCE" ]; then
    echo "⚠️ تحذير: لم يتم العثور على ملف اللوجو ($LOGO_SOURCE). سيتم إنشاء المسارات ولكن لن يتم نسخ اللوجو."
    echo "يرجى التأكد من وضع صورتك (m.jpg) في نفس المجلد قبل التشغيل."
fi

echo "🚀 بدء إعداد هيكل ملفات التخصيص داخل: $IMAGEBUILDER_DIR"
cd "$IMAGEBUILDER_DIR"

# =========================================================
# 1. إنشاء هيكل المجلدات files/
# =========================================================
echo "إنشاء هيكل المجلدات..."
mkdir -p files/etc/config
mkdir -p files/etc
mkdir -p files/usr/lib/lua/luci/{controller,view}
mkdir -p files/www/luci-static/argon/img

# =========================================================
# 2. إنشاء وتعديل ملفات الإعدادات (Hostname & Banner)
# =========================================================
echo "تطبيق تعديلات الاسم ورقم الهاتف..."

# a) تعديل اسم المضيف (Hostname) في /etc/config/system
cat > files/etc/config/system << EOF
config system
    option hostname '$CUSTOM_HOSTNAME'
    option timezone 'UTC'
    # يمكنك إضافة أي خيارات نظام افتراضية أخرى هنا
EOF
echo "✅ تم إنشاء ملف files/etc/config/system بالاسم الجديد."

# b) إضافة رقم الهاتف في ملف Banner
echo -e "مرحبًا بك في نظام $CUSTOM_HOSTNAME المخصص.\nللتواصل والدعم: $PHONE_NUMBER" > files/etc/banner
echo "✅ تم إنشاء ملف files/etc/banner."

# =========================================================
# 3. إنشاء ملفات صفحة "حولنا" (LuCI Controller & View)
# =========================================================
echo "إضافة صفحة 'حولنا' إلى LuCI..."

# a) LuCI Controller: يضيف الصفحة إلى القائمة الرئيسية (الترتيب 90)
cat > files/usr/lib/lua/luci/controller/about.lua << EOF
module("luci.controller.about", package.seeall)

function index()
    entry({"admin", "about"}, call("action_about"), _("About Us"), 90).leaf = true
end

function action_about()
    luci.template.render("about_page")
end
EOF
echo "✅ تم إنشاء ملف Controller (about.lua)."

# b) LuCI View: محتوى صفحة "حولنا"
cat > files/usr/lib/lua/luci/view/about_page.htm << EOF
<%+header%>
<h2><%:حول نظام $CUSTOM_HOSTNAME%></h2>
<div class="cbi-map-descr">
    <p>تم بناء هذا النظام خصيصاً لـ <strong>$CUSTOM_HOSTNAME</strong>.</p>
    <p>للدعم الفني والاستفسارات، يرجى الاتصال على الرقم: <strong>$PHONE_NUMBER</strong></p>
</div>
<%+footer%>
EOF
echo "✅ تم إنشاء ملف View (about_page.htm)."

# =========================================================
# 4. نسخ ملف اللوجو
# =========================================================
if [ -f "../$LOGO_SOURCE" ]; then
    cp "../$LOGO_SOURCE" "files/www/luci-static/argon/img/$LOGO_DEST_NAME"
    echo "✅ تم نسخ اللوجو ($LOGO_SOURCE) وتسميته ($LOGO_DEST_NAME)."
else
    echo "❌ لم يتم نسخ اللوجو. سيتم استخدام اللوجو الافتراضي لثيم Argon."
fi

# =========================================================
# 5. التوجيه لخطوة البناء
# =========================================================
echo "========================================================="
echo "✅ اكتمل إعداد الملفات بنجاح!"
echo "الآن، يمكنك تشغيل أمر البناء السريع ImageBuilder:"
echo ""
echo "make image PROFILE=\"[اسم الجهاز]\" PACKAGES=\"luci luci-theme-argon -ppp -ppp-mod-pppoe\" FILES=\"files/\""
echo ""
echo "لا تنس استبدال [اسم الجهاز] بملف تعريف جهازك الفعلي."
echo "========================================================="
