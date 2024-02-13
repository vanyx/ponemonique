import firebase_admin
from firebase_admin import credentials, firestore
import random
import time

from capteurs.SRF05 import get_distance
from capteurs.relay import launch_relay
from capteurs.quality2 import get_temperature,get_co2
from capteurs.lum2 import BH1750

# Initialisez Firebase Admin SDK avec le fichier de clé JSON
cred = credentials.Certificate('./clé/cred.json')
firebase_admin.initialize_app(cred)

# Obtenez une référence à la base de données Firestore
db = firestore.client()
collection_ref = db.collection('towers')
noms_documents = []

def update():

    
    try:

        document_ref = db.collection("towers").document('6h2MAEQxaPyzp6baRp7O')

        sous_collection_ref = document_ref.collection('data')
        
        distance = round(get_distance(),1)   
        temperatur=get_temperature()
        temperature=float(temperatur)
        
        number_co2 = get_co2()
        co2 = float(number_co2) + 0.1
        print(co2)
        bh_sensor = BH1750()
       
        luminosite= bh_sensor.light()
        date_actuelle = time.strftime("%Y-%m-%dT%H:%M:%S")
        
        # Mettre à jour les données
        document_ref.update({'niveauEau': float(distance),
                                  'temperatureAir':temperature,
                                  'co2' : co2,
                                  'luminosite':float(luminosite)})
        
        #Creation du nouveau document avec les nouvelles données
        nouveau_document = {
            'temperature': temperature,
            'distance' : distance,
            'luminosite': float(luminosite),
            'co2' : co2,
            'date_combinee': date_actuelle,
        }

        # Ajoutez un nouveau document à la sous-collection 'temperatures'
        sous_collection_ref.add(nouveau_document)
        
        #regarde si le bouton pour la pompe est mis sur on ou sur off sur firebase
        if check_onOff(document_ref):
           print('lancement de la pompe')
           launch_relay()
        

    except Exception as e:
        print('Erreur lors de l\'ajout du nouveau champ :', e)

def check_onOff(last_document_ref):
    doc =last_document_ref.get().to_dict()
    onOff=doc['onOff']
    return onOff

def get_docs():
    try:
        snapshot = collection_ref.get()

        for doc in snapshot:
            nom_document = doc.id
            noms_documents.append(nom_document)
            print('Nom du document:', nom_document)

        print('Noms des documents dans le tableau :', noms_documents)

    except Exception as e:
        print('Erreur lors de la récupération des documents :', e)


def get_random_int(minimum, maximum):
    return random.randint(minimum, maximum)


while True:
    print('début de la recuperation des donnees')
    update()
    time.sleep(10)  # Intervalles de 10 secondes
