from flask import Flask, render_template, request, redirect, url_for, session
from models import db, User

app = Flask(__name__)
app.secret_key = "SUPER_SECRET_KEY"   # Change this in production

# --- Database Configuration ---
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///users.db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# Initialize database
db.init_app(app)

# Create tables at startup (Flask 3.x safe)
with app.app_context():
    db.create_all()


# ------------------ HOME ------------------
@app.route('/')
def index():
    if 'username' in session:
        return redirect(url_for('welcome'))
    return redirect(url_for('login'))


# ------------------ SIGNUP ------------------
@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        username = request.form["username"]
        password = request.form["password"]

        # Check if username exists
        if User.query.filter_by(username=username).first():
            return render_template("signup.html", error="User already exists")

        # Create new user
        new_user = User(username=username)
        new_user.set_password(password)

        db.session.add(new_user)
        db.session.commit()

        return redirect(url_for('login'))

    return render_template("signup.html")


# ------------------ LOGIN ------------------
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form["username"]
        password = request.form["password"]

        user = User.query.filter_by(username=username).first()

        if user and user.check_password(password):
            session['username'] = username
            return redirect(url_for('welcome'))
        else:
            return render_template("login.html", error="Invalid username or password")

    return render_template("login.html")


# ------------------ WELCOME PAGE ------------------
@app.route('/welcome')
def welcome():
    if 'username' not in session:
        return redirect(url_for('login'))

    return render_template("welcome.html", user=session['username'])


# ------------------ LOGOUT ------------------
@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
