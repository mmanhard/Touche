from flask_script import Manager
from flask_migrate import Migrate, MigrateCommand

from app import app, db

# Configure the migration with the app and database.
migrate = Migrate(app, db)
manager = Manager(app)
manager.add_command('db', MigrateCommand)

# Adds the cube and earthdistance extension to the database if it does not exist.
# Allows for geolocation calculations in queries.
@manager.command
def add_earth_ext():
    db.engine.execute('CREATE EXTENSION IF NOT EXISTS cube;')
    db.engine.execute('CREATE EXTENSION IF NOT EXISTS earthdistance')
    print('Database set up for earthdistance calculations.')

if __name__ == '__main__':
    manager.run()
