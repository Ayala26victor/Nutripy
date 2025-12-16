"""Agregar firma digital a Visita (reintento)

Revision ID: 7cda15fbacb4
Revises: d99f2950031c
Create Date: 2025-12-14 21:42:59.546218
"""
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision = '7cda15fbacb4'
down_revision = 'd99f2950031c'
branch_labels = None
depends_on = None

def upgrade():
    with op.batch_alter_table('visitas', schema=None) as batch_op:
        batch_op.add_column(sa.Column('firma_img', sa.Text(), nullable=True))
        batch_op.add_column(sa.Column('firma_cripto', sa.Text(), nullable=True))

def downgrade():
    with op.batch_alter_table('visitas', schema=None) as batch_op:
        batch_op.drop_column('firma_cripto')
        batch_op.drop_column('firma_img')
