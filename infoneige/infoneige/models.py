from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Enum,
    Float,
    ForeignKey,
    ForeignKeyConstraint,
    func,
    Index,
    Integer,
    SmallInteger,
    String,
    Text,
    TIMESTAMP,
    )

from sqlalchemy.ext.declarative import declarative_base

from sqlalchemy.orm import (
    scoped_session,
    sessionmaker,
    )

from zope.sqlalchemy import ZopeTransactionExtension

from datetime import datetime

from suds import client

DBSession = scoped_session(sessionmaker(extension=ZopeTransactionExtension()))
Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(String(32))
    first_name = Column(String(32))
    last_name = Column(String(32))
    email = Column(String(256))
    phone_cell = Column(String(12))
    created_on = Column(DateTime)
    modified_on = Column(TIMESTAMP, server_default=func.now(), onupdate=func.current_timestamp())
    last_login = Column(DateTime)

class UserAddress(Base):
    __tablename__ = 'user_addresses'
    id = Column(Integer, primary_key=True)
    name = Column(String(32))
    user_id = Column(Integer, ForeignKey('users.id'))
    municipality_id = Column(Integer, ForeignKey('municipalities.id'))
    postal_code = Column(String(9))
    street_number = Column(Integer)
    street_side_id = Column(Integer, ForeignKey('street_sides.id'))
    walking_distance = Column(Integer)

class CarGeolocation(Base):
    __tablename__ = 'car_geolocations'
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('users.id'))
    geolat = Column(Float(precision=6))
    geolng = Column(Float(precision=6))
    street_side_id = Column(Integer, ForeignKey('street_sides.id'))
    walking_distance = Column(Integer)

class Geobase(Base):
    __tablename__ = 'geobase'
    id = Column(Integer, primary_key=True, autoincrement=False)
    type = Column(Enum("street_section", "street_side"))
    point_id = Column(Integer, primary_key=True)
    line_id = Column(Integer, primary_key=True)
    geotype = Column(Enum("LineString", "MultiLineString"))
    geolat = Column(Float(precision=6))
    geolng = Column(Float(precision=6))
    created_on = Column(DateTime)
    modified_on = Column(TIMESTAMP, server_default=func.now(), onupdate=func.current_timestamp())

class Municipality(Base):
    __tablename__ = 'municipalities'
    id = Column(Integer, primary_key=True, autoincrement=False)
    municipality_type = Column(String(64))
    name = Column(String(64))
    county = Column(String(64))
    region = Column(String(64))
    state = Column(String(2), primary_key=True)
    country = Column(String(64), primary_key=True)
    created_on = Column(DateTime)
    modified_on = Column(TIMESTAMP, server_default=func.now(), onupdate=func.current_timestamp())   

class StreetSection(Base):
    __tablename__ = 'street_sections'
    __table_args__ = ( 
        ForeignKeyConstraint( 
            ["municipality_id"], 
            ["municipalities.id"] 
            ),
        )
    id = Column(Integer, primary_key=True, autoincrement=False)
    municipality_id = Column(Integer, primary_key=True, autoincrement=False)
    street_name = Column(String(72))
    starting_intersection = Column(String(72))
    ending_intersection = Column(String(72))
    traffic_direction = Column(SmallInteger)
    geobase_id = Column(Integer, ForeignKey('geobase.id'))
    created_on = Column(DateTime)
    modified_on = Column(TIMESTAMP, server_default=func.now(), onupdate=func.current_timestamp())    

class StreetSide(Base):
    __tablename__ = 'street_sides'
    __table_args__ = ( 
        ForeignKeyConstraint( 
            ["municipality_id"], 
            ["municipalities.id"] 
            ),
        )
    id = Column(Integer, primary_key=True, autoincrement=False)
    municipality_id = Column(Integer, primary_key=True, autoincrement=False)
    street_section_id = Column(Integer, ForeignKey('street_sections.id'))
    starting_street_number = Column(Integer)
    ending_street_number = Column(Integer)
    district_name = Column(String(64))
    street_name = Column(String(72))
    geobase_id = Column(Integer, ForeignKey('geobase.id'))
    created_on = Column(DateTime)
    modified_on = Column(DateTime, server_default=func.now(), onupdate=func.current_timestamp())

class StreetSideHistory(Base):
    __tablename__ = 'street_side_history'
    id = Column(Integer, primary_key=True)
    municipality_id = Column(Integer, ForeignKey('municipalities.id'))
    street_side_id = Column(Integer, ForeignKey('street_sides.id'))
    state = Column(SmallInteger)
    observed_on = Column(DateTime)
    observed_by = Column(Integer, ForeignKey('users.id'))
    geolat = Column(Float(precision=6))
    geolng = Column(Float(precision=6))

class Planning(Base):
    __tablename__ = 'planning'
    id = Column(Integer, primary_key=True)
    municipality_id = Column(Integer, ForeignKey('municipalities.id'))
    street_side_id = Column(Integer, ForeignKey('street_sides.id'))
    planned_start_date = Column(DateTime)
    planned_end_date = Column(DateTime)
    replanned_start_date = Column(DateTime)
    replanned_end_date = Column(DateTime)
    modified_on = Column(DateTime, primary_key=True)