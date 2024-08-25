Proyecto Midterm

1. Se crea una base de datos "contacts_friendship", para gestionar información sobre personas,
sus datos personales y aficiones. Se crea una estructura y relaciones de tablas.

- Cree 5 tablas: People, Phones, Address, Hobbies, People_Hobbies.

  . People y Phones tiene una relación (1:N)
  . People y Address mantienen también una relación (1:N)
  . People y Hobbies tienen una relación (N:M) se crea una tabla intermedia People_Hobbies para asociar las id.

2. Mi intención es crear una especie de red social en la cual el usuario al ingresar a la página principal, podrá hacer un registro de usuario, una vez completado el registro podrá
   acceder a la página de contactos donde saldrán todos aquellos usuarios registrados, ordenados por ciudad.

   - Para ello desarrollé la página de registro, donde se guardan los datos personales del usuario, incluido aficiones.
   - Al registrarse se accede a la tabla de contactos, donde se recogen todos los usuarios registrados.
   - En la tabla de contactos se puede editar la información y eliminar contacto. Validando operaciones CRUD.

3. Para esto he creados 3 páginas html, dos de css, y una aplicación con flask.

4. Mi intención es continuar y terminar la página, incluyendo fotos y una especie de muro que cada usuario puede ir actualizando.
