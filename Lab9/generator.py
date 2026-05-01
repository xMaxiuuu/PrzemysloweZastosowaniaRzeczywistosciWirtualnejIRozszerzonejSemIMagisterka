import cv2
import numpy as np
import time

width, height = 1920, 1080
sq_size = 400 
frame_duration = 2000 

pos = [
    (int(width * 0.25 - sq_size/2), int(height * 0.25 - sq_size/2)),
    (int(width * 0.75 - sq_size/2), int(height * 0.25 - sq_size/2)),
    (int(width * 0.25 - sq_size/2), int(height * 0.75 - sq_size/2)),
    (int(width * 0.75 - sq_size/2), int(height * 0.75 - sq_size/2))
]

stany = [
    ("1. TŁO (Czarny)", [0, 0, 0, 0]),
    ("2. SYNC (Wszystkie Białe)", [255, 255, 255, 255]),
    ("3. BIT 2 (Szary, Szary, Biały, Biały)", [128, 128, 255, 255]),
    ("4. BIT 3 (Szary, Biały, Szary, Biały)", [128, 255, 128, 255]),
    ("5. KONIEC (Czarny)", [0, 0, 0, 0])
]

def rysuj(jasnosci):
    img = np.zeros((height, width), dtype=np.uint8)
    for i, p in enumerate(pos):
        cv2.rectangle(img, p, (p[0]+sq_size, p[1]+sq_size), jasnosci[i], -1)
    return img

win_name = 'Lab 9 - Światło strukturalne'
cv2.namedWindow(win_name, cv2.WINDOW_NORMAL)
cv2.resizeWindow(win_name, 1280, 720) 

print("START ZA 5 SEC")
time.sleep(5)

for nazwa, jasnosci in stany:
    klatka = rysuj(jasnosci)
    cv2.imshow(win_name, klatka)
    print(f"Aktualnie: {nazwa}")
    
    key = cv2.waitKey(frame_duration) & 0xFF
    if key == 27: # ESC
        print("Przerwano przez użytkownika.") 
        break

cv2.destroyAllWindows()