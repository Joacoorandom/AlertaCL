# AlertaCL

App iOS de **alertas sísmicas para Chile** (estilo monitoreo tipo SASMEX), escrita en **SwiftUI + Liquid Glass (iOS 26)**.

## Qué incluye

- Lista de sismos recientes (USGS FDSN, bounding box Chile)
- Mapa MapKit con pines por magnitud
- Notificaciones locales (time-sensitive / critical si Apple otorga entitlement)
- Demos de alertas por severidad
- Guía rápida SENAPRED / CSN
- IPA **sin firmar** vía GitHub Actions para instalar con **Sideloadly**

## Requisitos

- iPhone/iPad con **iOS 26+**
- Sideloadly (o AltStore) + Apple ID
- Para Critical Alerts *reales*: entitlement `com.apple.developer.usernotifications.critical-alerts` aprobado por Apple (no disponible en sideload típico)

## Descargar IPA

1. Andá a [Releases](https://github.com/Joacoorandom/AlertaCL/releases/latest)
2. Descargá `AlertaCL-unsigned.ipa`
3. O escaneá el QR en la [página de descarga](https://joacoorandom.github.io/AlertaCL/)

### Sideloadly

1. Abrí Sideloadly en Windows/macOS
2. Conectá el iPhone
3. Arrastrá el IPA
4. Iniciá sesión con tu Apple ID
5. Start → en el iPhone: **Ajustes → General → VPN y gestión de dispositivos → Confiar**

## Desarrollo

```bash
brew install xcodegen
xcodegen generate
open AlertaCL.xcodeproj
```

Deployment target: **iOS 26.0** (`.glassEffect`, `GlassEffectContainer`).

## Disclaimer

AlertaCL es un prototipo comunitario. **No reemplaza** avisos oficiales de SENAPRED, CSN, ni sistemas gubernamentales de alerta temprana.
