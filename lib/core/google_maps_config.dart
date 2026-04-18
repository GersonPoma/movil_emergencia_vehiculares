// Este archivo contiene la configuración de Google Maps para la aplicación
// Reemplaza YOUR_GOOGLE_MAPS_API_KEY con tu clave real de Google Maps API

class GoogleMapsConfig {
  // Clave de API de Google Maps para Android
  // Obtén esta clave en: https://developers.google.com/maps/documentation/android-sdk/get-api-key
  static const String androidApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Clave de API de Google Maps para iOS
  // Obtén esta clave en: https://developers.google.com/maps/documentation/ios-sdk/get-api-key
  static const String iosApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Ubicación por defecto (Ejemplo: Centro de una ciudad)
  static const double defaultLatitude = 40.7128;
  static const double defaultLongitude = -74.0060;

  // Nivel de zoom por defecto para el mapa
  static const double defaultZoomLevel = 15.0;
}

/// INSTRUCCIONES PARA CONFIGURAR GOOGLE MAPS:
///
/// 1. PARA ANDROID (android/app/build.gradle):
///    - Asegúrate de tener minSdkVersion 21 o superior
///    - Agrega la siguiente línea en android/AndroidManifest.xml dentro de <application>:
///      <meta-data
///        android:name="com.google.android.geo.API_KEY"
///        android:value="YOUR_GOOGLE_MAPS_API_KEY" />
///
/// 2. PARA iOS (ios/Runner/Info.plist):
///    - Agrega las siguientes líneas:
///      <key>NSLocationWhenInUseUsageDescription</key>
///      <string>Esta aplicación necesita acceso a tu ubicación para enviar emergencias.</string>
///      <key>com.google.ios.maps.API_KEY</key>
///      <string>YOUR_GOOGLE_MAPS_API_KEY</string>
///
/// 3. OBTENER LA CLAVE DE API:
///    - Ve a https://console.cloud.google.com
///    - Crea un nuevo proyecto o selecciona uno existente
///    - Habilita las APIs: Maps SDK for Android y Maps SDK for iOS
///    - Ve a Credenciales y crea una nueva clave de API
///    - Restringe la clave según sea necesario
///
/// 4. PERMISOS REQUERIDOS:
///    - Android: Agrega permisos en AndroidManifest.xml
///    - iOS: Agrega descripciones de uso en Info.plist
