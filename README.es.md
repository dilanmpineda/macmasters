# MacMasters

[English](README.md) · **Español** · [Português](README.pt-BR.md)

Una app gratuita y no oficial para jugar **Digimon Masters Online** en macOS. La abres, instalas el juego una vez y juegas. No necesitas licencia de CrossOver ni Windows.

> Proyecto no oficial, sin relación con Move Games, Gameking, Bandai Namco ni CodeWeavers. Revisa los términos de servicio del juego antes de usarla: juegas bajo tu responsabilidad.

## Qué hace la app

DMO es un juego de Windows. La app trae dentro [Wine](https://www.winehq.org/), una capa de compatibilidad gratuita que ejecuta programas de Windows en macOS, y lo prepara solo para DMO:

1. **Crea un entorno de Windows privado** para el juego en tu carpeta de usuario, separado de todo lo demás de tu Mac.
2. **Descarga un componente de Windows desde Microsoft** la primera vez: DirectX (100 MB), que el juego necesita para los gráficos. La descarga se comprueba con su huella digital (SHA-256).
3. **Instala el juego** con el instalador oficial que descargas de [dmo.gameking.com](https://dmo.gameking.com/Main/Main.aspx), o lo copia desde CrossOver si ya lo tenías ahí.
4. **Abre el launcher del propio juego**, que lo actualiza y te deja iniciar sesión como siempre.

Además trae dos correcciones a Wine que DMO necesita en Mac. Sin ellas, el juego muestra "Falha ao receber dados de recursos" al entrar al mundo y se congela al cerrarlo.

## Qué no hace la app

- **No** modifica el juego, sus archivos ni el anti-cheat XIGNCODE.
- **No** ejecuta otros programas de Windows: solo abre DMO.
- **No** recopila ni envía datos. Lo único que descarga es DirectX desde Microsoft, además de lo que descarga el propio juego.
- **No** incluye el juego ni archivos de Microsoft: cada jugador los descarga de los sitios oficiales.

## Requisitos

- Un Mac con Apple Silicon (M1 a M4) o Intel, con macOS 11 o posterior.
- Rosetta 2 en Apple Silicon. Si falta, la app ofrece instalarlo.
- Unos 30 GB libres en el disco para el juego.

Probado en un Apple M4 con macOS 26.5.2. Si la pruebas en otro Mac, cuéntanos cómo te fue en un issue.

## Instalar y jugar

1. Descarga `MacMasters-<versión>.dmg` desde [Releases](../../releases), ábrelo y arrastra **MacMasters** a la carpeta **Applications** (Aplicaciones).
2. Abre la app. La primera vez, macOS la bloquea porque no está notarizada por Apple. Ve a **Ajustes del Sistema → Privacidad y seguridad**, baja hasta el aviso sobre "MacMasters" y pulsa **Abrir de todos modos**.
3. Pulsa **Continuar** para descargar DirectX y preparar el entorno (alrededor de un minuto).
4. Elige cómo obtener el juego:
   - **Instalar de nuevo**: descarga el instalador oficial desde [dmo.gameking.com](https://dmo.gameking.com/Main/Main.aspx) y selecciónalo. Al terminar, el launcher del juego descarga las últimas actualizaciones, lo que puede tardar.
   - **Usar la de CrossOver**: solo aparece si ya tienes DMO en un bottle de CrossOver llamado `DMO`. Se copia al instante sin ocupar espacio extra.
5. Inicia sesión y juega. A partir de ahí, al abrir la app se va directo al launcher del juego.

## Problemas frecuentes

| Qué ves | Qué hacer |
| --- | --- |
| "No se puede abrir MacMasters" | Autorízala en **Ajustes del Sistema → Privacidad y seguridad → Abrir de todos modos** (paso 2). |
| Cerrar el juego tarda unos 20 segundos | Es normal: el juego guarda la configuración, se desconecta y cierra el anti-cheat. |
| Cualquier otro problema | Abre un issue y adjunta `~/Library/Logs/MacMasters/launcher.log`. |

## Desinstalar

Borra la app y estas carpetas (en Finder: **Ir → Ir a la carpeta…**):

| Carpeta | Contenido |
| --- | --- |
| `~/Library/Application Support/MacMasters` | El entorno de Windows con el juego |
| `~/Library/Caches/MacMasters` | La descarga de DirectX |
| `~/Library/Logs/MacMasters` | El registro |

## Para desarrolladores

Cómo funciona la app por dentro, las correcciones a Wine, cómo compilarla y las licencias, en inglés: [docs/technical.md](docs/technical.md).

## Licencia

El código de la app usa la licencia MIT. Wine y los demás componentes incluidos conservan sus licencias: ver [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
