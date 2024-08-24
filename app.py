from flask import Flask, render_template, request, redirect, url_for
from flask_mysqldb import MySQL
import MySQLdb.cursors

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'ironhack'
app.config['MYSQL_DB'] = 'contacts_friendship'

mysql = MySQL(app)

@app.route('/')
def index():
    return render_template('register.html')

@app.route('/register', methods=['POST'])
def register():
    if request.method == 'POST':
        name = request.form['name']
        last_name = request.form['last_name']
        email = request.form['email']
        phone = request.form['phone']
        street = request.form['street']
        city = request.form['city']
        country = request.form['country']
        hobbies = request.form.getlist('hobbies[]')
        birth_date = request.form['birth_date']

        # insertar en tablas
        cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

        cursor.execute(
            'INSERT INTO People (name, last_name, email, birth_date) VALUES (%s, %s, %s, %s)',
            (name, last_name, email, birth_date)
        )
        person_id = cursor.lastrowid  # Obtener el ID de la persona insertada

        cursor.execute(
            'INSERT INTO Phones (number, person_id) VALUES (%s, %s)',
            (phone, person_id)
        )

        cursor.execute(
            'INSERT INTO Address (street, city, country, person_id) VALUES (%s, %s, %s, %s)',
            (street, city, country, person_id)
        )

        for hobby_id in hobbies:
            cursor.execute(
                'INSERT INTO People_Hobbies (person_id, hobby_id) VALUES (%s, %s)',
                (person_id, hobby_id)
            )

        mysql.connection.commit()
        cursor.close()

        return redirect(url_for('view_contacts'))

# Ruta para ver todos los contactos
@app.route('/contacts')
def view_contacts():
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    # Consulta para obtener la información
    cursor.execute('''
        SELECT p.person_id, p.name, p.last_name, p.email, p.birth_date, ph.number as phone, a.street, a.city, a.country
        FROM People p
        JOIN Phones ph ON p.person_id = ph.person_id
        JOIN Address a ON p.person_id = a.person_id
    ''')
    contacts = cursor.fetchall()

    cursor.execute('''
        SELECT ph.person_id, GROUP_CONCAT(h.description SEPARATOR ', ') as hobbies
        FROM People_Hobbies ph
        JOIN Hobbies h ON ph.hobby_id = h.hobby_id
        GROUP BY ph.person_id
    ''')
    hobbies_dict = {row['person_id']: row['hobbies'] for row in cursor.fetchall()}

    # Agregar las aficiones a los contactos
    for contact in contacts:
        contact['hobbies'] = hobbies_dict.get(contact['person_id'], '')

    cursor.close()
    return render_template('view_contacts.html', contacts=contacts)

# Ruta para eliminar un contacto
@app.route('/delete/<int:id>', methods=['POST'])
def delete_contact(id):
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    # Eliminar los registros asociados en otras tablas
    cursor.execute('DELETE FROM People_Hobbies WHERE person_id = %s', [id])
    cursor.execute('DELETE FROM Phones WHERE person_id = %s', [id])
    cursor.execute('DELETE FROM Address WHERE person_id = %s', [id])
    cursor.execute('DELETE FROM People WHERE person_id = %s', [id])

    mysql.connection.commit()
    cursor.close()
    return redirect(url_for('view_contacts'))

# Ruta para actualizar un contacto
@app.route('/update/<int:id>', methods=['GET', 'POST'])
def update_contact(id):
    cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)

    if request.method == 'POST':
        name = request.form['name']
        last_name = request.form['last_name']
        email = request.form['email']
        phone = request.form['phone']
        street = request.form['street']
        city = request.form['city']
        country = request.form['country']
        hobbies = request.form.getlist('hobbies[]')
        birth_date = request.form['birth_date']

        # Actualizar tablas 
        cursor.execute(
            'UPDATE People SET name=%s, last_name=%s, email=%s, birth_date=%s WHERE person_id=%s',
            (name, last_name, email, birth_date, id)
        )

        cursor.execute(
            'UPDATE Phones SET number=%s WHERE person_id=%s',
            (phone, id)
        )

        cursor.execute(
            'UPDATE Address SET street=%s, city=%s, country=%s WHERE person_id=%s',
            (street, city, country, id)
        )

        # Eliminar y volver a insertar los hobbies
        cursor.execute('DELETE FROM People_Hobbies WHERE person_id=%s', [id])
        for hobby_id in hobbies:
            cursor.execute(
                'INSERT INTO People_Hobbies (person_id, hobby_id) VALUES (%s, %s)',
                (id, hobby_id)
            )

        mysql.connection.commit()
        cursor.close()
        return redirect(url_for('view_contacts'))

    # Obtener la información del contacto
    cursor.execute('SELECT * FROM People WHERE person_id = %s', [id])
    contact = cursor.fetchone()

    # Obtener teléfono, dirección y hobbies
    cursor.execute('SELECT number FROM Phones WHERE person_id = %s', [id])
    contact['phone'] = cursor.fetchone()['number']

    cursor.execute('SELECT street, city, country FROM Address WHERE person_id = %s', [id])
    address = cursor.fetchone()
    contact.update(address)

    cursor.execute('SELECT hobby_id FROM People_Hobbies WHERE person_id = %s', [id])
    contact['hobbies'] = [str(row['hobby_id']) for row in cursor.fetchall()]

    # Obtener todas las aficiones disponibles
    cursor.execute('SELECT * FROM Hobbies')
    hobbies = {row['hobby_id']: row['description'] for row in cursor.fetchall()}

    cursor.close()
    return render_template('update_contact.html', contact=contact, hobbies=hobbies)

if __name__ == '__main__':
    app.run(debug=True)
