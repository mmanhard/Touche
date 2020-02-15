"""empty message

Revision ID: 23fe9dc6a30
Revises: None
Create Date: 2020-02-15 13:13:47.137995

"""

# revision identifiers, used by Alembic.
revision = '23fe9dc6a30'
down_revision = None

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('questions')
    op.drop_table('users')
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.create_table('users',
    sa.Column('id', sa.INTEGER(), nullable=False),
    sa.Column('cell_number', sa.VARCHAR(length=16), autoincrement=False, nullable=True),
    sa.Column('ansQuest', sa.VARCHAR(), autoincrement=False, nullable=True),
    sa.Column('askQuest', sa.VARCHAR(), autoincrement=False, nullable=True),
    sa.PrimaryKeyConstraint('id', name='users_pkey')
    )
    op.create_table('questions',
    sa.Column('id', sa.INTEGER(), nullable=False),
    sa.Column('asker', sa.INTEGER(), autoincrement=False, nullable=True),
    sa.Column('datetime', postgresql.TIMESTAMP(), autoincrement=False, nullable=True),
    sa.Column('question', sa.VARCHAR(), autoincrement=False, nullable=True),
    sa.Column('answers', sa.VARCHAR(), autoincrement=False, nullable=True),
    sa.Column('total_votes', sa.INTEGER(), autoincrement=False, nullable=True),
    sa.Column('responders', sa.VARCHAR(), autoincrement=False, nullable=True),
    sa.Column('category', sa.VARCHAR(), autoincrement=False, nullable=True),
    sa.Column('lat', postgresql.DOUBLE_PRECISION(precision=53), autoincrement=False, nullable=True),
    sa.Column('lng', postgresql.DOUBLE_PRECISION(precision=53), autoincrement=False, nullable=True),
    sa.PrimaryKeyConstraint('id', name='questions_pkey')
    )
    ### end Alembic commands ###
