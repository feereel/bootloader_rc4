import sys

def ksa(key):
    s = list(range(0, 256))
    j = 0
    for i in range(256):
        t = ord(key[i % len(key)])
        j = (j + s[i] + t) % 256
        s[i], s[j] = s[j], s[i]
    return s

def pgra(s):
    i = 0
    j = 0
    while(True):
        i = (i + 1) % 256
        j = (j + s[i]) % 256
        s[i], s[j] = s[j], s[i]
        t = (s[i] + s[j]) % 256
        yield s[t]

def encrypt(text, gamma):
    
    cipher = [0] * len(text)
    for i in range(len(text)):
        cipher[i] = text[i] ^ next(gamma)
        cipher[i] = cipher[i].to_bytes(1, 'big')
    return b''.join(cipher)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Wrong params!")
        exit(0)
        
    loader = open(sys.argv[1], 'rb')
    payload = open(sys.argv[2], 'rb')
    key = sys.argv[3]
    out = open('image.bin', 'wb')
    
    # generate gamma from key with rc4
    s = ksa(key)
    gamma = pgra(s)
    
    loader_data = loader.read()
    payload_data = payload.read()
    
    cipher = encrypt(payload_data, gamma)

    out.write(loader_data)
    out.write(cipher)
    
    loader.close()
    payload.close()
    out.close()
    