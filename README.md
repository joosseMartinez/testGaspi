# testGaspi

App de búsqueda de productos en SwiftUI, con arquitectura Clean + Repository Pattern + Coordinators. Target mínimo: iOS 16.

## Configuración antes de correr el proyecto

El cliente HTTP necesita una API key de RapidAPI para consultar el servicio de Axesso Walmart Data Service, y esa key **no está en el repo** (se ignora por git para no exponerla).

1. Copia `testGaspi/App/Secrets.swift.example` a `testGaspi/App/Secrets.swift` (mismo folder).
2. Abre `Secrets.swift` y coloca la API key real en `rapidAPIKey`:

   ```swift
   enum Secrets {
       /// x-rapidapi-key for https://axesso-walmart-data-service.p.rapidapi.com
       static let rapidAPIKey = "TU_API_KEY_AQUI"
   }
   ```

3. Como el proyecto usa grupos sincronizados de Xcode (`PBXFileSystemSynchronizedRootGroup`), no hace falta agregar el archivo manualmente al target: en cuanto existe en esa carpeta, Xcode lo compila.

Sin este paso, el proyecto compila pero las búsquedas fallan (la API responde con error de autenticación).

## Correr el proyecto

Abre `testGaspi.xcodeproj` en Xcode y ejecuta el target `testGaspi` en un simulador o dispositivo con iOS 16+.

## Correr los tests

Target `testGaspiTests` (⌘U en Xcode, o `xcodebuild test` desde línea de comandos). Son unit tests de lógica (Domain, Data, Presentation) — no incluyen tests de UI/Views.
