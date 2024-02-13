
import RPi.GPIO as GPIO
import time

def setup_gpio():
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)

def cleanup_gpio():
    GPIO.cleanup()

def get_distance():
    TRIG_PIN=24
    ECHO_PIN=23
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    GPIO.setup(TRIG_PIN,GPIO.OUT)
    GPIO.setup(ECHO_PIN,GPIO.IN)
    # Assurez-vous que la broche de déclenchement est à l'état bas
    GPIO.output(TRIG_PIN, False)
    time.sleep(0.2)  # Attendez que les capteurs se stabilisent

    # Déclenchez une impulsion ultrasonique
    GPIO.output(TRIG_PIN, True)
    time.sleep(0.00001)
    GPIO.output(TRIG_PIN, False)

    pulse_start_time = time.time()
    pulse_end_time = time.time()

    # Mesurez le temps que prend le signal pour revenir
    while GPIO.input(ECHO_PIN) == 0:
        pulse_start_time = time.time()

    while GPIO.input(ECHO_PIN) == 1:
        pulse_end_time = time.time()

    pulse_duration = pulse_end_time - pulse_start_time

    # Calcul de la distance en centimètres
    distance = pulse_duration * 34300 / 2

    return distance

if __name__ == "__main__":
    try:

        while True:
            distance = get_distance()
            print(f"Distance: {distance:.2f} cm")
            time.sleep(1)

    except KeyboardInterrupt:
        print("\nProgramme interrompu par l'utilisateur.")
    finally:
        cleanup_gpio()
