import os
import sys
from suds.client import Client
import transaction

from sqlalchemy import engine_from_config

from pyramid.paster import (
    get_appsettings,
    setup_logging,
    )

from pyramid.scripts.common import parse_vars

from infoneige.models import (
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

import logging
log = logging.getLogger(__name__)

from cartodb import CartoDBOAuth, CartoDBException

class SoapImport:
    def usage(self, argv):
        cmd = os.path.basename(argv[0])
        print('usage: %s <config_uri> <fromDate> [var=value]\n'
            '(example: "%s development.ini 2014-07-20T08:00:00")' % (cmd, cmd))
        sys.exit(1)

    def run(self, argv):
        if len(argv) < 3:
            self.usage(argv)
        config_uri = argv[1]
        fromDate = argv[2]
        options = parse_vars(argv[3:])
        setup_logging(config_uri)
        settings = get_appsettings(config_uri, options=options)
        engine = engine_from_config(settings, 'sqlalchemy.')

        DBSession.configure(bind=engine)
        Base.metadata.create_all(engine)
        with transaction.manager:
            url = 'https://servicesenligne2.ville.montreal.qc.ca/api/infoneige/InfoneigeWebService?wsdl'
            client = Client(url)
            planification_request = client.factory.create('getPlanificationsForDate')
            planification_request.fromDate = fromDate
            planification_request.tokenString =  'ug33-b81ab488-c335-4021-9c52-26d6b8523301-e7aa002b-0d9d-4b5c-81ef-b012979cdafb-dab06588-1962-4b16-9942-a18054094f60-a4186179-d555-4fed-b35f-ec0c74da97a3-aa3b3766-4d26-42f0-888a-a6569a1dd745'
            response = client.service.GetPlanificationsForDate(planification_request)
            if response['responseStatus'] == 0:
                log.info('%s plannings returned', response['planifications']['count'])
                cartodb_client = CartoDBOAuth(settings['cartodb.key'], settings['cartodb.secret'], settings['cartodb.user'], settings['cartodb.password'], settings['cartodb.domain'])

                for result in response['planifications']['planification']:
                    '''
                    street_side_status = StreetSideHistory(
                        municipality_id = result['munid'],
                        street_side_id = result['coteRueId'],
                        state = result['etatDeneig'],
                        observed_on = result['dateMaj'],
                        )
                    DBSession.merge(street_side_status)
                    '''
                    if any(val in result for val in ['dateDebutPlanif', 'dateFinPlanif', 'dateDebutReplanif', 'dateFinReplanif']):
                        try:
                            result['dateDebutReplanif']
                        except AttributeError:
                            result['dateDebutReplanif'] = None
                        try:
                            result['dateFinReplanif']
                        except AttributeError:
                            result['dateFinReplanif'] = None
                        '''
                        print result
                        planning = Planning(
                            municipality_id = result['munid'],
                            street_side_id = result['coteRueId'],
                            planned_start_date = result['dateDebutPlanif'],
                            planned_end_date = result['dateFinPlanif'],
                            replanned_start_date = result['dateDebutReplanif'],
                            replanned_end_date = result['dateFinReplanif'],
                            modified_on = result['dateMaj'],
                            )
                        DBSession.merge(planning)
                        '''
                    #transaction.manager.commit()
                    cartodb_client.sql('UPDATE cote SET etat = %(etat)s WHERE cote_rue_id = %(cote_rue_id)d' %
                        {"etat": result['etatDeneig'], "cote_rue_id": result['coteRueId']})
            else:
                log.info('Status %s: %s', response['responseStatus'], response['responseDesc'])
            

if __name__ == "__main__":
    argv = sys.argv
    app = SoapImport()
    if len(argv) < 2:
        app.usage(argv)
    app.run(argv)