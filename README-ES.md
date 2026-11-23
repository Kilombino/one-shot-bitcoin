# One Shot Bitcoin

Un nodo Bitcoin (BLAKE2b) con Lightning y minería DATUM, instalado con un solo comando. Ves la versión exacta de cada pieza antes de instalarla, y nada se actualiza hasta que tú lo dices.

[English](README.md)

> **Estado: 0.1, Linux.** Probado en Ubuntu con Docker: la instalación, los paneles, actualizar y volver atrás. Aún no se ha probado con una sincronización completa de la cadena, la creación del monedero ni un minero real; tómalo como una beta. Después vendrán una imagen para arrancar desde pendrive y las versiones de Windows y macOS.

## Qué incluye

| Pieza | Qué es | Hecho por |
|-------|--------|-----------|
| **Bitcoin Knots** | El nodo, en la cadena BLAKE2b, con su panel | Bitcoin Knots, empaquetado por Horizon BTC / Léo Haf |
| **Lightning Fork** | LND para la cadena BLAKE2b, con su panel | PaulsCode |
| **DATUM CONVOY** | Pasarela de minería: tu minero trabaja con tus propias plantillas de bloque | DATUM, Convoy |
| Tor, I2P | Conexiones privadas para el nodo y Lightning | Tor Project, PurpleI2P |

One Shot Bitcoin no añade software propio en el camino de tus monedas: es un script corto, un fichero de Docker Compose y una lista de versiones que junta esas piezas.

## Instalación

Necesitas un ordenador con Linux de 64 bits (x86 o ARM) con [Docker](https://docs.docker.com/engine/install/), y espacio en disco: unos 30 GB para un nodo podado, cientos de GB para uno completo.

```sh
git clone https://github.com/Kilombino/one-shot-bitcoin.git
cd one-shot-bitcoin
./install.sh
```

El instalador:

1. Enseña la versión de cada pieza que va a instalar.
2. Pregunta dónde guardar los datos.
3. Pregunta **nodo podado o completo**. Los dos verifican todos los bloques; el podado después solo conserva los últimos.
4. Pregunta si los paneles responden solo en este ordenador o también en tu red de casa.
5. Pide confirmación, y entonces descarga y arranca todo.

Al terminar muestra las direcciones del panel general y de los tres paneles. Comparten un usuario y una contraseña, generados en tu ordenador: `./oneshot password`.

## Primeros pasos

1. **Espera a que el nodo sincronice.** De horas a días, según el ordenador y la conexión. El panel del nodo muestra el avance.
2. **Crea tu monedero Lightning.** Lightning arranca cuando el nodo pasa del bloque 961640. Abre su panel, elige *Setup a new node* y **apunta las 24 palabras en papel**. Son la única copia de seguridad de tus monedas.
3. **Mina.** Abre el panel de minería, pon la dirección en la que quieres cobrar y apunta tu minero a la dirección `stratum+tcp://` que muestra el panel general.

## Tú tienes el control

Las versiones que estás ejecutando están escritas en `state/versions.env`. Las que se ofrecen están en [`versions.env`](versions.env), cada imagen fijada por su digest.

| Comando | Qué hace |
|---------|----------|
| `./oneshot status` | Qué está en marcha y con qué versiones |
| `./oneshot check` | Mira si hay versiones nuevas. No cambia nada |
| `./oneshot update` | Enseña cada cambio, de qué versión a cuál, y pregunta antes de aplicarlo |
| `./oneshot rollback` | Vuelve a las versiones que tenías antes de la última actualización |
| `./oneshot stop` / `start` / `restart` | Para o arranca todo, o una sola pieza (`./oneshot restart lnd`) |
| `./oneshot logs knots` | Lo que está diciendo una pieza |
| `./oneshot password` | Usuario y contraseña de los paneles |
| `./oneshot uninstall` | Quita los contenedores. Tus datos se quedan |

No hay actualización automática ni telemetría. `check` y `update` hacen un `git pull` de este repositorio y comparan dos ficheros de texto; puedes leer la diferencia tú mismo con `git log -p versions.env`.

Para usar una versión que elijas tú, edita `state/versions.env` y ejecuta `./oneshot restart`.

Volver atrás no siempre es posible: una base de datos abierta por una versión nueva puede no abrirse con una anterior. Lee las notas de cada pieza antes de un salto grande.

## Dónde está cada cosa

- **Tus datos**: el directorio que elegiste (por defecto `~/oneshot-data`), una carpeta por pieza. `lnd/` contiene tu monedero y tus canales Lightning: haz copia, y nunca ejecutes dos copias a la vez.
- **Tus ajustes**: `state/config.env` (puertos, contraseñas, tamaño de poda de la instalación).
- **Puertos abiertos a la red**: P2P de Bitcoin (8333), P2P de Lightning (9735) y Stratum (23334). Los paneles (8000 a 8003) y el gRPC y REST de Lightning solo responden en este ordenador, salvo que eligieras la red de casa.

El RPC del nodo no se publica fuera de Docker. El tamaño de poda se puede cambiar después en los ajustes del panel del nodo.

## Créditos

Todo el mérito del software es de sus autores: Bitcoin Knots, Horizon BTC y Léo Haf, PaulsCode, los desarrolladores de DATUM y Convoy, Lightning Labs, Tor Project y PurpleI2P. Este repositorio solo junta su trabajo.

## Licencia

MIT, para los ficheros de este repositorio. Cada pieza conserva su propia licencia.
