# Gestor de Tareas Personal

Aplicación móvil y backend para la gestión de tareas diarias.

## Descripción
El sistema permite a los usuarios:
- Ver todas sus tareas
- Crear nuevas tareas
- Editar tareas existentes
- Marcar tareas como completadas o pendientes
- Eliminar tareas

Incluye autenticación para que cada usuario gestione solo sus propias tareas.

---

## Tecnologías Usadas

### **Frontend (mobile/)**
- Flutter 3.32.8
- Dart 3.8.1
- Manejo de estado con `StatefulWidget`
- Consumo de API REST vía `http`

### **Backend (server/)**
- Node.js
- NestJS
- PostgreSQL
- Prisma
- DTOs para validación
- Autenticación JWT
- Controladores, Servicios y Módulos con buenas prácticas

---

## **AVISOS**
Manejo del token en memoria
Se optó por mantener el token únicamente en memoria durante la sesión de la app para simplificar la implementación y evitar riesgos de almacenamiento inseguro. Esta decisión facilita las pruebas rápidas en el entorno de la prueba técnica, aunque en un entorno productivo se recomendaría persistirlo de forma segura (ej. flutter_secure_storage) para mejorar la experiencia de usuario.

Uso de un modelo híbrido de autenticación
Se implementó un token firmado tipo JWT con un payload reducido (solo userId y email) en lugar de un JWT completo con expiración y roles. Esto permitió integrar rápidamente la autenticación con el frontend Flutter, manteniendo seguridad básica y simplificando el desarrollo para la prueba técnica. En un entorno productivo se recomienda ampliar el payload y añadir control de expiración y roles para una gestión más robusta de permisos.

## Instalación y Ejecución Local

Se debe crear archivo .env para server con variables:

DATABASE_URL

JWT_SECRET


### 1️: Clonar repositorio
```bash
git clone https://github.com/student452/APP_TAREAS.git
cd APP_TAREAS
```

### Despliegue

El proyecto está desplegado en Render, que aloja tanto el backend como la base de datos.

Backend: API REST desarrollada con NestJS accesible públicamente para la aplicación Flutter.

Base de datos: PostgreSQL conectada de forma segura al backend mediante variables de entorno.

Render ofrece despliegue continuo, por lo que los cambios enviados a la rama principal de GitHub se actualizan automáticamente en producción.





