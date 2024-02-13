import time
import threading
from guizero import App, Text, Slider
from capteurs.aq import AQ

aq = AQ()



def get_temperature():
    temp_c = aq.get_temp()
    print(temp_c)
    return temp_c

def get_co2():
    eco2 = aq.get_eco2()
    print(eco2)
    return eco2

get_temperature()
get_co2()
