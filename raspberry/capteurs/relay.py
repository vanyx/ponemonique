import RPi.GPIO as GPIO
import time

# Définir le numéro de broche du relais
RELAY_PIN = 17

try:
    # Initialiser les broches GPIO
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(RELAY_PIN, GPIO.OUT)

    # Activer le relais (allumer)
    GPIO.output(RELAY_PIN, GPIO.HIGH)
    print("Relay turned ON")

    # Attendre pendant 5 secondes
    time.sleep(5)

    # Désactiver le relais (éteindre)
    GPIO.output(RELAY_PIN, GPIO.LOW)
    print("Relay turned OFF")

except KeyboardInterrupt:
    print("Interruption par l'utilisateur")

finally:
    # Nettoyer et réinitialiser les broches GPIO
    GPIO.cleanup()
