# Reglas específicas para Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Mantener clases nativas
-keepclasseswithmembernames class * {
    native <methods>;
}

# Mantener clases de la aplicación
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# Para plugins comunes de Flutter
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keep class androidx.lifecycle.DefaultLifecycleObserver

# ✅ NUEVAS REGLAS PARA PLAY CORE (Solucionan tu error actual)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.tasks.** { *; }
-keep class com.google.android.play.splitinstall.** { *; }
-keep class com.google.android.play.splitcompat.** { *; }

# Reglas específicas para las clases mencionadas en el error
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Mantener todas las clases de Play Core referenciadas
-keep class com.google.android.play.** { *; }

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.gemalto.jp2.JP2Decoder
-dontwarn com.gemalto.jp2.JP2Encoder


# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn org.spongycastle.asn1.ASN1Encodable
-dontwarn org.spongycastle.asn1.ASN1InputStream
-dontwarn org.spongycastle.asn1.ASN1Integer
-dontwarn org.spongycastle.asn1.ASN1ObjectIdentifier
-dontwarn org.spongycastle.asn1.ASN1OctetString
-dontwarn org.spongycastle.asn1.ASN1Primitive
-dontwarn org.spongycastle.asn1.ASN1Set
-dontwarn org.spongycastle.asn1.DEROctetString
-dontwarn org.spongycastle.asn1.DEROutputStream
-dontwarn org.spongycastle.asn1.DERSet
-dontwarn org.spongycastle.asn1.cms.ContentInfo
-dontwarn org.spongycastle.asn1.cms.EncryptedContentInfo
-dontwarn org.spongycastle.asn1.cms.EnvelopedData
-dontwarn org.spongycastle.asn1.cms.IssuerAndSerialNumber
-dontwarn org.spongycastle.asn1.cms.KeyTransRecipientInfo
-dontwarn org.spongycastle.asn1.cms.OriginatorInfo
-dontwarn org.spongycastle.asn1.cms.RecipientIdentifier
-dontwarn org.spongycastle.asn1.cms.RecipientInfo
-dontwarn org.spongycastle.asn1.pkcs.PKCSObjectIdentifiers
-dontwarn org.spongycastle.asn1.x500.X500Name
-dontwarn org.spongycastle.asn1.x509.AlgorithmIdentifier
-dontwarn org.spongycastle.asn1.x509.SubjectPublicKeyInfo
-dontwarn org.spongycastle.asn1.x509.TBSCertificateStructure
-dontwarn org.spongycastle.cert.X509CertificateHolder
-dontwarn org.spongycastle.cms.CMSEnvelopedData
-dontwarn org.spongycastle.cms.Recipient
-dontwarn org.spongycastle.cms.RecipientId
-dontwarn org.spongycastle.cms.RecipientInformation
-dontwarn org.spongycastle.cms.RecipientInformationStore
-dontwarn org.spongycastle.cms.jcajce.JceKeyTransEnvelopedRecipient
-dontwarn org.spongycastle.cms.jcajce.JceKeyTransRecipient
-dontwarn org.spongycastle.crypto.BlockCipher
-dontwarn org.spongycastle.crypto.CipherParameters
-dontwarn org.spongycastle.crypto.engines.AESFastEngine
-dontwarn org.spongycastle.crypto.modes.CBCBlockCipher
-dontwarn org.spongycastle.crypto.paddings.PaddedBufferedBlockCipher
-dontwarn org.spongycastle.crypto.params.KeyParameter
-dontwarn org.spongycastle.crypto.params.ParametersWithIV