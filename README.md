# DeathCounter 1.3

Un addon ligero para contar muertes en **World of Warcraft 3.3.5a (WotLK)**.

---

## Características

- Seguimiento de muertes totales
- Separación entre muertes **PvE** y **PvP**
- Sincronización del total de muertes usando estadísticas de Blizzard
- Interfaz movible y escalable
- Inicialización manual de contadores

---

## Comandos

### General

| Comando | Descripción |
|----------|-------------|
| `/dc` | Mostrar lista de comandos |
| `/dc unlock` | Desbloquear el movimiento del marco |
| `/dc lock` | Bloquear el marco |
| `/dc reset` | Restablecer todos los datos |

---

### Escala de la interfaz

Permite cambiar el tamaño de la interfaz del addon.

```bash
/dc scale X
```

Ejemplos:

```bash
/dc scale 0.8
/dc scale 1.5
```

---

### Sincronizar muertes

Sincroniza el **TOTAL de muertes** usando las estadísticas de Blizzard.

```bash
/dc sync
```

> **Importante**  
> Abre primero **Logros → Estadísticas** antes de usar la sincronización.

Ejemplo:

```bash
/dc sync
```

---

### Inicializar contador PvP

Inicializa manualmente el contador de **PvP**.

```bash
/dc ini pvp X
```

Ejemplo:

```bash
/dc ini pvp 0
```

---

### Inicializar contador PvE

Inicializa manualmente el contador de **PvE**.

```bash
/dc ini pve X
```

Ejemplo:

```bash
/dc ini pve 7
```

> **Regla**  
> `PvP + PvE` no puede exceder el número de **Muertes Totales**.

---

## Instalación

Extrae el addon en la carpeta de addons de WoW:

```text
World of Warcraft/
└── Interface/
    └── AddOns/
        └── DeathCounter/
            ├── DeathCounter.toc
            ├── DeathCounter.lua
            ├── README.md
            ├── CHANGELOG.txt
            └── LICENSE.txt
```

---

## Compatibilidad

- **World of Warcraft:** Wrath of the Lich King 3.3.5a
- **Build del cliente:** 12340

---

## Licencia

### Código

El código fuente de este addon está licenciado bajo la **Mozilla Public License 2.0 (MPL-2.0)**.

### Recursos y Marca

Toda la identidad visual, logotipos, texturas, ilustraciones y documentación están licenciados bajo la **Licencia Creative Commons Atribución–NoComercial–CompartirIgual 4.0 Internacional (CC BY-NC-SA 4.0)**.

Esto incluye:

- La identidad visual de **LaboratorioGoblin**
- Logotipos e iconos
- Ilustraciones y texturas
- Documentación y material multimedia

### Enlaces de licencia

**Mozilla Public License 2.0 (MPL-2.0)**  
https://www.mozilla.org/MPL/2.0/

**Creative Commons CC BY-NC-SA 4.0**  
https://creativecommons.org/licenses/by-nc-sa/4.0/
