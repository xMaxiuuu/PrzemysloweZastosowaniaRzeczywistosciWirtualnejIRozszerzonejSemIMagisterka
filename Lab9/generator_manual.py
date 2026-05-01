import cv2
import numpy as np

# Wewnętrzna rozdzielczość "płótna" (Full HD dla zachowania jakości)
width, height = 1920, 1080
sq_size = 400 

# Pozycje kwadratów (wyśrodkowane w ćwiartkach)
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

# Tworzymy okno w trybie NORMAL (można je przesuwać i zmieniać rozmiar)
win_name = 'Wyswietlanie Lab9'
cv2.namedWindow(win_name, cv2.WINDOW_NORMAL)
# Ustawiamy startowy rozmiar okna na nieco mniejszy, żeby łatwo było go złapać myszką
cv2.resizeWindow(win_name, 1280, 720) 

print("--- INSTRUKCJA ---")
print("1. Przeciągnij okno na wybrany monitor.")
print("2. Rozpocznij nagrywanie telefonem.")
print("3. Naciskaj SPACJĘ, aby przełączać slajdy. ESC kończy program.")

for nazwa, jasnosci in stany:
    klatka = rysuj(jasnosci)
    cv2.imshow(win_name, klatka)
    print(f"Pokazuję: {nazwa}")
    
    while True:
        key = cv2.waitKey(1) & 0xFF
        if key == ord(' '): # Spacja
            break
        if key == 27: # ESC
            cv2.destroyAllWindows()
            exit()

cv2.destroyAllWindows()