import cv2
import numpy as np

def pobierz_bit(klatka):
    gray = cv2.cvtColor(klatka, cv2.COLOR_BGR2GRAY)
    
    bity = np.zeros_like(gray, dtype=np.uint8)
    bity[gray > 192] = 1 
    
    maska_obiektow = (gray > 64).astype(np.uint8) * 255 
    
    return bity, maska_obiektow

img2 = cv2.imread('bit2.png')
img3 = cv2.imread('bit3.png')

if img2 is None or img3 is None:
    print("BŁĄD: Nie znaleziono plików bit2.png lub bit3.png w folderze Lab9!")
    print("Zrób screeny z nagrania wideo i upewnij się, że mają poprawne nazwy.")
    exit()

b2, m2 = pobierz_bit(img2)
b3, m3 = pobierz_bit(img3)

indeksy = (b2.astype(np.int32) * 2) + b3.astype(np.int32)

maska_finalna = cv2.bitwise_and(m2, m3)

h, w = indeksy.shape
wynik_kolor = np.zeros((h, w, 3), dtype=np.uint8)

kolory = {
    0: [0, 0, 255],   # Czerwony
    1: [0, 255, 0],   # Zielony
    2: [255, 0, 0],   # Niebieski
    3: [0, 255, 255]  # Żółty
}

for idx, kolor in kolory.items():
    wynik_kolor[(indeksy == idx) & (maska_finalna > 0)] = kolor

cv2.imshow('Wynik Indeksowania - Lab9', wynik_kolor)
cv2.imwrite('index.png', wynik_kolor)

print("Done")
cv2.waitKey(0)
cv2.destroyAllWindows()