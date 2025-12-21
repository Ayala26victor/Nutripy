import os, base64
from datetime import datetime
from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import serialization, hashes
from werkzeug.security import generate_password_hash, check_password_hash
from flask_migrate import Migrate
from sqlalchemy.orm import joinedload  # ✅ para cargar relaciones correctamente
from sqlalchemy import func
from werkzeug.utils import secure_filename
from flask import send_file

# === CONFIGURACIÓN DE LA APP ===
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
app = Flask(__name__)
app.config['SECRET_KEY'] = 'clave_nutripy'
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://nutripy_admin:1234@localhost/nutripy'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
migrate = Migrate(app, db)   # ✅ ahora sí, después de app y db

login_manager = LoginManager(app)
login_manager.login_view = 'login'
login_manager.login_message = "Por favor, iniciá sesión para acceder a esta página."
login_manager.login_message_category = "info"


# === MODELOS ===

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    password = db.Column(db.String(250))   # ✅ más grande para hashes

class Doctor(db.Model):
    __tablename__ = 'doctores'
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    cedula = db.Column(db.String(20), nullable=True)
    especialidad = db.Column(db.String(100), nullable=False)
    telefono = db.Column(db.String(20), nullable=True)
    turno = db.Column(db.String(50), nullable=True)
    # Mapeo opcional con User (si querés vincular cuentas a doctores)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)

class Paciente(db.Model):
    __tablename__ = 'pacientes'   # 👈 plural, igual que en la BD
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100))
    cedula = db.Column(db.String(20))
    telefono = db.Column(db.String(20))
    edad = db.Column(db.Integer)
    notas = db.Column(db.String(200))
    sexo = db.Column(db.String(10))



class Agenda(db.Model):
    __tablename__ = 'agenda'
    id = db.Column(db.Integer, primary_key=True)   
    
    # Clave foránea con borrado en cascada
    paciente_id = db.Column(
        db.Integer,
        db.ForeignKey('pacientes.id', ondelete="CASCADE"),  # 👈 corregido
        nullable=False
    )

    edad = db.Column(db.Integer, nullable=True)          
    sexo = db.Column(db.String(10), nullable=True)       
    doctor_id = db.Column(db.Integer, db.ForeignKey('doctores.id'), nullable=False)
    fecha = db.Column(db.Date, nullable=False)
    hora = db.Column(db.Time, nullable=False)
    motivo = db.Column(db.String(200), nullable=True)
    modalidad = db.Column(db.String(50), nullable=True)  
    turno = db.Column(db.String(50), nullable=True)      

    # Relación con cascada y passive_deletes
    paciente = db.relationship(
        'Paciente',
        backref=db.backref('citas', cascade="all, delete-orphan"),
        passive_deletes=True
    )
    doctor = db.relationship('Doctor', backref='citas')


class Visita(db.Model):
    __tablename__ = 'visitas'
    id = db.Column(db.Integer, primary_key=True)
    paciente_id = db.Column(db.Integer, nullable=False)
    paciente_nombre = db.Column(db.String(120), nullable=False)
    edad = db.Column(db.Integer, nullable=False)
    sexo = db.Column(db.String(10), nullable=False)
    doctor_id = db.Column(db.Integer, nullable=False)
    doctor_nombre = db.Column(db.String(120), nullable=False)
    turno = db.Column(db.String(20), nullable=False)
    modalidad = db.Column(db.String(20), nullable=False)
    fecha = db.Column(db.Date, nullable=False)
    hora = db.Column(db.Time, nullable=False)
    motivo = db.Column(db.String(200), nullable=False)

    # 🔑 Campos nuevos para firma digital
    firma_img = db.Column(db.Text, nullable=True)
    firma_cripto = db.Column(db.Text, nullable=True)

    def __repr__(self):
        return f'<Visita {self.id} - {self.paciente_nombre} con {self.doctor_nombre}>'


class Recetario(db.Model):
    __tablename__ = 'recetario'
    id = db.Column(db.Integer, primary_key=True)
    # ❌ Eliminamos doctor_id porque la tabla no lo tiene
    paciente_id = db.Column(db.Integer, db.ForeignKey('pacientes.id'), nullable=True)
    titulo = db.Column(db.String(200), nullable=False)
    descripcion = db.Column(db.Text, nullable=True)
    archivo = db.Column(db.String(300), nullable=False)
    fecha_subida = db.Column(db.DateTime, default=datetime.utcnow)

    # ❌ Eliminamos la relación con Doctor
    paciente = db.relationship("Paciente", backref="recetarios")

    def __repr__(self):
        return f"<Recetario {self.titulo}>"






# === CLAVES RSA ===
PRIVATE_KEY_PATH = os.path.join(BASE_DIR, 'keys', 'private_key.pem')
PUBLIC_KEY_PATH = os.path.join(BASE_DIR, 'keys', 'public_key.pem')

def generar_claves():
    keys_dir = os.path.join(BASE_DIR, 'keys')
    if not os.path.exists(keys_dir):
        os.makedirs(keys_dir)

    if not os.path.exists(PRIVATE_KEY_PATH):
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048
        )
        with open(PRIVATE_KEY_PATH, "wb") as f:
            f.write(private_key.private_bytes(
                serialization.Encoding.PEM,
                serialization.PrivateFormat.PKCS8,
                serialization.NoEncryption()
            ))

        public_key = private_key.public_key()
        with open(PUBLIC_KEY_PATH, "wb") as f:
            f.write(public_key.public_bytes(
                serialization.Encoding.PEM,
                serialization.PublicFormat.SubjectPublicKeyInfo
            ))

        print("🔑 Claves RSA generadas correctamente.")


# === LOGIN ===
@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))


@app.route('/init')
def init():
    db.create_all()
    generar_claves()
    if not User.query.filter_by(username='admin').first():
        db.session.add(User(username='admin', password=generate_password_hash('admin123')))
        db.session.commit()
    return "Base de datos inicializada y usuario admin creado."

# === RUTA INICIAL ===
@app.route('/')
def inicio():
        if current_user.is_authenticated:
           return render_template('inicio.html')
        return redirect(url_for('login'))


# === REGISTRO DE USUARIO ===
@app.route('/registro', methods=['GET', 'POST'])
def registro():
        if request.method == 'POST':
            username = request.form['username']
            password = request.form['password']
            confirm_password = request.form['confirm_password']

            if password != confirm_password:
                flash('Las contraseñas no coinciden', 'error')
                return render_template('registro.html')

            if User.query.filter_by(username=username).first():
                flash('El usuario ya existe', 'error')
                return redirect(url_for('registro'))

            hashed_password = generate_password_hash(password)
            db.session.add(User(username=username, password=hashed_password))
            db.session.commit()
            flash('Usuario creado correctamente', 'success')
            return redirect(url_for('login'))

        return render_template('registro.html')

# === RESTABLECER CONTRASEÑA ===
@app.route('/reset', methods=['GET', 'POST'])
def reset():
        if request.method == 'POST':
            username = request.form['username']
            nuevo_pass = request.form['password']
            confirm_pass = request.form['confirm_password']

            if nuevo_pass != confirm_pass:
                flash('⚠️ Las contraseñas no coinciden', 'error')
                return redirect(url_for('reset'))

            user = User.query.filter_by(username=username).first()
            if user:
                user.password = generate_password_hash(nuevo_pass)
                db.session.commit()
                flash('✅ Contraseña actualizada correctamente', 'success')
                return redirect(url_for('login'))
            else:
                flash('⚠️ Usuario no encontrado', 'error')
                return redirect(url_for('reset'))

        return render_template('reset.html')

# === RUTAS PRINCIPALES ===
@app.route('/pacientes')
@login_required
def pacientes_listado():
        q = request.args.get('q', '').strip()
        query = Paciente.query
        if q:
            query = query.filter(Paciente.nombre.ilike(f'%{q}%'))
        pacientes = query.all()
        return render_template('pacientes/listado.html', pacientes=pacientes, q=q)

@app.route('/login', methods=['GET', 'POST'])
def login():
        if request.method == 'POST':
            user = User.query.filter_by(username=request.form['username']).first()
            if user and check_password_hash(user.password, request.form['password']):
                login_user(user)
                return redirect(url_for('inicio'))
            else:
                flash('Usuario o contraseña incorrectos', 'error')
        return render_template('login.html')

@app.route('/logout')
def logout():
        logout_user()
        flash('Sesión cerrada correctamente', 'success')
        return redirect(url_for('login'))

@app.route('/paciente/nuevo', methods=['GET', 'POST'])
@login_required
def nuevo_paciente():
        if request.method == 'POST':
            nuevo = Paciente(
                nombre=request.form['nombre'],
                cedula=request.form['cedula'],
                telefono=request.form['telefono'],
                edad=int(request.form['edad']) if request.form.get('edad') else None,
                sexo=request.form.get('sexo'),   # ✅ ahora captura el campo sexo
                notas=request.form['notas']
            )
            db.session.add(nuevo)
            db.session.commit()
            flash('Paciente creado correctamente', 'success')
            return redirect(url_for('pacientes_listado'))
        return render_template('paciente_form.html')



@app.route('/paciente/<int:id>/historial')
@login_required
def historial_consultas(id):
    paciente = Paciente.query.get_or_404(id)
    visitas = Visita.query.filter_by(paciente_id=id).order_by(Visita.fecha.desc(), Visita.hora.desc()).all()
    return render_template('historial.html', paciente=paciente, visitas=visitas)


@app.route('/editar_paciente/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_paciente(id):
        # Buscar el paciente por ID, si no existe devuelve 404
        paciente = Paciente.query.get_or_404(id)

        if request.method == 'POST':
            # Actualizar los datos con lo que viene del formulario
            paciente.nombre = request.form['nombre']
            paciente.cedula = request.form['cedula']
            paciente.telefono = request.form['telefono']
            paciente.edad = int(request.form['edad']) if request.form.get('edad') else None
            paciente.sexo = request.form.get('sexo')   # ✅ ahora captura y guarda el sexo
            paciente.notas = request.form['notas']

            # Guardar cambios en la base de datos
            db.session.commit()
            flash('Paciente actualizado correctamente', 'success')

            # Redirigir al listado de pacientes
            return redirect(url_for('pacientes_listado'))

        # Si es GET, mostrar el formulario con los datos cargados
        return render_template('paciente_form.html', paciente=paciente)


@app.route('/doctores')
@login_required
def doctores_listado():
        doctores = Doctor.query.all()
        return render_template('doctores/listado.html', doctores=doctores)


@app.route('/doctores/nuevo', methods=['GET', 'POST'])
@login_required
def nuevo_doctor():
        if request.method == 'POST':
            nombre = request.form['nombre']
            cedula = request.form['cedula']
            especialidad = request.form['especialidad']
            telefono = request.form['telefono']
            turno = request.form['turno']

            nuevo = Doctor(
                nombre=nombre,
                cedula=cedula,
                especialidad=especialidad,
                telefono=telefono,
                turno=turno
            )
            db.session.add(nuevo)
            db.session.commit()
            flash('Doctor registrado correctamente ✅', 'success')
            return redirect(url_for('doctores_listado'))

        return render_template('doctores/nuevo.html')


@app.route('/doctores/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_doctor(id):
        doctor = Doctor.query.get_or_404(id)
        if request.method == 'POST':
            doctor.nombre = request.form['nombre']
            doctor.cedula = request.form['cedula']          # ✅ agregado
            doctor.especialidad = request.form['especialidad']
            doctor.telefono = request.form['telefono']
            doctor.turno = request.form['turno']            # ✅ agregado

            db.session.commit()
            flash('Doctor actualizado correctamente ✏', 'success')
            return redirect(url_for('doctores_listado'))

        return render_template('doctores/editar.html', doctor=doctor)


@app.route('/doctores/ver/<int:id>')
@login_required
def ver_doctor(id):
        doctor = Doctor.query.get_or_404(id)
        return render_template('doctores/ver.html', doctor=doctor)


@app.route('/doctores/eliminar/<int:id>', methods=['POST'])
@login_required
def eliminar_doctor(id):
        doctor = Doctor.query.get_or_404(id)
        db.session.delete(doctor)
        db.session.commit()
        flash('Doctor eliminado correctamente 🗑', 'danger')
        return redirect(url_for('doctores_listado'))


@app.route('/agenda/nueva', methods=['GET', 'POST'])
@login_required
def nueva_cita():
        pacientes = Paciente.query.all()
        doctores = Doctor.query.all()

        if request.method == 'POST':
            paciente_id = request.form['paciente_id']
            edad = int(request.form['edad'])              # ✅ nuevo campo
            sexo = request.form['sexo']                   # ✅ nuevo campo
            doctor_id = request.form['doctor_id']
            fecha = request.form['fecha']
            hora = request.form['hora']
            motivo = request.form['motivo']
            turno = request.form.get('turno')
            modalidad = request.form.get('modalidad')

            nueva = Agenda(
                paciente_id=paciente_id,
                edad=edad,
                sexo=sexo,
                doctor_id=doctor_id,
                fecha=datetime.strptime(fecha, '%Y-%m-%d').date(),
                hora=datetime.strptime(hora, '%H:%M').time(),
                motivo=motivo,
                turno=turno,
                modalidad=modalidad
            )
            db.session.add(nueva)
            db.session.commit()
            flash('Cita registrada correctamente', 'success')
            return redirect(url_for('agenda_listado'))

        return render_template('agenda/nueva_cita.html', pacientes=pacientes, doctores=doctores)


    # -------------------------
    # Agenda - Ver cita
    # -------------------------
@app.route('/agenda/ver/<int:id>')
@login_required
def ver_cita(id):
        cita = Agenda.query.get_or_404(id)
        return render_template('agenda/ver_cita.html', cita=cita)


    # -------------------------
    # Agenda - Editar cita
    # -------------------------
@app.route('/agenda/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_cita(id):
        cita = Agenda.query.get_or_404(id)
        pacientes = Paciente.query.all()
        doctores = Doctor.query.all()

        if request.method == 'POST':
            cita.paciente_id = request.form['paciente_id']
            cita.edad = int(request.form['edad']) if request.form.get('edad') else None   # ✅ nuevo campo
            cita.sexo = request.form.get('sexo')                                         # ✅ nuevo campo
            cita.doctor_id = request.form['doctor_id']
            cita.turno = request.form.get('turno')
            cita.modalidad = request.form.get('modalidad')
            cita.fecha = datetime.strptime(request.form['fecha'], '%Y-%m-%d').date()
            cita.hora = datetime.strptime(request.form['hora'], '%H:%M').time()
            cita.motivo = request.form['motivo']

            db.session.commit()
            flash('Cita actualizada correctamente', 'success')
            return redirect(url_for('agenda_listado'))

        return render_template('agenda/editar_cita.html', cita=cita, pacientes=pacientes, doctores=doctores)


    # -------------------------
    # Agenda - Eliminar cita
    # -------------------------
@app.route('/agenda/eliminar/<int:id>', methods=['POST'])
@login_required
def eliminar_cita(id):
        cita = Agenda.query.get_or_404(id)
        db.session.delete(cita)
        db.session.commit()
        flash('Cita eliminada correctamente', 'success')
        return redirect(url_for('agenda_listado'))

@app.route('/agenda')
@login_required
def agenda_listado():
        agenda = Agenda.query.all()
        return render_template('agenda/listado.html', agenda=agenda)

@app.route('/eliminar/<int:id>', methods=['POST'])
def eliminar_paciente(id):
        paciente = Paciente.query.get_or_404(id)
        db.session.delete(paciente)
        db.session.commit()
        flash('Paciente eliminado correctamente', 'success')
        return redirect(url_for('pacientes_listado'))
    
@app.route('/consultas', methods=['GET'])
@login_required
def consultas_listado():
    consultas = Visita.query.order_by(Visita.fecha.desc(), Visita.hora.desc()).all()
    return render_template('consultas/listado.html', consultas=consultas)


@app.route('/consultas/nueva', methods=['GET', 'POST'])
@login_required
def crear_consulta():
    if request.method == 'POST':
        paciente_id = int(request.form['paciente_id'])
        edad = int(request.form['edad'])
        sexo = request.form['sexo']
        doctor_id = int(request.form['doctor_id'])
        turno = request.form['turno'].strip()
        modalidad = request.form['modalidad']
        fecha_str = request.form['fecha']
        hora_str = request.form['hora']
        motivo = request.form['motivo'].strip()

        # Firma digital (imagen base64 desde el formulario)
        firma_img = request.form.get('firma_img')

        paciente = Paciente.query.get(paciente_id)
        doctor = Doctor.query.get(doctor_id)

        fecha = datetime.strptime(fecha_str, '%Y-%m-%d').date()
        hora = datetime.strptime(hora_str, '%H:%M').time()

        # Generar firma criptográfica con RSA
        private_key = serialization.load_pem_private_key(
            open(PRIVATE_KEY_PATH, "rb").read(),
            password=None
        )
        texto = f"{paciente.nombre}|{motivo}|{datetime.now()}"
        firma_cripto = base64.b64encode(
            private_key.sign(
                texto.encode(),
                padding.PSS(
                    mgf=padding.MGF1(hashes.SHA256()),
                    salt_length=padding.PSS.MAX_LENGTH
                ),
                hashes.SHA256()
            )
        ).decode()

        nueva = Visita(
            paciente_id=paciente_id,
            paciente_nombre=paciente.nombre if paciente else 'Desconocido',
            edad=edad,
            sexo=sexo,
            doctor_id=doctor_id,
            doctor_nombre=doctor.nombre if doctor else 'Desconocido',
            turno=turno,
            modalidad=modalidad,
            fecha=fecha,
            hora=hora,
            motivo=motivo,
            firma_img=firma_img,
            firma_cripto=firma_cripto
        )

        db.session.add(nueva)
        db.session.commit()
        flash('Consulta registrada correctamente ✅', 'success')
        return redirect(url_for('consultas_listado'))

    pacientes = Paciente.query.order_by(Paciente.nombre.asc()).all()
    doctores = Doctor.query.order_by(Doctor.nombre.asc()).all()
    return render_template('consultas/nueva.html', pacientes=pacientes, doctores=doctores)

            


@app.route('/consultas/editar/<int:id>', methods=['GET', 'POST'])
@login_required
def editar_consulta(id):
    consulta = Visita.query.get_or_404(id)

    if request.method == 'POST':
        consulta.paciente_id = int(request.form['paciente_id'])
        consulta.edad = int(request.form['edad'])
        consulta.sexo = request.form['sexo']
        consulta.doctor_id = int(request.form['doctor_id'])
        consulta.turno = request.form['turno'].strip()
        consulta.modalidad = request.form['modalidad']
        consulta.fecha = datetime.strptime(request.form['fecha'], '%Y-%m-%d').date()
        consulta.hora = datetime.strptime(request.form['hora'], '%H:%M').time()
        consulta.motivo = request.form['motivo'].strip()

        paciente = Paciente.query.get(consulta.paciente_id)
        doctor = Doctor.query.get(consulta.doctor_id)
        consulta.paciente_nombre = paciente.nombre if paciente else 'Desconocido'
        consulta.doctor_nombre = doctor.nombre if doctor else 'Desconocido'

        db.session.commit()
        flash('Consulta actualizada correctamente ✅', 'success')
        return redirect(url_for('consultas_listado'))

    pacientes = Paciente.query.order_by(Paciente.nombre.asc()).all()
    doctores = Doctor.query.order_by(Doctor.nombre.asc()).all()
    return render_template('consultas/editar.html', consulta=consulta, pacientes=pacientes, doctores=doctores)


@app.route('/consultas/ver/<int:id>', methods=['GET'])
@login_required
def ver_visita(id):
    consulta = Visita.query.get_or_404(id)
    return render_template('consultas/ver.html', consulta=consulta)



@app.route('/consultas/eliminar/<int:id>', methods=['POST'])
@login_required
def eliminar_consulta(id):
    consulta = Visita.query.get_or_404(id)
    db.session.delete(consulta)
    db.session.commit()
    flash('Consulta eliminada correctamente 🗑️', 'success')
    return redirect(url_for('consultas_listado'))


@app.route('/dashboard')
@login_required
def dashboard():
    hoy = datetime.today().date()

    # Contadores principales
    total_pacientes = Paciente.query.count()
    total_citas = Agenda.query.count()
    total_consultas = Visita.query.count()

    # Próximas citas (con relaciones cargadas)
    proximas_citas = (
        Agenda.query.options(
            joinedload(Agenda.paciente),
            joinedload(Agenda.doctor)
        )
        .filter(Agenda.fecha >= hoy)
        .order_by(Agenda.fecha.asc(), Agenda.hora.asc())
        .limit(5)
        .all()
    )

    # Doctores activos (turno no nulo)
    doctores_activos = Doctor.query.filter(Doctor.turno != None).order_by(Doctor.nombre.asc()).all()

    # Alertas
    alertas = []
    pacientes_sin_historia = (
        db.session.query(Paciente)
        .filter(~db.session.query(Visita).filter(Visita.paciente_id == Paciente.id).exists())
        .all()
    )
    if pacientes_sin_historia:
        alertas.append(f"{len(pacientes_sin_historia)} pacientes sin historial clínico")


    # Modalidades para gráfico (sanitizando nulos)
    modalidades_raw = db.session.query(Visita.modalidad, func.count(Visita.id)).group_by(Visita.modalidad).all()
    modalidades = [(m[0] if m[0] else "Sin modalidad", m[1]) for m in modalidades_raw]

    return render_template(
        'dashboard.html',
        total_pacientes=total_pacientes or 0,
        total_citas=total_citas or 0,
        total_consultas=total_consultas or 0,
        proximas_citas=proximas_citas,
        doctores_activos=doctores_activos,
        alertas=alertas,
        modalidades=modalidades
    )

# Configuración de carpeta de subida (asegurate de crearla en tu proyecto)
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads', 'recetarios')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/recetarios', methods=['GET', 'POST'])
@login_required
def recetarios():
    if request.method == 'POST':
        titulo = request.form.get('titulo')
        descripcion = request.form.get('descripcion')
        archivo = request.files.get('archivo')

        if not archivo or archivo.filename == '':
            flash('No se seleccionó ningún archivo', 'warning')
            return redirect(url_for('recetarios'))

        nombre_archivo = secure_filename(archivo.filename)
        ruta_archivo = os.path.join(UPLOAD_FOLDER, nombre_archivo)
        archivo.save(ruta_archivo)

        nuevo = Recetario(
            titulo=titulo,
            descripcion=descripcion,
            archivo=ruta_archivo,
            fecha_subida=datetime.utcnow()
        )
        db.session.add(nuevo)
        db.session.commit()

        flash('Recetario subido correctamente', 'success')
        return redirect(url_for('recetarios'))

    # ✅ Ahora listamos todos los recetarios, sin filtrar por doctor
    recetarios = Recetario.query.all()
    return render_template('recetarios.html', recetarios=recetarios)

@app.route('/recetarios/descargar/<int:id>')
@login_required
def descargar_recetario(id):
    recetario = Recetario.query.get_or_404(id)
    return send_file(recetario.archivo, as_attachment=True)

@app.route('/recetarios/eliminar/<int:id>', methods=['POST', 'GET'])
@login_required
def eliminar_recetario(id):
    recetario = Recetario.query.get_or_404(id)
    db.session.delete(recetario)
    db.session.commit()
    flash('Recetario eliminado correctamente 🗑️', 'success')
    return redirect(url_for('recetarios'))

# === EXPORTACIONES ===
    
from io import BytesIO, StringIO
import pandas as pd
import csv
from reportlab.pdfgen import canvas
from flask import make_response

@app.route('/agenda/exportar/pdf/<int:id>')
@login_required
def exportar_cita_pdf(id):
    from reportlab.pdfgen import canvas
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.utils import ImageReader
    from flask import make_response
    from io import BytesIO
    import os

    cita = Agenda.query.get_or_404(id)  # ✅ corregido

    buffer = BytesIO()
    c = canvas.Canvas(buffer, pagesize=A4)
    width, height = A4
    c.setFont("Helvetica", 12)

    # === Logo Nutripy con borde verde ===
    logo_path = os.path.join("static", "img", "logo_nutripy.png")  # ✅ corregido
    if os.path.exists(logo_path):
        logo = ImageReader(logo_path)
        c.setStrokeColorRGB(0, 0.6, 0.2)  # Verde institucional
        c.setLineWidth(1)
        c.rect(40, height - 120, 100, 100)  # Marco más grande
        c.drawImage(logo, 42, height - 118, width=96, height=96, mask='auto')
    else:
        print(f"Logo no encontrado en: {logo_path}")

    # Encabezado institucional
    c.drawString(160, height - 60, "Nutripy - Clínica de Nutrición")
    c.drawString(160, height - 80, "Tel: (021) 123-456 | Email: info@nutripy.com")
    c.line(40, height - 140, width - 40, height - 140)

    # Título
    c.setFont("Helvetica-Bold", 14)
    c.drawCentredString(width / 2, height - 160, "Detalle de la cita")
    c.setFont("Helvetica", 12)

    # Datos de la cita
    y = height - 190
    c.drawString(60, y, f"Paciente: {cita.paciente.nombre}")
    y -= 20
    c.drawString(60, y, f"Edad: {cita.edad}")
    y -= 20
    c.drawString(60, y, f"Sexo: {cita.sexo}")
    y -= 20
    c.drawString(60, y, f"Doctor: {cita.doctor.nombre}")
    y -= 20
    c.drawString(60, y, f"Turno: {cita.turno}")
    y -= 20
    c.drawString(60, y, f"Fecha: {cita.fecha.strftime('%d/%m/%Y')}")
    y -= 20
    c.drawString(60, y, f"Hora: {cita.hora.strftime('%H:%M')}")
    y -= 20
    c.drawString(60, y, f"Motivo: {cita.motivo}")
    y -= 20
    c.drawString(60, y, f"Modalidad: {cita.modalidad}")

    c.save()
    pdf = buffer.getvalue()
    buffer.close()

    response = make_response(pdf)
    response.headers['Content-Type'] = 'application/pdf'
    response.headers['Content-Disposition'] = f'attachment; filename=cita_{id}.pdf'
    return response

@app.route('/consultas/exportar/pdf/<int:id>')
@login_required
def exportar_consulta_pdf(id):
    from reportlab.pdfgen import canvas
    from reportlab.lib.utils import ImageReader
    from flask import make_response
    from io import BytesIO
    import os

    consulta = Visita.query.get_or_404(id)
    buffer = BytesIO()
    c = canvas.Canvas(buffer)
    c.setFont("Helvetica", 12)

    # === Logo Nutripy ===
    logo_path = os.path.join(os.getcwd(), "static", "img", "nutripy_logo.png")  # Asegurate que el archivo exista
    if os.path.exists(logo_path):
        try:
            logo = ImageReader(logo_path)
            c.drawImage(logo, 40, 800, width=50, height=50, mask='auto')  # Ajustado para no superponerse
        except Exception as e:
            print(f"⚠️ No se pudo cargar el logo: {e}")
    else:
        print(f"⚠️ Logo no encontrado en: {logo_path}")

    # Encabezado institucional
    c.drawString(100, 820, "Nutripy - Clínica de Nutrición")
    c.drawString(100, 805, "Tel: (021) 123-456 | Email: info@nutripy.com")
    c.line(100, 800, 500, 800)

    # Datos de la consulta
    c.drawString(100, 780, f"Paciente: {consulta.paciente_nombre}")
    c.drawString(100, 760, f"Edad: {consulta.edad}")
    c.drawString(100, 740, f"Sexo: {'Masculino' if consulta.sexo == 'M' else 'Femenino'}")
    c.drawString(100, 720, f"Doctor: {consulta.doctor_nombre}")
    c.drawString(100, 700, f"Turno: {consulta.turno}")
    c.drawString(100, 680, f"Modalidad: {consulta.modalidad}")
    c.drawString(100, 660, f"Fecha: {consulta.fecha.strftime('%d/%m/%Y')}")
    c.drawString(100, 640, f"Hora: {consulta.hora.strftime('%H:%M')}")
    c.drawString(100, 620, f"Motivo: {consulta.motivo}")

    c.save()
    pdf = buffer.getvalue()
    buffer.close()

    response = make_response(pdf)
    response.headers['Content-Type'] = 'application/pdf'
    response.headers['Content-Disposition'] = f'attachment; filename=consulta_{id}.pdf'
    return response


@app.route('/agenda/exportar/excel/<int:id>')
@login_required
def exportar_cita_excel(id):
        cita = Agenda.query.get_or_404(id)
        data = {
            "Paciente": [cita.paciente.nombre],
            "Edad": [cita.edad],
            "Sexo": [cita.sexo],
            "Doctor": [cita.doctor.nombre],
            "Turno": [cita.turno or '-'],
            "Fecha": [cita.fecha.strftime('%d/%m/%Y')],
            "Hora": [cita.hora.strftime('%H:%M')],
            "Motivo": [cita.motivo or '-'],
            "Modalidad": [cita.modalidad or '-']
        }
        df = pd.DataFrame(data)
        output = BytesIO()
        # Usar openpyxl como motor
        with pd.ExcelWriter(output, engine="openpyxl") as writer:
            df.to_excel(writer, index=False)
        response = make_response(output.getvalue())
        response.headers['Content-Disposition'] = f'attachment; filename=cita_{id}.xlsx'
        response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        return response


@app.route('/agenda/exportar/csv/<int:id>')
@login_required
def exportar_cita_csv(id):
        cita = Agenda.query.get_or_404(id)
        si = StringIO()
        writer = csv.writer(si)
        writer.writerow(["Paciente", "Edad", "Sexo", "Doctor", "Turno", "Fecha", "Hora", "Motivo", "Modalidad"])
        writer.writerow([
            cita.paciente.nombre,
            cita.edad,
            cita.sexo,
            cita.doctor.nombre,
            cita.turno or '-',
            cita.fecha.strftime('%d/%m/%Y'),
            cita.hora.strftime('%H:%M'),
            cita.motivo or '-',
            cita.modalidad or '-'
        ])
        response = make_response(si.getvalue())
        response.headers['Content-Disposition'] = f'attachment; filename=cita_{id}.csv'
        response.headers['Content-Type'] = 'text/csv; charset=utf-8'
        return response

@app.route('/consultas/exportar/excel/<int:id>')
@login_required
def exportar_consulta_excel(id):
    consulta = Visita.query.get_or_404(id)

    encabezado = {
    "Institución": ["Nutripy - Clínica de Nutrición"],
    "Contacto": ["Tel: (021) 123-456 | Email: info@nutripy.com"],
    "Logo": [url_for('static', filename='img/logo_nutripy.png')]
}


    datos = {
        "Paciente": [consulta.paciente_nombre],
        "Edad": [consulta.edad],
        "Sexo": ['Masculino' if consulta.sexo == 'M' else 'Femenino'],
        "Doctor": [consulta.doctor_nombre],
        "Turno": [consulta.turno],
        "Modalidad": [consulta.modalidad],
        "Fecha": [consulta.fecha.strftime('%d/%m/%Y')],
        "Hora": [consulta.hora.strftime('%H:%M')],
        "Motivo": [consulta.motivo]
    }

    df_encabezado = pd.DataFrame(encabezado)
    df_datos = pd.DataFrame(datos)
    output = BytesIO()
    with pd.ExcelWriter(output, engine="openpyxl") as writer:
        df_encabezado.to_excel(writer, index=False, startrow=0)
        df_datos.to_excel(writer, index=False, startrow=5)
    response = make_response(output.getvalue())
    response.headers['Content-Disposition'] = f'attachment; filename=consulta_{id}.xlsx'
    response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    return response

@app.route('/consultas/exportar/csv/<int:id>')
@login_required
def exportar_consulta_csv(id):
    consulta = Visita.query.get_or_404(id)
    si = StringIO()
    writer = csv.writer(si)

    # Encabezado institucional
    writer.writerow(["Nutripy - Clínica de Nutrición"])
    writer.writerow(["Tel: (021) 123-456 | Email: info@nutripy.com"])
    writer.writerow(["Logo Nutripy"])
    writer.writerow([])

    # Datos de la consulta
    writer.writerow(["Paciente", "Edad", "Sexo", "Doctor", "Turno", "Modalidad", "Fecha", "Hora", "Motivo"])
    writer.writerow([
        consulta.paciente_nombre,
        consulta.edad,
        'Masculino' if consulta.sexo == 'M' else 'Femenino',
        consulta.doctor_nombre,
        consulta.turno,
        consulta.modalidad,
        consulta.fecha.strftime('%d/%m/%Y'),
        consulta.hora.strftime('%H:%M'),
        consulta.motivo
    ])

    response = make_response(si.getvalue())
    response.headers['Content-Disposition'] = f'attachment; filename=consulta_{id}.csv'
    response.headers['Content-Type'] = 'text/csv; charset=utf-8'
    return response


# === EJECUCIÓN DEL SERVIDOR ===
if __name__ == '__main__':
        app.run(debug=True)

