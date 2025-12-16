"""Unificar ramas de migraciones

Revision ID: 07ba076d9688
Revises: 500fbe8cca05, 7cda15fbacb4
Create Date: 2025-12-14 22:04:54.423783

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '07ba076d9688'
down_revision = ('500fbe8cca05', '7cda15fbacb4')
branch_labels = None
depends_on = None


def upgrade():
    pass


def downgrade():
    pass
