#Easy car owner and givecar menu! ( geus_givecar ) By. PRESTIGEUS

<img width="1280" height="720" alt="preview" src="https://github.com/user-attachments/assets/610e0604-01be-4506-b180-b475eb52c56b" />

🚗 geus_givecar — ESX vehicle ownership (admin-only) con ox_lib

geus_givecar permite registrar vehículos como “owned” en ESX, para ti o para otro jugador por ID de servidor, con un menú limpio en ox_lib y seguridad reforzada del lado del servidor (solo administradores).
Ideal para staffs que quieren gestionar propiedades de vehículos sin complicarse con comandos crípticos.

✨ Características

Admin-only: validación en servidor (geus.givecar o group.admin).

Sin “access denied”: los comandos no usan ACE en cliente; el control real está en servidor.

Menú dinámico con ox_lib (/ownmenu).

Comandos rápidos: /owncar [PLACA], /owncarid <ID> [PLACA].

ESX Legacy + oxmysql: inserta/actualiza en owned_vehicles.

Código simple y listo para producción.

🧩 Requisitos

ESX Legacy (@es_extended/imports.lua)

ox_lib

oxmysql

(opcional) chat para sugerencias de comandos

⚙️ Instalación rápida
# server.cfg
ensure ox_lib
ensure geus_givecar

# Seguridad server-side
add_ace group.admin "geus.givecar" allow

# Asegúrate de estar en admin:
# add_principal identifier.license:TULICENSE group.admin
# add_principal identifier.license2:TULICENSE2 group.admin
# add_principal identifier.discord:TUDISCORDID group.admin


Limpia cache en txAdmin y reinicia el servidor.

🕹️ Uso

/owncar [PLACA] — te asigna el vehículo donde estás sentado.

/owncarid <ID> [PLACA] — asigna el vehículo a otro jugador (server ID).

/ownmenu — abre el menú de administración con ox_lib.

🔒 Seguridad

La autorización vive en el servidor.

Aunque cualquiera pueda escribir el comando, solo admins pasan la validación y se ejecuta la acción.

🗄️ Notas de base de datos

Se usa owned_vehicles (owner, plate, vehicle, type, stored).

Si tu schema tiene columnas extras (garage, job, parking), ajusta la función insertOwned en server.lua.

🛣️ Roadmap

Webhook a Discord (logs con embeds).

Selector de garage/estado desde el menú.

Llaves automáticas (wasabi_carlock / qb-vehiclekeys / etc.).

Asignación offline por identifier.

/givecar <ID> <modelo> [placa] (spawn + registrar).


BY. PRESTIGEUS
