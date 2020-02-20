"""try to fix tables v7

Revision ID: 11c2b11b636
Revises: 182cae057e2
Create Date: 2020-02-15 13:53:34.549646

"""

# revision identifiers, used by Alembic.
revision = '11c2b11b636'
down_revision = '182cae057e2'

from alembic import op
import sqlalchemy as sa


def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.create_table('questions',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('asker', sa.Integer(), nullable=True),
    sa.Column('datetime', sa.DateTime(), nullable=True),
    sa.Column('question', sa.String(), nullable=True),
    sa.Column('answers', sa.String(), nullable=True),
    sa.Column('total_votes', sa.Integer(), nullable=True),
    sa.Column('responders', sa.String(), nullable=True),
    sa.Column('category', sa.String(), nullable=True),
    sa.Column('lat', sa.Float(), nullable=True),
    sa.Column('lng', sa.Float(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_table('users',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('cell_number', sa.String(length=16), nullable=True),
    sa.Column('username', sa.String(), nullable=True),
    sa.Column('ansQuest', sa.String(), nullable=True),
    sa.Column('askQuest', sa.String(), nullable=True),
    sa.PrimaryKeyConstraint('id')
    )
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('users')
    op.drop_table('questions')
    ### end Alembic commands ###