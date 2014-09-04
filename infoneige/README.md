# infoneige
Application Chasse-ta-neige pour la ville de Montréal

1. Cloner le dépôt
    ```bash
      $ git clone git@github.com:nilovna/info-neige.git
    ```

2. Créer et configurer un environnement virtuel
    ```bash
      $ mkvirtualenv infoneige
    ```

3. Copier les exemples de configuration et ajouter les infos manquantes
    ```bash
      $ cd <directory containing this file>
      $ cp development.ini.example development.ini
      $ cp production.ini.example production.ini
    ```

4. Initialiser le serveur
    ```bash
      $ cd <directory containing this file>
      $ pip install -r requirements.txt
      $ python setup.py develop
      $ initialize_InfoNeige_db development.ini
      $ pserve development.ini 
    ```

## Utilisation

### Mettre à jour la planification de déneigement

  ```bash
    $ python scripts/soap_client.py <config_uri> <fromDate> [var=value]
  ```

---

# infoneige (Chasse ta neige)
Chasse-ta-neige Application for the Town of Montreal

## Installation
1. Clone repository
    ```bash
      $ git clone git@github.com:nilovna/info-neige.git
    ```

2. Create and configure a virtual environment
    ```bash
      $ mkvirtualenv infoneige
    ```

3. Copy configuration examples and add missing info
    ```bash
      $ cd <directory containing this file>
      $ cp development.ini.example development.ini
      $ cp production.ini.example production.ini
    ```

4. Initialize the server
    ```bash
      $ cd <directory containing this file>
      $ pip install -r requirements.txt
      $ python setup.py develop
      $ initialize_InfoNeige_db development.ini
      $ pserve development.ini 
    ```

## Usage

### Update snow removal planning

  ```bash
    $ python scripts/soap_client.py <config_uri> <fromDate> [var=value]
  ```
