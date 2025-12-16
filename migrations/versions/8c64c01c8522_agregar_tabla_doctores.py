"""Agregar tabla doctores

Revision ID: 8c64c01c8522
Revises: 
Create Date: 2025-11-29 14:34:39.214537

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '8c64c01c8522'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.create_table('doctores',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('nombre', sa.String(length=100), nullable=False),
        sa.Column('especialidad', sa.String(length=100), nullable=False),
        sa.Column('telefono', sa.String(length=20), nullable=True),
        sa.PrimaryKeyConstraint('id')
    )
    with op.batch_alter_table('user', schema=None) as batch_op:
        batch_op.alter_column('password',
            existing_type=sa.VARCHAR(length=100),
            type_=sa.String(length=255),
            existing_nullable=True)

def downgrade():
    with op.batch_alter_table('user', schema=None) as batch_op:
        batch_op.alter_column('password',
            existing_type=sa.String(length=255),
            type_=sa.VARCHAR(length=100),
            existing_nullable=True)

    op.drop_table('doctores')
