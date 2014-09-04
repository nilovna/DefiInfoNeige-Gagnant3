#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import transaction
import json
import re
from datetime import datetime

from sqlalchemy import engine_from_config

from pyramid.paster import (
    get_appsettings,
    setup_logging,
    )

from pyramid.scripts.common import parse_vars

from ..models import (
    DBSession,
    User,
    UserAddress,
    CarGeolocation,
    Geobase,
    Municipality,
    StreetSection,
    StreetSide,
    StreetSideHistory,
    Planning,
    Base,
    )


def usage(argv):
    cmd = os.path.basename(argv[0])
    print('usage: %s <config_uri> [var=value]\n'
          '(example: "%s development.ini")' % (cmd, cmd))
    sys.exit(1)

def process_geometry_coordinates(id, type, geotype, coordinates_data):
    line_id = 0
    if geotype == "MultiLineString":
        '''
        When geometry is a MultiLineString, process both points and lines.
        '''
        for coordinates_group in coordinates_data:
            point_id = 0
            for coordinates in coordinates_group:
                geobase = Geobase(
                    id = id,
                    type = type,
                    point_id = point_id,
                    line_id = line_id,
                    geotype = geotype,
                    geolat = coordinates[0], 
                    geolng = coordinates[1], 
                    created_on = datetime.now(),
                    )
                DBSession.merge(geobase)
                transaction.manager.commit()
                point_id += 1
            line_id += 1 
    if geotype == 'LineString':
        '''
        When geometry is LineString, process only points
        '''
        point_id = 0
        for coordinates in coordinates_data:               
            geobase = Geobase(
                id = id,
                type = type,
                point_id = point_id,
                line_id = line_id,
                geotype = geotype,
                geolat = coordinates[0], 
                geolng = coordinates[1], 
                created_on = datetime.now(),
                )

            DBSession.merge(geobase)
            transaction.manager.commit()
            point_id += 1

def main(argv=sys.argv):
    if len(argv) < 2:
        usage(argv)
    config_uri = argv[1]
    options = parse_vars(argv[2:])
    setup_logging(config_uri)
    settings = get_appsettings(config_uri, options=options)
    engine = engine_from_config(settings, 'sqlalchemy.')
    DBSession.configure(bind=engine)
    Base.metadata.create_all(engine)
    with transaction.manager:
        '''
        Create reference data
        '''

        '''
        Create single current municipality (Montreal) in municipalities table
        '''
        montreal = Municipality(
            id = 66023,
            municipality_type = "Ville",
            name = u"Montréal",
            county = u"Hors MRC \Communauté métropolitaine de Montréal",
            region = u"Montréal",
            state = u"QC",
            country = u"Canada",
            created_on = datetime.now(),
            )
        DBSession.merge(montreal)
        transaction.manager.commit()

        '''
        Load geobase geojson data and import it in geobase and street_section tables
        ''' 
        geobase_json = open(os.path.dirname(os.path.realpath(__file__)) + '/../../scripts/geobase.json')
        geobase_data = json.load(geobase_json)
        id = 0
        for feature in geobase_data['features']:
            if feature['geometry'] != None:
                process_geometry_coordinates(id=id, type='street_section', geotype=feature['geometry']['type'], coordinates_data=feature['geometry']['coordinates'])
                    
            try:
                feature['properties']['A']
            except KeyError:
                feature['properties']['A'] = None
            try:
                feature['properties']['DE']
            except KeyError:
                feature['properties']['DE'] = None
            
            street_section = StreetSection(
                id = feature['properties']['TRC_ID'],
                municipality_id = 66023,
                street_name = feature['properties']['SUR'],
                starting_intersection = feature['properties']['DE'],
                ending_intersection = feature['properties']['A'],
                traffic_direction = feature['properties']['SENS_CIR'],
                geobase_id = id,
                created_on = datetime.now(),   
                )
            DBSession.merge(street_section)
            transaction.manager.commit()
            id += 1

        '''
        Load street sides geojson data and import it in stree_sides table
        '''
        street_sides_json = open(os.path.dirname(os.path.realpath(__file__)) + '/../../scripts/cote.json')
        street_sides_data = json.load(street_sides_json)
        for feature in street_sides_data['features']:
            if feature['geometry'] != None:
                process_geometry_coordinates(id=id, type='street_side', geotype=feature['geometry']['type'], coordinates_data=feature['geometry']['coordinates'])
            
            street_side = StreetSide(
                id = feature['properties']['COTE_RUE_ID'],
                municipality_id = 66023,
                street_section_id = feature['properties']['ID_TRC'],
                starting_street_number = feature['properties']['DEBUT_ADRESSE'],
                ending_street_number = feature['properties']['FIN_ADRESSE'],
                district_name = feature['properties']['ARRONDISSEMENT'],
                street_name = re.sub(' +', ' ', ' '.join(
                    [ 
                        feature['properties']['TYPE_F'],
                        feature['properties']['LIEN_F'],
                        feature['properties']['NOM_VOIE'],
                        feature['properties']['ORIENTATION_F'],
                    ]
                )),
                geobase_id = id,
                created_on = datetime.now(),
                )
            DBSession.merge(street_side)
            transaction.manager.commit()
            id += 1