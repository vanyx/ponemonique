# Tour Hydroponique - MIoT

Projet de tour hydroponique "ponemonique".

Le projet est pensé pour gérer plusieurs tours depuis une application mobile.

Une tour est composé de capteurs, d'un Raspberry pi, et d'un QR code contenant un identifiant unique.

Depuis l'application mobile, nous avons la possibilité de scanner un QR code :

Lorsque un QR code est scanné, notre utilisateur (précedement crée sur l'application mobile) est ajouté à la liste des utilisateurs ayant accès à la tour.

On retrouve la tour dans le menu principal de l'application :

- Allumage / extinction de la tour à distance depuis l'application
- Visualisation en temps réel des données de la tour : luminosité, CO2, niveau d'eau et température

# Architecture

Capteurs -> Raspberry pi <---> Firebase : Firestore & Firebase Authentification <---> Flutter

# Membres du groupe

- Thomas BENALOUANE
- Enzo POTIN
- Valentin BESNARD
- Zoé COSTAN
